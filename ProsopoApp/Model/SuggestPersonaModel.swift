//
//  SuggestPersonaModel.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 11/10/2025.
//

import Foundation
import FirebaseFirestore

/*
 View model that handles suggesting a persona from a description input.
 Manages interaction between the view, suggestion service, and persona persistence.
*/

final class SuggestPersonaModel: ObservableObject {
    @Published var descriptionText: String = ""
    @Published var suggested: Persona?
    @Published var isGenerating = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let suggestionService: SuggestionServiceProtocol
    private let promptService: PromptServiceProtocol
    private let personaService: PersonaServiceProtocol

    private var userId: String?

    // Dependency injection for modular service usage
    init(
        suggestionService: SuggestionServiceProtocol = SuggestionService(),
        promptService: PromptServiceProtocol = PromptService(),
        personaService: PersonaServiceProtocol = PersonaService()
    ) {
        self.suggestionService = suggestionService
        self.promptService = promptService
        self.personaService = personaService
    }

    // Sets the current user context
    func start(userId: String) {
        self.userId = userId
    }

    // Sends description to AI model and receives suggested persona
    @MainActor
    func suggest() async {
        let input = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return }
        isGenerating = true
        errorMessage = nil
        do {
            let p = try await suggestionService.suggestPersona(from: input)
            suggested = p
        } catch {
            errorMessage = error.localizedDescription
        }
        isGenerating = false
    }

    // Generates prompt for the suggested persona and saves to Firestore
    @MainActor
    func saveSuggested() async -> Persona? {
        guard var persona = suggested, let uid = userId else { return nil }
        isSaving = true
        defer { isSaving = false }
        do {
            let prompt = try await promptService.generatePrompt(for: persona)
            persona.prompt = prompt
            try await personaService.addPersona(persona, userId: uid)
            return persona
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
