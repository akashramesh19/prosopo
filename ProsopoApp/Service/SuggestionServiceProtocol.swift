//
//  SuggestionServiceProtocol.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 11/10/2025.
//

import Foundation

/// Contract for suggesting persona fields from a free-form description.
protocol SuggestionServiceProtocol {
    /// Returns a Persona suggestion built from a free-form description.
    func suggestPersona(from description: String) async throws -> Persona
}
