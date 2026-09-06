//
//  SignInViewModel.swift
//  Squared
//

import AuthenticationServices
import Foundation
import Observation

/// Calls `AuthServiceProtocol` directly; doesn't touch `AppState` itself.
@Observable
final class SignInViewModel {
    private(set) var isSigningIn = false
    private(set) var errorMessage: String?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func handleAuthorization(_ result: Result<ASAuthorization, Error>) async -> User? {
        isSigningIn = true
        errorMessage = nil
        defer { isSigningIn = false }

        switch result {
        case .failure(let error):
            // User-cancelled — not a real failure.
            if (error as? ASAuthorizationError)?.code == .canceled {
                return nil
            }

            #if DEBUG
            // Free dev teams can't provision Sign In with Apple; continue with mock data.
            return MockData.currentUser
            #else
            errorMessage = error.localizedDescription
            return nil
            #endif

        case .success(let authorization):
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let identityToken = String(data: tokenData, encoding: .utf8)
            else {
                errorMessage = "Unable to sign in with Apple."
                return nil
            }

            do {
                return try await authService.signInWithApple(
                    userIdentifier: credential.user,
                    identityToken: identityToken,
                    fullName: credential.fullName
                )
            } catch {
                errorMessage = error.localizedDescription
                return nil
            }
        }
    }
}
