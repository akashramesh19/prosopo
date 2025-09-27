//
//  HomeViewListModel.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 27/9/2025.
//

import Foundation

/*
 The Home Page of the application. Contains the list of Personas of the user.
 This model mirrors the HomeView’s data flow (observePersonas + stopObserving),
 so that the unit test on the list behavior can be written without a UI harness.
*/

@MainActor
final class HomeListModel: ObservableObject {
    @Published private(set) var personas: [Persona] = []

    private let service: PersonaServiceProtocol

    init(service: PersonaServiceProtocol = PersonaService()) {
        self.service = service
    }

    func start(userId: String) {
        service.observePersonas(for: userId) { [weak self] items in
            Task { @MainActor in
                self?.personas = items
            }
        }
    }

    func stop() {
        service.stopObserving()
    }
}
