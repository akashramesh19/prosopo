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
import FirebaseCore
import GoogleSignIn

/**
 View model managing user authentication state and flows.

 Supports sign-in with Apple and Google, using Firebase as the backend.
 Apple authentication setup requires an enrolled Apple Developer account,
 while Google authentication has been tested and verified.
 */
@MainActor
final class AuthViewModel: ObservableObject {
    @Published var error: String?
    @Published var isAuthenticated: Bool = Auth.auth().currentUser != nil

    /// Current authenticated user ID.
    var userId: String? { Auth.auth().currentUser?.uid }
    private var currentNonce: String?

    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = (user != nil)
        }
    }

    /// Prepares the Apple sign-in request with nonce and requested scopes.
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    /// Handles the completion of Apple sign-in and authenticates with Firebase.
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

            let firebaseCredential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: credential.fullName
            )

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

    /// Signs in with Google using FirebaseAuth.
    func signInWithGoogle(presenting viewController: UIViewController) async {
        do {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                self.error = "Missing Google Client ID"
                return
            }
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
            let user = result.user

            guard let idToken = user.idToken?.tokenString else {
                self.error = "Missing Google ID token"
                return
            }

            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )

            _ = try await signIn(with: credential)
        } catch {
            self.error = error.localizedDescription
        }
    }

    /// Signs the current user out.
    func signOut() {
        do { try Auth.auth().signOut() }
        catch { self.error = error.localizedDescription }
    }

    /// Wraps Firebase sign-in for async/await.
    private func signIn(with credential: AuthCredential) async throws -> AuthDataResult {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<AuthDataResult, Error>) in
            Auth.auth().signIn(with: credential) { result, error in
                if let error {
                    cont.resume(throwing: error)
                } else if let result {
                    cont.resume(returning: result)
                } else {
                    cont.resume(throwing: NSError(domain: "Auth", code: -1))
                }
            }
        }
    }

    /// Updates Firebase user profile with a display name.
    private func updateDisplayName(_ name: String) async throws {
        guard let user = Auth.auth().currentUser else { return }
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            let change = user.createProfileChangeRequest()
            change.displayName = name
            change.commitChanges { error in
                if let error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume(returning: ())
                }
            }
        }
    }

    /// Hashes a string with SHA-256.
    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }

    /// Generates a random nonce string for Apple sign-in.
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var randoms = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
            if status != errSecSuccess { fatalError("Unable to generate nonce.") }

            randoms.forEach { random in
                if remainingLength == 0 { return }
                let idx = Int(random) % charset.count
                result.append(charset[idx])
                remainingLength -= 1
            }
        }
        return result
    }
}
