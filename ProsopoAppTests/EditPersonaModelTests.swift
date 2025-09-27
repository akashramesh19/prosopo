//
//  EditPersonaModelTests.swift
//  ProsopoAppTests
//
//  Created by Akash Ramesh on 27/9/2025.
//

import XCTest
@testable import ProsopoApp

final class MockPersonaService: PersonaServiceProtocol {
    //Simple flags for verification without hitting Firestore (Isolated Testing)
    private(set) var didUpdate = false
    private(set) var lastUpdated: Persona?
    private(set) var didDelete = false
    private(set) var lastDeleted: Persona?

    //Not used in the scope of the tests below, but required by protocol
    func observePersonas(for userId: String, onChange: @escaping ([Persona]) -> Void) {}
    func stopObserving() {}
    func addPersona(_ persona: Persona, userId: String) async throws {}
    func existsPersonaNamed(_ name: String, userId: String) async throws -> Bool { false }

    func updatePersona(_ persona: Persona) async throws {
        didUpdate = true
        lastUpdated = persona
    }

    func deletePersona(_ persona: Persona) async throws {
        didDelete = true
        lastDeleted = persona
    }
}

struct MockPromptService_Success: PromptServiceProtocol {
    let value: String
    func generatePrompt(for persona: Persona) async throws -> String { value }
}

struct MockPromptService_Slow: PromptServiceProtocol {
    func generatePrompt(for persona: Persona) async throws -> String {
        try await Task.sleep(nanoseconds: 150_000_000)
        return "SLOW_PROMPT"
    }
}

private func makePersona(
    id: String? = "p1",
    userId: String? = "uid-1",
    name: String = "OldName",
    role: String = "OldRole",
    tone: PersonaTone = .precise,
    guardrail: String = "g",
    consistency: Double = 0.5,
    prompt: String = "OLD_PROMPT"
) -> Persona {
    var p = Persona(name: name, role: role, tone: tone, guardrail: guardrail, consistency: consistency)
    p.id = id
    p.userId = userId
    p.prompt = prompt
    p.createdAt = Date(timeIntervalSince1970: 0)
    p.updatedAt = Date(timeIntervalSince1970: 0)
    return p
}


final class EditPersonaModelTests: XCTestCase {

    //Edit with valid values and ensure the prompt is different from before
    @MainActor
    func test_edit_valid_changesPrompt() async {
        let original = makePersona(prompt: "OLD_PROMPT")
        let service = MockPersonaService()
        let prompt = MockPromptService_Success(value: "NEW_PROMPT")

        let model = EditPersonaModel(original: original, promptService: prompt, service: service)
        model.name = "NewName"
        model.role = "NewRole"

        let updated = await model.save()

        XCTAssertNotNil(updated, "Save should succeed")
        XCTAssertEqual(updated?.prompt, "NEW_PROMPT")
        XCTAssertNotEqual(updated?.prompt, original.prompt, "Prompt must be regenerated")
        XCTAssertTrue(service.didUpdate)
        XCTAssertEqual(service.lastUpdated?.name, "NewName")
        XCTAssertEqual(service.lastUpdated?.role, "NewRole")
    }

    //Delete and Confirm should get the persona deleted
    @MainActor
    func test_delete_confirm_deletesPersona() async {
        let original = makePersona()
        let service = MockPersonaService()
        let prompt = MockPromptService_Success(value: "ANY")

        let model = EditPersonaModel(original: original, promptService: prompt, service: service)

        let result = await model.delete(confirm: true)

        XCTAssertTrue(result, "Delete should report success when confirmed")
        XCTAssertTrue(service.didDelete, "deletePersona should be called on service")
        XCTAssertEqual(service.lastDeleted?.id, original.id)
    }

    //Delete and Cancel should not get the persona delted
    @MainActor
    func test_delete_cancel_doesNotDelete() async {
        let original = makePersona()
        let service = MockPersonaService()
        let prompt = MockPromptService_Success(value: "ANY")

        let model = EditPersonaModel(original: original, promptService: prompt, service: service)

        let result = await model.delete(confirm: false)

        XCTAssertFalse(result, "Delete should be skipped when not confirmed")
        XCTAssertFalse(service.didDelete, "Service must not be called when canceling")
    }

    //isSaving is toggled during save
    @MainActor
    func test_isSaving_togglesDuringSave() async {
        let original = makePersona()
        let service = MockPersonaService()
        let prompt = MockPromptService_Slow()

        let model = EditPersonaModel(original: original, promptService: prompt, service: service)

        //Start save concurrently on the same actor
        async let result: Persona? = model.save()

        //Yield to let save() flip isSaving = true before assertion
        await Task.yield()
        XCTAssertTrue(model.isSaving, "isSaving should be true while save is in-flight")

        //Wait for save to complete
        _ = await result
        XCTAssertFalse(model.isSaving, "isSaving should return to false after save completes")
    }
}
