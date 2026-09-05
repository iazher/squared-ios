//
//  SettingsView.swift
//  Squared
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    let onSignedOut: () -> Void

    init(appState: AppState, authService: AuthServiceProtocol, settingsService: SettingsServiceProtocol, onSignedOut: @escaping () -> Void) {
        _viewModel = State(initialValue: SettingsViewModel(appState: appState, authService: authService, settingsService: settingsService))
        self.onSignedOut = onSignedOut
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    if let user = viewModel.currentUser {
                        Text(user.name)
                        Text(user.email)
                            .foregroundStyle(.secondary)
                    }
                }

                // Preferences are the one per-screen fetch in the app (they aren't
                // shared AppState data), so the fields are simply disabled until
                // loaded rather than showing a spinner, per the activity-indicator rule.
                Section("Preferences") {
                    if let preferences = viewModel.preferences {
                        Text("Currency: \(preferences.preferredCurrencyCode)")
                        Text("Notifications: \(preferences.notificationsEnabled ? "On" : "Off")")
                    }
                }
                .disabled(viewModel.isLoadingPreferences)

                Section {
                    // Spinner reflects this in-flight action, not a data load.
                    Button(role: .destructive) {
                        Task {
                            await viewModel.signOut()
                            if viewModel.currentUser == nil {
                                onSignedOut()
                            }
                        }
                    } label: {
                        if viewModel.isSigningOut {
                            ProgressView()
                        } else {
                            Text("Sign Out")
                        }
                    }
                    .disabled(viewModel.isSigningOut)
                }
            }
            .navigationTitle("Settings")
            .task {
                await viewModel.loadPreferences()
            }
        }
    }
}
