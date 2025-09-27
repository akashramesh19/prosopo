//
//  EditPersonaModel.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 27/9/2025.
//

import Foundation

@MainActor
final class EditPersonaModel: ObservableObject {

    @Published var name: String
    @Published var role: String
    @Published var tone: PersonaTone
    @Published var guardrails: String
    @Published var consistency: Double
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let original: Persona
    private let promptService: PromptServiceProtocol
    private let service: PersonaServiceProtocol

    init(original: Persona,
         promptService: PromptServiceProtocol = PromptService(),
         service: PersonaServiceProtocol = PersonaService()) {
        self.original = original
        self.name = original.name
        self.role = original.role
        self.tone = original.tone
        self.guardrails = original.guardrail
        self.consistency = original.consistency
        self.promptService = promptService
        self.service = service
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !role.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func save() async -> Persona? {
        guard canSave else { return nil }
        isSaving = true
        defer { isSaving = false }

        var updated = original
        updated.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.role = role.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.tone = tone
        updated.guardrail = guardrails
        updated.consistency = consistency

        do {
            let newPrompt = try await promptService.generatePrompt(for: updated)
            updated.prompt = newPrompt
            try await service.updatePersona(updated)
            return updated
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func delete(confirm: Bool) async -> Bool {
        guard confirm else { return false }
        isSaving = true
        defer { isSaving = false }
        do {
            try await service.deletePersona(original)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
