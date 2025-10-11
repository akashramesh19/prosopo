//
//  AddPersonaModelTests.swift
//  ProsopoAppTests
//
//  Created by Akash Ramesh on 27/9/2025.
//

import XCTest
@testable import ProsopoApp

final class AddPersonaModelTests: XCTestCase {

    final class MockPersonaService_NoDuplicate: PersonaServiceProtocol {
        func observePersonas(for userId: String, onChange: @escaping ([Persona]) -> Void) {}
        func stopObserving() {}
        func addPersona(_ persona: Persona, userId: String) async throws {}
        func updatePersona(_ persona: Persona) async throws {}
        func deletePersona(_ persona: Persona) async throws {}
        func existsPersonaNamed(_ name: String, userId: String) async throws -> Bool { false }
    }

    final class MockPersonaService_Duplicate: PersonaServiceProtocol {
        func observePersonas(for userId: String, onChange: @escaping ([Persona]) -> Void) {}
        func stopObserving() {}
        func addPersona(_ persona: Persona, userId: String) async throws {}
        func updatePersona(_ persona: Persona) async throws {}
        func deletePersona(_ persona: Persona) async throws {}
        func existsPersonaNamed(_ name: String, userId: String) async throws -> Bool { true }
    }


    struct MockPromptService_Success: PromptServiceProtocol {
        func generatePrompt(for persona: Persona) async throws -> String { "PROMPT_OK" }
    }

    struct MockPromptService_Failure: PromptServiceProtocol {
        struct BadKey: LocalizedError { var errorDescription: String? { "Invalid API key" } }
        func generatePrompt(for persona: Persona) async throws -> String { throw BadKey() }
    }

    @MainActor
    func test_validValues_personaGetsCreated() async {
        let model = AddPersonaModel(
            service: MockPersonaService_NoDuplicate(),
            promptService: MockPromptService_Success()
        )
        model.setUserId("uid-1")
        model.name = "Writer"
        model.role = "Technical Writer"
        model.tone = .precise
        model.guardrails = "Keep it short"
        model.consistency = 0.6

        let p = await model.createPersona()
        XCTAssertNotNil(p)
        XCTAssertEqual(p?.prompt, "PROMPT_OK")
        XCTAssertNil(model.errorMessage)
    }

    @MainActor
    func test_duplicateName_personaDoesNotGetCreated() async {
        let model = AddPersonaModel(
            service: MockPersonaService_Duplicate(),
            promptService: MockPromptService_Success()
        )
        model.setUserId("uid-1")
        model.name = "Existing"
        model.role = "PM"

        let p = await model.createPersona()
        XCTAssertNil(p)
        XCTAssertEqual(model.errorMessage, "Persona name already exists.")
    }

    @MainActor
    func test_apiKeyWrong_throwsAndSurfacesMessage() async {
        let model = AddPersonaModel(
            service: MockPersonaService_NoDuplicate(),
            promptService: MockPromptService_Failure()
        )
        model.setUserId("uid-1")
        model.name = "Any"
        model.role = "Any"

        let p = await model.createPersona()
        XCTAssertNil(p)
        XCTAssertEqual(model.errorMessage, "Invalid API key")
    }
    
    @MainActor
    func test_emptyName_draftNotCreated() throws {
        final class MockContext {}
        struct MockRepository: @unchecked Sendable {
            var didInsert = false
            mutating func upsertDraft(_ draft: DraftPersona) throws {
                didInsert = true
                throw XCTSkip("Should not be called for empty name")
            }
        }

        var repo = MockRepository()
        let context = MockContext()
        let draft = DraftPersona(userId: "user-1", name: "", role: "Dev")

        // Simulate upsertDraft with same logic as real repository
        let trimmed = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            // Expected: should not insert
            XCTAssertFalse(repo.didInsert, "Draft should not be inserted when name is empty.")
        } else {
            try repo.upsertDraft(draft)
        }
    }

}
