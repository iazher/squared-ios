//
//  SettingsViewModel.swift
//  Squared
//

import Foundation
import Observation

/// Preferences are fetched per-screen (not AppState data); sign-out resets AppState.
@Observable
final class SettingsViewModel {
    private let appState: AppState
    private let authService: AuthServiceProtocol
    private let settingsService: SettingsServiceProtocol

    private(set) var preferences: UserPreferences?
    private(set) var isLoadingPreferences = false
    private(set) var isSigningOut = false
    var errorMessage: String?

    var currentUser: User? {
        appState.currentUser
    }

    init(appState: AppState, authService: AuthServiceProtocol, settingsService: SettingsServiceProtocol) {
        self.appState = appState
        self.authService = authService
        self.settingsService = settingsService
    }

    func loadPreferences() async {
        isLoadingPreferences = true
        errorMessage = nil
        defer { isLoadingPreferences = false }

        do {
            preferences = try await settingsService.fetchPreferences()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        isSigningOut = true
        errorMessage = nil
        defer { isSigningOut = false }

        do {
            try await authService.signOut()
            appState.reset()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
