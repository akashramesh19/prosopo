//
//  PromptService.swift
//  Prosopo
//
//  Created by Akash Ramesh on 29/8/2025.
//

import Foundation

/*
 The actual service that is used to call the generate prompt function to the API. Async and await is used to block the main thread (UI) till the function completes building network connection with Open AI API, sends request, waits for response and receives response. This way the main thread of the application does not break and UI is not affected till this is done.
 */

final class PromptService {
    private let client = OpenAIClient()

    func generatePrompt(
        for persona: Persona
    ) async throws -> String {
        try await client.generatePersonaPrompt(
            name: persona.name,
            role: persona.role,
            tone: persona.tone.rawValue.capitalized,
            guardrails: persona.guardrail,
            temperature: persona.temperature
        )
    }
}
