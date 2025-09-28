//
//  AuthView.swift
//  Prosopo
//
//  Created by Akash Ramesh on 22/9/2025.
//

import SwiftUI
import AuthenticationServices

/**
 A view providing authentication options at application launch.

 Sign-in options are presented for Apple and Google accounts.
 Errors from the authentication process are displayed inline.
 */
struct AuthView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var isGoogleBusy = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Prosopo")
                .font(.largeTitle).bold()

            if let error = auth.error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Apple sign-in button
            SignInWithAppleButton(.signIn) { request in
                auth.handleSignInWithAppleRequest(request)
            } onCompletion: { result in
                Task { await auth.handleSignInWithAppleCompletion(result) }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)

            // Google sign-in button
            GoogleWhiteTextButton(busy: isGoogleBusy) {
                guard let vc = rootViewController() else {
                    auth.error = "Unable to find a presenting view controller."
                    return
                }
                isGoogleBusy = true
                Task {
                    defer { isGoogleBusy = false }
                    await auth.signInWithGoogle(presenting: vc)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }

    /// Retrieves the root view controller for presenting authentication flows.
    private func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController
    }
}

/// Custom Google button styled as a white pill with centered logo and text.
private struct GoogleWhiteTextButton: View {
    var busy: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if busy {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    HStack(spacing: 10) {
                        Image("google_g") // Asset stored in Assets.xcassets
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)

                        Text("Sign in with Google")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                    }
                    .padding(.horizontal, 12)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 48) // Matches Apple button proportions
        }
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.separator), lineWidth: 1) // Subtle border
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
        .accessibilityLabel("Sign in with Google")
        .accessibilityAddTraits(.isButton)
        .contentShape(RoundedRectangle(cornerRadius: 10))
    }
}
