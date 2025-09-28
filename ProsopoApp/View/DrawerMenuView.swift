//
//  MenuView.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 22/9/2025.
//

import SwiftUI

/// Drawer menu view providing logout and about options, with optional user email shown at the bottom.
struct DrawerMenuView: View {
    /// Email of the currently signed-in user, displayed in the footer if available.
    let email: String?
    /// Action executed when logout is selected.
    let onSignOut: () -> Void
    /// Action executed when about is selected.
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
