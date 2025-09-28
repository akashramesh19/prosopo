//
//  AddPersonaModel.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 22/9/2025.
//

import Foundation
import SwiftData
import FirebaseFirestore

/**
 View model for the Add Persona screen.

 Provides published properties for form fields and state flags,
 handles validation, and integrates with services for prompt
 generation and persistence.

 Drafts are managed locally with SwiftData to ensure progress
 is not lost if the form is dismissed.
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

    /// Services injected for prompt generation and persona persistence.
    private let promptService: PromptServiceProtocol
    private let personaService: PersonaServiceProtocol
    
    /// SwiftData context for managing local drafts.
    private var context: ModelContext?
    /// Current user identifier, required for persistence and uniqueness checks.
    private var userId: String?

    /// Form validation flag. Returns `true` if required fields are non-empty.
    var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !role.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !tone.rawValue.isEmpty
    }

    /// Initializes the model with default production services.
    init(service: PersonaServiceProtocol = PersonaService(),
         promptService: PromptServiceProtocol = PromptService()) {
        self.personaService = service
        self.promptService = promptService
    }
    
    /// Creates a persona by validating input, checking for duplicates, and generating a prompt.
    ///
    /// - Returns: A new `Persona` object if successful, otherwise `nil`.
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

    /// Binds a SwiftData context for draft persistence.
    func bind(context: ModelContext) {
        self.context = context
    }

    /// Assigns the current user identifier for persona operations.
    func setUserId(_ uid: String) {
        self.userId = uid
    }

    /// Saves the current form state as a draft for the user.
    ///
    /// Ensures one draft per user (upsert behavior).
    func saveDraftIfPossible() {
        guard let context, let uid = userId else { return }
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

    /// Loads the most recent draft for the current user if available.
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

    /// Deletes all drafts belonging to the current user.
    func deleteDrafts() {
        guard let context, let uid = userId else { return }
        let predicate = #Predicate<DraftPersona> { $0.userId == uid }
        if let items = try? context.fetch(FetchDescriptor<DraftPersona>(predicate: predicate)) {
            for i in items { context.delete(i) }
            try? context.save()
        }
    }

    /// Fetches the latest draft for a user.
    private func fetchDraft(for uid: String, in context: ModelContext) -> DraftPersona? {
        let predicate = #Predicate<DraftPersona> { $0.userId == uid }
        var desc = FetchDescriptor<DraftPersona>(predicate: predicate)
        desc.sortBy = [SortDescriptor(\.updatedAt, order: .reverse)]
        desc.fetchLimit = 1
        return (try? context.fetch(desc))?.first
    }
}
