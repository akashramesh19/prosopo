//
//  MenuView.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 22/9/2025.
//

import SwiftUI

struct DrawerMenuView: View {
    let email: String?
    let onSignOut: () -> Void
    let onAbout: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Menu").font(.title3.bold())
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 14)

            Divider().padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 6) {
                Button {
                    onSignOut()
                } label: {
                    Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                }
                .tint(.red)

                Button {
                    onAbout()
                } label: {
                    Label("About", systemImage: "info.circle")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                }
            }
            .padding(.horizontal, 16)

            Spacer()

            if let email {
                Text("Signed in as \(email)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
            }
        }
    }
}
