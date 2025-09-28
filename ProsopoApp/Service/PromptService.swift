//
//  PromptService.swift
//  Prosopo
//
//  Created by Akash Ramesh on 29/8/2025.
//

import Foundation

/**
 Service responsible for generating prompts via the OpenAI client.

 The class delegates the request to `OpenAIClient` and ensures that
 prompt generation is executed asynchronously without blocking the
 main thread. This preserves UI responsiveness while network calls
 are performed in the background.
 */
final class PromptService: PromptServiceProtocol {
    private let client = OpenAIClient()

    /// Generates a system prompt string for the given persona.
    ///
    /// - Parameter persona: Persona whose attributes are used to construct the prompt.
    /// - Returns: A completed prompt string generated from OpenAI.
    /// - Throws: An error if the request or response parsing fails.
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
