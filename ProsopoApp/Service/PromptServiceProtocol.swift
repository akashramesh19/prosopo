//
//  PromptServiceProtocol.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 27/9/2025.
//

import Foundation

protocol PromptServiceProtocol {
    func generatePrompt(for persona: Persona) async throws -> String
}
