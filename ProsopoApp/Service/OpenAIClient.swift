//
//  OpenApiClient.swift
//  Prosopo
//
//  Created by Akash Ramesh on 29/8/2025.
//

import Foundation

/*
 Contains all the required request response JSON format as structs. This entire file is used to communicate with Open AI API.
 The Request according to the open AI developer page documentation should contain:
 - model type (example: chatgpt-4o-mini)
 - input (string with the input message)
 
 The response will likely contain:
 - Open AI output
 - Response
 - Content from the response to the query we sent as input
 
 For this, OpenAIOutputWrapper, OpenAIOutput and OpenAIContent is created.
 An example JSON response given for a text input request in the documentation:
 {
   "id": "resp_67ccd2bed1ec8190b14f964abc0542670bb6a6b452d3795b",
   "object": "response",
   "created_at": 1741476542,
   "status": "completed",
   "error": null,
   "incomplete_details": null,
   "instructions": null,
   "max_output_tokens": null,
   "model": "gpt-4.1-2025-04-14",
   "output": [
     {
       "type": "message",
       "id": "msg_67ccd2bf17f0819081ff3bb2cf6508e60bb6a6b452d3795b",
       "status": "completed",
       "role": "assistant",
       "content": [
         {
           "type": "output_text",
           "text": "In a peaceful grove beneath a silver moon, a unicorn named Lumina discovered a hidden pool that reflected the stars. As she dipped her horn into the water, the pool began to shimmer, revealing a pathway to a magical realm of endless night skies. Filled with wonder, Lumina whispered a wish for all who dream to find their own hidden magic, and as she glanced back, her hoofprints sparkled like stardust.",
           "annotations": []
         }
       ]
     }
   ],
   "parallel_tool_calls": true,
   "previous_response_id": null,
   "reasoning": {
     "effort": null,
     "summary": null
   },
   "store": true,
   "temperature": 1.0,
   "text": {
     "format": {
       "type": "text"
     }
   },
   "tool_choice": "auto",
   "tools": [],
   "top_p": 1.0,
   "truncation": "disabled",
   "usage": {
     "input_tokens": 36,
     "input_tokens_details": {
       "cached_tokens": 0
     },
     "output_tokens": 87,
     "output_tokens_details": {
       "reasoning_tokens": 0
     },
     "total_tokens": 123
   },
   "user": null,
   "metadata": {}
 }
 Reference: https://platform.openai.com/docs/api-reference/responses/create

 This is taken into smaller required chunks using the individual struct objects mentioned above.
 */

//This when encoded forms a JSON request with keys model and input.
struct OpenAIResponsesRequest: Encodable {
    let model: String
    let input: String
}

//This contains the response root. This is broken down into chunks using the individual structs below this. The app only take in the values under the key "output".
struct OpenAIResponsesRoot: Decodable {
    let output: [OpenAIOutput]?
    let response: OpenAIOutputWrapper?
    let content: [OpenAIContent]?
}

//The output wrapper to breakdown the JSON to the key "output".
struct OpenAIOutputWrapper: Decodable { let output: [OpenAIOutput] }

//The actual required keys from the JSON response from Open AI. Contains the content, id, type and role.
struct OpenAIOutput: Decodable {
    let id: String?
    let type: String?
    let role: String?
    let content: [OpenAIContent]? //This is what the app actually needs.
}

//The Content inside the response JSON contains the text returned from the Open AI LLM.
struct OpenAIContent: Decodable {
    let type: String?
    let text: String?
}

//OpenAIClient class is kept final as it does not require to be inherited. This class contains all the endpoint, model and generate prompt function to create the prompt using Open AI LLM.
final class OpenAIClient {
    private let endpoint = URL(string: "https://api.openai.com/v1/responses")!
    private let model = "gpt-4o-mini"
    private let apiKey: String
    
    init() {
        // Load API key from Secrets.plist
        if let path = Bundle.main.path(forResource: "Secret", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["openAIKey"] as? String {
            self.apiKey = key
        } else {
            fatalError("Missing OpenAI Key in Secret.plist")
        }
    }

    func generatePersonaPrompt(
        name: String,
        role: String,
        tone: String,
        guardrails: String,
        temperature: Double
    ) async throws -> String {
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        //The input text the app sends to Open AI. This was created to match consistency using ChatGPT.
        let input = """
        You output a single, production-ready SYSTEM PROMPT for a chat assistant persona.

        Requirements:
        - Fold all inputs below into concise, directive instructions (10–18 lines).
        - Reflect the requested tone.
        - Enforce guardrails clearly.
        - Output PLAIN TEXT ONLY (no markdown, no quotes, no code fences, no extra commentary).
        
        Always give consistent prompts based on the Persona inputs I give you. Keep a temperature of 0.2 for the prompt generation.

        Persona Inputs:
        Name: \(name)
        Role: \(role)
        Tone: \(tone)
        Guardrails: \(guardrails)
        Target Temperature for consistency (lower means more consistent and higher means more towards humanity): \(String(format: "%.2f", temperature))
        Give the temperature back in the prompt ensuring that the prompt always invokes that temperature.
        """
        
        //The payload request that will be sent to Open AI is created and encoded here.
        let payload = OpenAIResponsesRequest(model: model, input: input)
        req.httpBody = try JSONEncoder().encode(payload)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        //The prompt text is decoded here from the response.
        if let prompt = try? decodePromptText(from: data) { return prompt }
        if let prompt = try? fallbackExtractText(from: data) { return prompt }
        throw URLError(.cannotParseResponse)
    }
    
    //Function to decode prompt text using open AI documentation's example and recommendations.
    private func decodePromptText(from data: Data) throws -> String {
        let root = try JSONDecoder().decode(OpenAIResponsesRoot.self, from: data)

        if let txt = root.output?.first?.content?.compactMap({ $0.text }).joined(),
           !txt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return txt }

        if let txt = root.response?.output.first?.content?.compactMap({ $0.text }).joined(),
           !txt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return txt }

        if let txt = root.content?.compactMap({ $0.text }).joined(),
           !txt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return txt }

        throw URLError(.cannotParseResponse)
    }
    
    //If the decoding function above fails, the fall back function extracts the information required manually by treating the response as a dictionary.
    private func fallbackExtractText(from data: Data) throws -> String {
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let output = obj?["output"] as? [[String: Any]],
           let content = output.first?["content"] as? [[String: Any]] {
            let text = content.compactMap { $0["text"] as? String }.joined()
            if !text.isEmpty { return text }
        }
        return String(data: data, encoding: .utf8) ?? ""
    }
}
