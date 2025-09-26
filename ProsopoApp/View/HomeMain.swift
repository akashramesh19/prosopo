//
//  HomeMain.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 26/9/2025.
//

import SwiftUI

struct HomeMain: View {
    let personas: [Persona]
    let onTapView: (Persona) -> Void
    let onTapEdit: (Persona) -> Void
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
