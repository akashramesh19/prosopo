//
//  HomeView.swift
//  Prosopo
//
//  Created by Akash Ramesh on 22/9/2025.
//

import SwiftUI

/*
 The Home Page of the application. Contains the list of Personas of the user.
 The UI design is preserved from the Prototype (header + ScrollView with tiles + floating add button).
*/

struct HomeView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var personas: [Persona] = []
    private let service = PersonaService()

    @State private var showDrawer = false
    @State private var showLogoutConfirm = false
    @State private var showAbout = false

    @State private var selectedPersona: Persona? = nil
    @State private var editingPersona: Persona? = nil

    @State private var personaToDelete: Persona? = nil
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            RightDrawer(isOpen: $showDrawer) {
                HomeMain(
                    personas: personas,
                    onTapView: { selectedPersona = $0 },
                    onTapEdit: { editingPersona = $0 },
                    onAskDelete: { p in
                        personaToDelete = p
                        showDeleteConfirm = true
                    }
                )
            } drawer: {
                DrawerMenuView(
                    email: nil,
                    onSignOut: {
                        withAnimation { showDrawer = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                            showLogoutConfirm = true
                        }
                    },
                    onAbout: {
                        withAnimation { showDrawer = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                            showAbout = true
                        }
                    }
                )
            }
            .navigationTitle("Prosopo").font(.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation { showDrawer.toggle() }
                    } label: {
                        Image(systemName: "line.horizontal.3")
                    }
                }
            }
            .confirmationDialog("Log out?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("Log out", role: .destructive) { auth.signOut() }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showAbout) { AboutView() }
            .onAppear {
                guard let uid = auth.userId else { return }
                service.observePersonas(for: uid) { items in
                    self.personas = items
                }
            }
            .onDisappear { service.stopObserving() }
            .navigationDestination(item: $selectedPersona) { p in
                PersonaView(persona: p)
            }
            .navigationDestination(item: $editingPersona) { p in
                EditPersonaView(persona: p)
            }
            .confirmationDialog(
                "Delete this persona?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible,
                presenting: personaToDelete
            ) { p in
                Button("Delete", role: .destructive) {
                    Task {
                        do {
                            try await service.deletePersona(p)
                        } catch {
                            print("Failed to delete persona: \(error)")
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: { p in
                Text("Are you sure you want to delete “\(p.name)”? This cannot be undone.")
            }
        }
    }
}
