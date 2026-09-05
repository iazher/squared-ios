//
//  SignInViewModel.swift
//  Squared
//

import Foundation
import Observation

/// Sign-in has no data to read from `AppState` (the user isn't signed in yet),
/// so this view model owns its own transient form state and calls `AuthServiceProtocol`
/// directly. It does not touch `AppState` itself — `RootView` reads the returned
/// `User` and drives the signedOut -> loading -> signedIn transition.
@Observable
final class SignInViewModel {
    var email: String = ""
    var password: String = ""
    private(set) var isSigningIn = false
    private(set) var errorMessage: String?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func signIn() async -> User? {
        isSigningIn = true
        errorMessage = nil
        defer { isSigningIn = false }

        do {
            return try await authService.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
