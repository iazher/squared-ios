//
//  AuthService.swift
//  Squared
//

import Foundation

/// Concrete `AuthServiceProtocol` implementation.
final class AuthService: AuthServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func signInWithApple(userIdentifier: String, identityToken: String, fullName: PersonNameComponents?) async throws -> User {
        let requestBody = SignInWithAppleRequest(
            userIdentifier: userIdentifier,
            identityToken: identityToken,
            givenName: fullName?.givenName,
            familyName: fullName?.familyName
        )
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

private struct SignInWithAppleRequest: Encodable {
    let userIdentifier: String
    let identityToken: String
    let givenName: String?
    let familyName: String?
}
