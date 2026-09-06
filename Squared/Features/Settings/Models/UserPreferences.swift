//
//  UserPreferences.swift
//  Squared
//

/// Owned by the Settings feature; intentionally not part of `AppState`.
struct UserPreferences: Codable, Equatable {
    var preferredCurrencyCode: String
    var notificationsEnabled: Bool
}
