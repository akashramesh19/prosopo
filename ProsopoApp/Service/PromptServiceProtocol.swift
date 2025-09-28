//
//  PromptServiceProtocol.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 27/9/2025.
//

import Foundation

/// Contract describing the functionality for generating prompts from a persona.
protocol PromptServiceProtocol {
    /// Builds a system prompt string using the provided persona.
    ///
    /// - Parameter persona: Persona containing the attributes required for prompt construction.
    /// - Returns: A prompt string generated from the persona details.
    /// - Throws: An error if prompt generation fails.
    func generatePrompt(for persona: Persona) async throws -> String
}
