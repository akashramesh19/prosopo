//
//  AuthViewModel.swift
//  Prosopo
//
//  Created by Akash Ramesh on 22/9/2025.
//

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var error: String?
    @Published var isAuthenticated: Bool = Auth.auth().currentUser != nil

    var userId: String? { Auth.auth().currentUser?.uid }

    private var currentNonce: String?

    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = (user != nil)
        }
    }

    // MARK: - Apple Sign In (SwiftUI button hooks)

    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .failure(let err):
            self.error = err.localizedDescription
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else {
                self.error = "Missing AppleIDCredential"
                return
            }
            guard let idTokenData = credential.identityToken,
                  let idTokenString = String(data: idTokenData, encoding: .utf8) else {
                self.error = "Unable to read identity token"
                return
            }
            guard let nonce = currentNonce else {
                self.error = "Invalid state: missing login request"
                return
            }

            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                              idToken: idTokenString,
                                                              rawNonce: nonce)
            do {
                _ = try await signIn(with: firebaseCredential)

                if let name = credential.fullName, !name.description.isEmpty {
                    let formatter = PersonNameComponentsFormatter()
                    let display = formatter.string(from: name)
                    try await updateDisplayName(display)
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
    }

    func signOut() {
        do { try Auth.auth().signOut() } catch { self.error = error.localizedDescription }
    }

    // MARK: - Helpers

    private func signIn(with credential: AuthCredential) async throws -> AuthDataResult {
        try await withCheckedThrowingContinuation { cont in
            Auth.auth().signIn(with: credential) { result, error in
                if let error { cont.resume(throwing: error) }
                else if let result { cont.resume(returning: result) }
                else { cont.resume(throwing: NSError(domain: "Auth", code: -1)) }
            }
        }
    }

    private func updateDisplayName(_ name: String) async throws {
        guard let user = Auth.auth().currentUser else { return }
        try await withCheckedThrowingContinuation { cont in
            let change = user.createProfileChangeRequest()
            change.displayName = name
            change.commitChanges { error in
                if let error { cont.resume(throwing: error) }
                else { cont.resume(returning: ()) }
            }
        }
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var randoms = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
            if status != errSecSuccess { fatalError("Unable to generate nonce.") }

            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
}
