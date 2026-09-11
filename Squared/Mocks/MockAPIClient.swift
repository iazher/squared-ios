//
//  MockAPIClient.swift
//  Squared
//

import Foundation

/// Stands in for `URLSessionAPIClient` before the real backend exists.
final class MockAPIClient: APIClient {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let sample: Any

        switch (endpoint.method, endpoint.path) {
        case (.get, "/auth/me"), (.post, "/auth/sign-in"):
            sample = MockData.currentUser
        case (.get, "/users"):
            sample = MockData.users
        case (.post, "/auth/sign-out"):
            sample = EmptyResponse()
        case (.get, "/groups"):
            sample = MockData.groups
        case (.post, "/groups"):
            if let body = endpoint.body,
               let payload = try? JSONDecoder().decode(GroupCreationPayload.self, from: body) {
                sample = Group(id: UUID().uuidString, name: payload.name, memberIDs: payload.memberIDs, createdAt: Date())
            } else {
                sample = MockData.groups[0]
            }
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
        case let (.post, path) where path.hasPrefix("/groups/") && path.hasSuffix("/members"):
            if let body = endpoint.body,
               let payload = try? JSONDecoder().decode(AddMemberPayload.self, from: body) {
                sample = User(id: UUID().uuidString, name: payload.name, email: "", avatarURL: nil)
            } else {
                throw NetworkError.invalidResponse
            }
        default:
            throw NetworkError.invalidResponse
        }

        guard let typed = sample as? T else {
            throw NetworkError.decodingFailed
        }
        return typed
    }
}

private struct GroupCreationPayload: Decodable {
    let name: String
    let memberIDs: [String]
}

private struct AddMemberPayload: Decodable {
    let name: String
}
