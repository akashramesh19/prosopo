//
//  PersonaService.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 22/9/2025.
//

import Foundation
import FirebaseFirestore

final class PersonaService : PersonaServiceProtocol {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private var collection: CollectionReference { db.collection("personas") }

    //Live listener to observe changes to personas and retrieval of personas from Firestore database
    func observePersonas(for userId: String, onChange: @escaping ([Persona]) -> Void) {
        listener?.remove()
        listener = collection
            .whereField("userId", isEqualTo: userId)
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { snapshot, _ in
                let items = snapshot?.documents.compactMap { try? $0.data(as: Persona.self) } ?? []
                onChange(items)
            }
    }

    func stopObserving() {
        listener?.remove()
        listener = nil
    }


    //This is used for inserting new personas to the firestore database
    func addPersona(_ persona: Persona, userId: String) async throws {
        var p = persona
        p.userId = userId
        p.createdAt = Date()
        p.updatedAt = Date()
        _ = try collection.addDocument(from: p)
    }

    //Used for updating Personas in database when user updates their saved personas
    func updatePersona(_ persona: Persona) async throws {
        guard let id = persona.id else { return }
        var p = persona
        p.updatedAt = Date()
        try collection.document(id).setData(from: p, merge: true)
    }

    //Deleting personas from database
    func deletePersona(_ persona: Persona) async throws {
        guard let id = persona.id else { return }
        try await collection.document(id).delete()
    }
    
    //Checking for existing Personas with same name
    func existsPersonaNamed(_ name: String, userId: String) async throws -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return try await withCheckedThrowingContinuation { cont in
            Firestore.firestore()
                .collection("personas")
                .whereField("userId", isEqualTo: userId)
                .whereField("name", isEqualTo: trimmed)
                .limit(to: 1)
                .getDocuments { snap, err in
                    if let err = err { cont.resume(throwing: err) }
                    else { cont.resume(returning: (snap?.documents.count ?? 0) > 0) }
                }
        }
    }
}
