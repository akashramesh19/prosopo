//
//  HomeMain.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 26/9/2025.
//

import SwiftUI

/// Main home screen layout displaying the list of personas and navigation to add new ones.
struct HomeMain: View {
    let personas: [Persona]
    let onTapView: (Persona) -> Void
    let onTapEdit: (Persona) -> Void
    let onAskDelete: (Persona) -> Void

    @State private var goAdd = false
    @State private var goSuggest = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            PersonasList(
                personas: personas,
                onTapView: onTapView,
                onTapEdit: onTapEdit,
                onAskDelete: onAskDelete
            )
            .padding(.bottom, 0)

            VStack {
                Spacer()
                Menu {
                    Button("Add Persona") { goAdd = true }
                    Button("Suggest Persona from Description") { goSuggest = true }
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

            NavigationLink("", destination: AddPersonaView(), isActive: $goAdd)
                .hidden()
            NavigationLink("", destination: SuggestPersonaView(), isActive: $goSuggest)
                .hidden()
        }
    }
}
