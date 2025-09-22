//
//  AuthView.swift
//  Prosopo
//
//  Created by Akash Ramesh on 22/9/2025.
//

import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Prosopo").font(.largeTitle).bold()

            if let error = auth.error {
                Text(error).foregroundColor(.red).font(.footnote).multilineTextAlignment(.center)
            }

            SignInWithAppleButton(.signIn) { request in
                auth.handleSignInWithAppleRequest(request)
            } onCompletion: { result in
                Task { await auth.handleSignInWithAppleCompletion(result) }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
        }
        .padding()
    }
}
