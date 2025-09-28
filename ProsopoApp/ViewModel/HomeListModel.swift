//
//  HomeViewListModel.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 27/9/2025.
//

import Foundation

/**
 View model backing the home screen persona list.

 Mirrors the data flow of `HomeView` by observing personas from
 the service and exposing them as published state.
 This separation allows unit testing of list behavior without
 requiring a SwiftUI harness.
 */
@MainActor
final class HomeListModel: ObservableObject {
    /// Current list of personas observed from the service.
    @Published private(set) var personas: [Persona] = []

    private let service: PersonaServiceProtocol

    /// Initializes with a persona service, defaulting to production.
    init(service: PersonaServiceProtocol = PersonaService()) {
        self.service = service
    }

    /// Starts observing personas for a given user.
    ///
    /// - Parameter userId: Identifier of the user whose personas should be observed.
    func start(userId: String) {
        service.observePersonas(for: userId) { [weak self] items in
            Task { @MainActor in
                self?.personas = items
            }
        }
    }

    /// Stops observing persona updates.
    func stop() {
        service.stopObserving()
    }
}
