//
//  AddPersonaModel.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 22/9/2025.
//

import Foundation
import SwiftData
import FirebaseFirestore

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

    //Using protocols so that it can be mocked in tests
    private let promptService: PromptServiceProtocol
    private let personaService: PersonaServiceProtocol
    
    //SwiftData bindings for local drafts
    private var context: ModelContext?
    private var userId: String?

    //For form validation
    var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !role.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !tone.rawValue.isEmpty
    }

    //Default DI keeps production behavior unchanged
    init(service: PersonaServiceProtocol = PersonaService(),
         promptService: PromptServiceProtocol = PromptService()) {
        self.personaService = service
        self.promptService = promptService
    }
    
    //To create persona and check if the persona is still creating in the view
    func createPersona() async -> Persona? {
        isCreating = true
        defer { isCreating = false }

        if let uid = userId {
            do {
                if try await personaService.existsPersonaNamed(name, userId: uid) {
                    errorMessage = "Persona name already exists."
                    return nil
                }
            } catch {
                errorMessage = error.localizedDescription
                return nil
            }
        }

        var persona = Persona(
            name: name,
            role: role,
            tone: tone,
            guardrail: guardrails,
            consistency: consistency
        )

        do {
            let prompt = try await promptService.generatePrompt(for: persona)
            persona.prompt = prompt
            return persona
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func bind(context: ModelContext) {
        self.context = context
    }

    func setUserId(_ uid: String) {
        self.userId = uid
    }

    func saveDraftIfPossible() {
        guard let context, let uid = userId else { return }
        //Upsert: one draft per user
        if let existing = fetchDraft(for: uid, in: context) {
            existing.name = name
            existing.role = role
            existing.toneRaw = tone.rawValue
            existing.guardrail = guardrails
            existing.consistency = consistency
            existing.updatedAt = .now
        } else {
            let draft = DraftPersona(
                userId: uid,
                name: name,
                role: role,
                toneRaw: tone.rawValue,
                guardrail: guardrails,
                consistency: consistency
            )
            context.insert(draft)
        }
        try? context.save()
    }

    func loadDraftIfAny() {
        guard let context, let uid = userId else { return }
        if let d = fetchDraft(for: uid, in: context) {
            name = d.name
            role = d.role
            tone = PersonaTone(rawValue: d.toneRaw) ?? .precise
            guardrails = d.guardrail
            consistency = d.consistency
        }
    }

    func deleteDrafts() {
        guard let context, let uid = userId else { return }
        let predicate = #Predicate<DraftPersona> { $0.userId == uid }
        if let items = try? context.fetch(FetchDescriptor<DraftPersona>(predicate: predicate)) {
            for i in items { context.delete(i) }
            try? context.save()
        }
    }

    private func fetchDraft(for uid: String, in context: ModelContext) -> DraftPersona? {
        let predicate = #Predicate<DraftPersona> { $0.userId == uid }
        var desc = FetchDescriptor<DraftPersona>(predicate: predicate)
        desc.sortBy = [SortDescriptor(\.updatedAt, order: .reverse)]
        desc.fetchLimit = 1
        return (try? context.fetch(desc))?.first
    }
}
