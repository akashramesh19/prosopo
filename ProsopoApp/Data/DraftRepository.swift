//
//  DraftRepository.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 24/9/2025.
//

import Foundation
import SwiftData

struct DraftRepository {
    let context: ModelContext

    func upsertDraft(_ draft: DraftPersona) throws {
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
