//
//  HomeMain.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 26/9/2025.
//

import SwiftUI

/// Main home screen layout displaying the list of personas and navigation to add new ones.
struct HomeMain: View {
    /// Personas to display.
    let personas: [Persona]
    /// Action triggered when a persona is tapped for viewing.
    let onTapView: (Persona) -> Void
    /// Action triggered when a persona is tapped for editing.
    let onTapEdit: (Persona) -> Void
    /// Action triggered when a persona is requested for deletion.
    let onAskDelete: (Persona) -> Void

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Your Personas")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                    .padding(.top, 16)

                PersonasList(
                    personas: personas,
                    onTapView: onTapView,
                    onTapEdit: onTapEdit,
                    onAskDelete: onAskDelete
                )
            }

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
    }
}
