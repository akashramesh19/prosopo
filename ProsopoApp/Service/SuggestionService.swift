//
//  SuggestionService.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 11/10/2025.
//

import Foundation

/// Concrete implementation that delegates to OpenAIClient.
final class SuggestionService: SuggestionServiceProtocol {
    private let client = OpenAIClient()
    
    func suggestPersona(from description: String) async throws -> Persona {
        try await client.suggestPersona(fromDescription: description)
    }
}

