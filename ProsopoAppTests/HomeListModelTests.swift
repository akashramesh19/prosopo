//
//  HomeListModelTests.swift
//  ProsopoAppTests
//
//  Created by Akash Ramesh on 27/9/2025.
//

import XCTest
@testable import ProsopoApp

final class MockPersonaService_List: PersonaServiceProtocol {
    private var onChange: (([Persona]) -> Void)?

    private(set) var lastUserId: String?

    func observePersonas(for userId: String, onChange: @escaping ([Persona]) -> Void) {
        lastUserId = userId
        self.onChange = onChange
    }

    func stopObserving() {
        onChange = nil
    }

    //Helpers to drive the stream in tests
    func push(_ items: [Persona]) {
        onChange?(items)
    }

    //Unused by these tests but required by protocol
    func addPersona(_ persona: Persona, userId: String) async throws {}
    func updatePersona(_ persona: Persona) async throws {}
    func deletePersona(_ persona: Persona) async throws {}
    func existsPersonaNamed(_ name: String, userId: String) async throws -> Bool { false }
}

private func makePersona(
    id: String,
    userId: String = "uid-1",
    name: String,
    updatedAt: Date
) -> Persona {
    var p = Persona(
        name: name,
        role: "Role",
        tone: .precise,
        guardrail: "g",
        consistency: 0.5
    )
    p.id = id
    p.userId = userId
    p.prompt = "PROMPT"
    p.createdAt = Date(timeIntervalSince1970: 0)
    p.updatedAt = updatedAt
    return p
}

final class HomeListModelTests: XCTestCase {

    @MainActor
    func test_viewAllPersonas_valid() async {
        let service = MockPersonaService_List()
        let model = HomeListModel(service: service)

        model.start(userId: "uid-1")

        let now = Date()
        let p1 = makePersona(id: "p1", name: "Alpha",   updatedAt: now.addingTimeInterval(-120))
        let p2 = makePersona(id: "p2", name: "Bravo",   updatedAt: now.addingTimeInterval(-60))
        let p3 = makePersona(id: "p3", name: "Charlie", updatedAt: now)

        service.push([p1, p2, p3])
        await Task.yield()

        XCTAssertEqual(model.personas.count, 3)
        XCTAssertEqual(model.personas.compactMap(\.id), ["p1", "p2", "p3"])
    }

    @MainActor
    func test_viewPersonas_descendingOrder_afterEdit() async {
        let service = MockPersonaService_List()
        let model = HomeListModel(service: service)

        model.start(userId: "uid-1")

        let t0 = Date()
        var alpha  = makePersona(id: "p1", name: "Alpha",   updatedAt: t0.addingTimeInterval(-120))
        let bravo  = makePersona(id: "p2", name: "Bravo",   updatedAt: t0.addingTimeInterval(-60))
        let charlie = makePersona(id: "p3", name: "Charlie", updatedAt: t0)

        service.push([alpha, bravo, charlie])
        await Task.yield()

        XCTAssertEqual(model.personas.compactMap(\.id), ["p1", "p2", "p3"])

        //Simulating edit by changing updated at
        alpha.updatedAt = t0.addingTimeInterval(+30)

        //Service emits already sorted by updatedAt DESC
        service.push([alpha, charlie, bravo])
        await Task.yield()

        XCTAssertEqual(model.personas.compactMap(\.id), ["p1", "p3", "p2"])
        XCTAssertTrue(model.personas[0].updatedAt > model.personas[1].updatedAt)
        XCTAssertTrue(model.personas[1].updatedAt > model.personas[2].updatedAt)
    }
    
    @MainActor
    func test_stopObserving_freezesList() async {
        let service = MockPersonaService_List()
        let model = HomeListModel(service: service)

        model.start(userId: "uid-1")

        //Initial list
        let now = Date()
        let p1 = makePersona(id: "p1", name: "Alpha",   updatedAt: now)
        let p2 = makePersona(id: "p2", name: "Bravo",   updatedAt: now)
        service.push([p1, p2])
        await Task.yield()

        XCTAssertEqual(model.personas.compactMap(\.id), ["p1", "p2"])

        //Stop observing to test if a push is taken in
        model.stop()

        let p3 = makePersona(id: "p3", name: "Charlie", updatedAt: now)
        service.push([p3])
        await Task.yield()

        //Still the old list
        XCTAssertEqual(model.personas.compactMap(\.id), ["p1", "p2"])
    }
}
