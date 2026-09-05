//
//  MockAPIClient.swift
//  Squared
//

import Foundation

/// Stands in for `URLSessionAPIClient` before the real backend exists. Routes
/// on path + method the same way `URLSessionAPIClient` would, but returns
/// hardcoded sample data instead of making a network call — so the app is
/// buildable and testable end-to-end from day one.
final class MockAPIClient: APIClient {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let sample: Any

        switch (endpoint.method, endpoint.path) {
        case (.get, "/auth/me"), (.post, "/auth/sign-in"):
            sample = MockData.currentUser
        case (.post, "/auth/sign-out"):
            sample = EmptyResponse()
        case (.get, "/groups"):
            sample = MockData.groups
        case (.post, "/groups"):
            sample = MockData.groups[0]
        case (.get, "/expenses"):
            sample = MockData.expenses
        case (.post, "/expenses"):
            sample = MockData.expenses[0]
        case (.get, "/settlement/balances"):
            sample = MockData.balances
        case (.post, "/settlement/settlements"):
            sample = MockData.settlement
        case (.get, "/settings/preferences"), (.put, "/settings/preferences"):
            sample = MockData.preferences
        default:
            throw NetworkError.invalidResponse
        }

        guard let typed = sample as? T else {
            throw NetworkError.decodingFailed
        }
        return typed
    }
}
