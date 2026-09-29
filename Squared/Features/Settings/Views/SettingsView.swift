//
//  SettingsView.swift
//  Squared
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    let onSignedOut: () -> Void

    init(appState: AppState, authService: AuthServiceProtocol, settingsService: SettingsServiceProtocol, usersService: UsersServiceProtocol, onSignedOut: @escaping () -> Void) {
        _viewModel = State(initialValue: SettingsViewModel(appState: appState, authService: authService, settingsService: settingsService, usersService: usersService))
        self.onSignedOut = onSignedOut
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    if let user = viewModel.currentUser {
                        Text("Signed in as \(user.name)")
                        Text(user.email)
                            .foregroundStyle(.secondary)
                    }
                }

                // One per-screen fetch exception — disabled until loaded, no spinner.
                Section("Preferences") {
                    if let preferences = viewModel.preferences {
                        Text("Currency: \(preferences.preferredCurrencyCode)")
                    }
                    Toggle("Notifications", isOn: Binding(
                        get: { viewModel.notificationsEnabled },
                        set: { viewModel.notificationsEnabled = $0 }
                    ))
                }
                .disabled(viewModel.isLoadingPreferences)

                Section {
                    TextField("Venmo username (optional)", text: Binding(
                        get: { viewModel.venmoUsernameText },
                        set: { viewModel.venmoUsernameText = $0 }
                    ))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    TextField("PayPal username (optional)", text: Binding(
                        get: { viewModel.paypalUsernameText },
                        set: { viewModel.paypalUsernameText = $0 }
                    ))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    if viewModel.hasUnsavedPaymentMethodChanges {
                        Button {
                            Task {
                                await viewModel.savePaymentMethods()
                            }
                        } label: {
                            if viewModel.isSavingPaymentMethods {
                                ProgressView()
                            } else {
                                Text("Save")
                            }
                        }
                        .disabled(viewModel.isSavingPaymentMethods)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Payment Methods")
                } footer: {
                    Text("Set these so Open Venmo / Open PayPal work in a settle-up whenever you're the one who owes money.")
                }

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
