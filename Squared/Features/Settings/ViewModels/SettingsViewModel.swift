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
    private let usersService: UsersServiceProtocol

    private(set) var preferences: UserPreferences?
    private(set) var isLoadingPreferences = false
    private(set) var isSigningOut = false
    private(set) var isSavingPaymentMethods = false
    var errorMessage: String?

    /// Local-only for now — flips immediately on tap, no backend round-trip yet.
    var notificationsEnabled = true

    var venmoUsernameText: String
    var paypalUsernameText: String
    /// Snapshot of what's persisted — Save's visibility tracks this diff, not
    /// keyboard/focus state, so dismissing the keyboard can't strand an edit.
    private var savedVenmoUsernameText: String
    private var savedPaypalUsernameText: String

    var hasUnsavedPaymentMethodChanges: Bool {
        venmoUsernameText != savedVenmoUsernameText || paypalUsernameText != savedPaypalUsernameText
    }

    var currentUser: User? {
        appState.currentUser
    }

    init(appState: AppState, authService: AuthServiceProtocol, settingsService: SettingsServiceProtocol, usersService: UsersServiceProtocol) {
        self.appState = appState
        self.authService = authService
        self.settingsService = settingsService
        self.usersService = usersService
        let venmo = appState.currentUser?.venmoUsername ?? ""
        let paypal = appState.currentUser?.paypalUsername ?? ""
        venmoUsernameText = venmo
        paypalUsernameText = paypal
        savedVenmoUsernameText = venmo
        savedPaypalUsernameText = paypal
    }

    func savePaymentMethods() async {
        guard let currentUser else { return }
        isSavingPaymentMethods = true
        errorMessage = nil
        defer { isSavingPaymentMethods = false }

        let trimmedVenmo = venmoUsernameText.trimmingCharacters(in: .whitespaces)
        let trimmedPaypal = paypalUsernameText.trimmingCharacters(in: .whitespaces)
        let updated = User(
            id: currentUser.id,
            name: currentUser.name,
            email: currentUser.email,
            avatarURL: currentUser.avatarURL,
            venmoUsername: trimmedVenmo.isEmpty ? nil : trimmedVenmo,
            paypalUsername: trimmedPaypal.isEmpty ? nil : trimmedPaypal
        )

        do {
            let saved = try await usersService.updateProfile(updated)
            appState.upsert(user: saved)
            venmoUsernameText = trimmedVenmo
            paypalUsernameText = trimmedPaypal
            savedVenmoUsernameText = trimmedVenmo
            savedPaypalUsernameText = trimmedPaypal
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadPreferences() async {
        isLoadingPreferences = true
        errorMessage = nil
        defer { isLoadingPreferences = false }

        do {
            let fetched = try await settingsService.fetchPreferences()
            preferences = fetched
            notificationsEnabled = fetched.notificationsEnabled
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
