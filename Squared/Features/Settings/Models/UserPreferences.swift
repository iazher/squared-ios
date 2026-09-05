//
//  UserPreferences.swift
//  Squared
//

/// Owned by the Settings feature. Not part of `AppState` — unlike currentUser,
/// groups, expenses, and balances, preferences aren't read by other features,
/// so there's no cross-feature reason to centralize them.
struct UserPreferences: Codable, Equatable {
    var preferredCurrencyCode: String
    var notificationsEnabled: Bool
}
