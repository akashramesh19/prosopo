//
//  AddPersonaModel.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 22/9/2025.
//

import Foundation

/*
 The Add persona model is used as a template to show the individual fields for the Add Persona page.
 The can Create boolean is used to confirm if the form is valid to create the Persona (Required fields are present)
 */

@MainActor
final class AddPersonaModel: ObservableObject {
    @Published var name = ""
    @Published var role = ""
    @Published var tone: PersonaTone = .precise
    @Published var guardrails = ""
    @Published var consistency: Double = 0.5

    @Published var isCreating = false
    @Published var errorMessage: String?

    private let service = PromptService()
    
    //For form validation
    var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !role.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !tone.rawValue.isEmpty
    }
    
    //To create persona and check if the persona is still creating in the view
    func createPersona() async -> Persona? {
        isCreating = true
        defer { isCreating = false }

        var persona = Persona(
            name: name,
            role: role,
            tone: tone,
            guardrail: guardrails,
            consistency: consistency
        )

        do {
            let prompt = try await service.generatePrompt(for: persona)
            persona.prompt = prompt
            return persona
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
