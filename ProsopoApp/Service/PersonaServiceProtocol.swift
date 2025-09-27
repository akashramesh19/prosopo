//
//  PersonaServiceProtocol.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 27/9/2025.
//

import Foundation

protocol PersonaServiceProtocol {
    func observePersonas(for userId: String, onChange: @escaping ([Persona]) -> Void)
    func stopObserving()
    func addPersona(_ persona: Persona, userId: String) async throws
    func updatePersona(_ persona: Persona) async throws
    func deletePersona(_ persona: Persona) async throws
    func existsPersonaNamed(_ name: String, userId: String) async throws -> Bool
}
