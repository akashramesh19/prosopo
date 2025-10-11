//
//  DraftRepository.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 24/9/2025.
//

import Foundation
import SwiftData

/**
 Draft Repository is used to upsert and fetch drafts to SwiftData in the IPhone.
 The drafts are upserted as one user can only have one draft.
 
 A Delete Draft function is also defined to delete the draft once the user creates the Persona.
 **/
struct DraftRepository {
    let context: ModelContext

    func upsertDraft(_ draft: DraftPersona) throws {
        let trimmed = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        draft.name = trimmed
        if let existing = try fetchDraft(userId: draft.userId) {
            existing.name = draft.name
            existing.role = draft.role
            existing.toneRaw = draft.toneRaw
            existing.guardrail = draft.guardrail
            existing.consistency = draft.consistency
            existing.updatedAt = .now
        } else {
            context.insert(draft)
        }
        try context.save()
    }

    func fetchDraft(userId: String) throws -> DraftPersona? {
        let predicate = #Predicate<DraftPersona> { $0.userId == userId }
        var desc = FetchDescriptor<DraftPersona>(predicate: predicate)
        desc.sortBy = [SortDescriptor(\.updatedAt, order: .reverse)]
        desc.fetchLimit = 1
        return try context.fetch(desc).first
    }

    func deleteDrafts(for userId: String) throws {
        let predicate = #Predicate<DraftPersona> { $0.userId == userId }
        let desc = FetchDescriptor<DraftPersona>(predicate: predicate)
        for d in try context.fetch(desc) { context.delete(d) }
        try context.save()
    }
}
