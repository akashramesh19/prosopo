//
//  PersonaServiceProtocol.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 27/9/2025.
//

import Foundation

/// Contract describing persona-related operations backed by a data store.
protocol PersonaServiceProtocol {
    /// Subscribes to persona changes for a specific user and emits real-time updates.
    ///
    /// - Parameters:
    ///   - userId: Identifier of the user whose personas are observed.
    ///   - onChange: Callback invoked with the current list of personas whenever a change occurs.
    func observePersonas(for userId: String, onChange: @escaping ([Persona]) -> Void)

    /// Stops any active observation on the personas collection.
    func stopObserving()

    /// Inserts a new persona for the specified user.
    ///
    /// - Parameters:
    ///   - persona: Persona to insert.
    ///   - userId: Identifier of the user who owns the persona.
    /// - Throws: An error if the insert operation fails.
    func addPersona(_ persona: Persona, userId: String) async throws

    /// Updates an existing persona.
    ///
    /// - Parameter persona: Persona with modified fields. Requires a valid `id`.
    /// - Throws: An error if the update operation fails.
    func updatePersona(_ persona: Persona) async throws

    /// Deletes an existing persona.
    ///
    /// - Parameter persona: Persona to delete. Requires a valid `id`.
    /// - Throws: An error if the delete operation fails.
    func deletePersona(_ persona: Persona) async throws

    /// Checks for the existence of a persona with the given name for the user.
    ///
    /// - Parameters:
    ///   - name: Persona name to check.
    ///   - userId: Identifier of the user.
    /// - Returns: `true` if a persona with the same name exists, otherwise `false`.
    /// - Throws: An error if the lookup operation fails.
    func existsPersonaNamed(_ name: String, userId: String) async throws -> Bool
}
