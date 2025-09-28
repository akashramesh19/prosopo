//
//  OpenApiClient.swift
//  Prosopo
//
//  Created by Akash Ramesh on 29/8/2025.
//

import Foundation

/// The struct encodes the request body with keys `model` and `input`.
struct OpenAIResponsesRequest: Encodable {
    let model: String
    let input: String
}

/// The root response from the API. It can contain `output`, `response`, or `content`.
/// Only the values under the key `output` are consumed by the app.
struct OpenAIResponsesRoot: Decodable {
    let output: [OpenAIOutput]?
    let response: OpenAIOutputWrapper?
    let content: [OpenAIContent]?
}

/// Output wrapper for parsing the JSON key `output`.
struct OpenAIOutputWrapper: Decodable {
    let output: [OpenAIOutput]
}

/// The JSON output returned by OpenAI. Contains identifiers, type, role, and content.
/// The property `content` is the relevant part consumed by the application.
struct OpenAIOutput: Decodable {
    let id: String?
    let type: String?
    let role: String?
    let content: [OpenAIContent]?
}

/// Represents the textual content returned in the response.
struct OpenAIContent: Decodable {
    let type: String?
    let text: String?
}

/**
 A final class used to manage all communication with the OpenAI API.

 This class contains the endpoint URL, model identifier, and the function to generate
 prompts for personas. It also includes request/response structures required for
 encoding the request and decoding the response.

 ### Request format (as per OpenAI documentation):
 - `model`: the model type (e.g., `chatgpt-4o-mini`)
 - `input`: a string containing the input message

 ### Response format:
 - `output`: the structured output
 - `response`: a wrapper around output
 - `content`: the textual result

 For decoding, `OpenAIOutputWrapper`, `OpenAIOutput`, and `OpenAIContent` are defined.

 Example response provided in the official documentation includes multiple keys such as
 `id`, `status`, `model`, `output`, and `usage`. Only a subset relevant to persona
 prompt generation is extracted in this implementation.

 Reference: https://platform.openai.com/docs/api-reference/responses/create
 */
final class OpenAIClient {
    private let endpoint = URL(string: "https://api.openai.com/v1/responses")!
    private let model = "gpt-4o-mini"
    private let apiKey: String
    
    init() {
        /// Loads API key from `Secret.plist`.
        if let path = Bundle.main.path(forResource: "Secret", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["openAIKey"] as? String {
            self.apiKey = key
        } else {
            fatalError("Missing OpenAI Key in Secret.plist")
        }
    }

    /// Generates a persona prompt using the configured OpenAI model.
    ///
    /// - Parameters:
    ///   - name: Persona name.
    ///   - role: Persona role.
    ///   - tone: Tone applied to the prompt.
    ///   - guardrails: Constraints or restrictions applied to the persona.
    ///   - temperature: Degree of variability in responses.
    /// - Returns: A string prompt formatted for the persona.
    /// - Throws: `URLError` if the request fails or response cannot be parsed.
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
        
        /// Input text template sent to OpenAI for generating prompts.
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
        
        /// Encodes the payload request body.
        let payload = OpenAIResponsesRequest(model: model, input: input)
        req.httpBody = try JSONEncoder().encode(payload)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        /// Decodes the prompt text from the response.
        if let prompt = try? decodePromptText(from: data) { return prompt }
        if let prompt = try? fallbackExtractText(from: data) { return prompt }
        throw URLError(.cannotParseResponse)
    }
    
    /// Decodes prompt text from structured response objects.
    ///
    /// - Parameter data: JSON data returned from the API.
    /// - Returns: The decoded prompt text.
    /// - Throws: `URLError` if no valid text is found.
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
    
    /// Fallback method for extracting prompt text manually from JSON.
    ///
    /// - Parameter data: Raw JSON data.
    /// - Returns: The extracted prompt text if available, otherwise raw JSON string.
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
