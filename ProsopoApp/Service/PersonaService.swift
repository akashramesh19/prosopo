//
//  PersonaService.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 22/9/2025.
//

import Foundation
import FirebaseFirestore

/**
 A final class used to manage all persona-related operations in Firestore.

 The service handles:
 1. Creation of new personas
 2. Updating existing personas
 3. Deletion of personas
 4. Retrieval and observation of persona collections
 */
final class PersonaService: PersonaServiceProtocol {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    /// A computed reference to the `personas` collection in Firestore.
    private var collection: CollectionReference { db.collection("personas") }

    /// Observes personas for a specific user, returning updates in real time.
    ///
    /// - Parameters:
    ///   - userId: The identifier of the user.
    ///   - onChange: Closure invoked with the updated list of personas whenever data changes.
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
    
    /// Stops observing changes to the persona collection.
    func stopObserving() {
        listener?.remove()
        listener = nil
    }

    /// Inserts a new persona document into Firestore.
    ///
    /// - Parameters:
    ///   - persona: The persona object to insert.
    ///   - userId: The identifier of the user to whom the persona belongs.
    /// - Throws: An error if Firestore insertion fails.
    func addPersona(_ persona: Persona, userId: String) async throws {
        var p = persona
        p.userId = userId
        p.createdAt = Date()
        p.updatedAt = Date()
        _ = try collection.addDocument(from: p)
    }

    /// Updates an existing persona document in Firestore.
    ///
    /// - Parameter persona: The updated persona object. Requires a valid `id`.
    /// - Throws: An error if Firestore update fails.
    func updatePersona(_ persona: Persona) async throws {
        guard let id = persona.id else { return }
        var p = persona
        p.updatedAt = Date()
        try collection.document(id).setData(from: p, merge: true)
    }

    /// Deletes a persona document from Firestore.
    ///
    /// - Parameter persona: The persona object to delete. Requires a valid `id`.
    /// - Throws: An error if Firestore deletion fails.
    func deletePersona(_ persona: Persona) async throws {
        guard let id = persona.id else { return }
        try await collection.document(id).delete()
    }
    
    /// Checks whether a persona with the same name already exists for a user.
    ///
    /// - Parameters:
    ///   - name: Name of the persona to check.
    ///   - userId: The identifier of the user.
    /// - Returns: `true` if a persona with the same name exists, otherwise `false`.
    /// - Throws: An error if the Firestore query fails.
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
