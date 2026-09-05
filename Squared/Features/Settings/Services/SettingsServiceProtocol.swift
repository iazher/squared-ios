//
//  SettingsServiceProtocol.swift
//  Squared
//

protocol SettingsServiceProtocol {
    func fetchPreferences() async throws -> UserPreferences
    func updatePreferences(_ preferences: UserPreferences) async throws -> UserPreferences
}
