//
//  HomeView.swift
//  Prosopo
//
//  Created by Akash Ramesh on 22/9/2025.
//

import SwiftUI

/*
 The Home Page of the application. Contains the list of Personas of the user.
 The UI design is preserved (header + ScrollView with tiles + floating add button).
 Only the data flow has been aligned to the Notes-style observe/add/delete pattern.
*/

struct HomeView: View {
    @EnvironmentObject var auth: AuthViewModel

    //Setting app state with the list of personas for the session
    @State private var personas: [Persona] = []

    //Persona service initialised to manage the crud operations to firebase database
    private let service = PersonaService()

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Personas")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                        .padding(.top, 16)

                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(personas) { persona in
                                NavigationLink {
                                    PersonaView(persona: persona)
                                } label: {
                                    Text(persona.name)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding(10)
                                        .background(Color.accentColor)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 8)
                            }
                        }
                        .padding(.top, 8)
                    }
                }

                //Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink {
                            AddPersonaView()
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Prosopo").font(.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { print("Menu tapped") }) {
                        Image(systemName: "line.horizontal.3")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") { auth.signOut() }
                }
            }
            .onAppear {
                guard let uid = auth.userId else { return }
                service.observePersonas(for: uid) { items in
                    self.personas = items
                }
            }
            .onDisappear {
                service.stopObserving()
            }
        }
    }
}

#Preview {
    HomeView().environmentObject(AuthViewModel())
}
