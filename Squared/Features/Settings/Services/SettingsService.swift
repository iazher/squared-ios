//
//  SettingsService.swift
//  Squared
//

import Foundation

final class SettingsService: SettingsServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchPreferences() async throws -> UserPreferences {
        let endpoint = Endpoint(path: "/settings/preferences")
        return try await apiClient.request(endpoint)
    }

    func updatePreferences(_ preferences: UserPreferences) async throws -> UserPreferences {
        let body = try JSONEncoder().encode(preferences)
        let endpoint = Endpoint(path: "/settings/preferences", method: .put, body: body)
        return try await apiClient.request(endpoint)
    }
}
