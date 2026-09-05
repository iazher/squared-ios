//
//  AuthService.swift
//  Squared
//

import Foundation

/// Concrete `AuthServiceProtocol` implementation. Depends on `APIClient` via
/// constructor injection so it can run against either `URLSessionAPIClient`
/// or `MockAPIClient` without changing a single line here.
final class AuthService: AuthServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func signIn(email: String, password: String) async throws -> User {
        let requestBody = SignInRequest(email: email, password: password)
        let body = try JSONEncoder().encode(requestBody)
        let endpoint = Endpoint(path: "/auth/sign-in", method: .post, body: body)
        return try await apiClient.request(endpoint)
    }

    func signOut() async throws {
        let endpoint = Endpoint(path: "/auth/sign-out", method: .post)
        let _: EmptyResponse = try await apiClient.request(endpoint)
    }

    func fetchCurrentUser() async throws -> User {
        let endpoint = Endpoint(path: "/auth/me")
        return try await apiClient.request(endpoint)
    }
}

private struct SignInRequest: Encodable {
    let email: String
    let password: String
}
