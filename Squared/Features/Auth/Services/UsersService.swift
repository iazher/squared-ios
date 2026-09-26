//
//  UsersService.swift
//  Squared
//

import Foundation

final class UsersService: UsersServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchUsers() async throws -> [User] {
        let endpoint = Endpoint(path: "/users")
        return try await apiClient.request(endpoint)
    }

    func updateProfile(_ user: User) async throws -> User {
        let body = try JSONEncoder().encode(user)
        let endpoint = Endpoint(path: "/users/me", method: .put, body: body)
        return try await apiClient.request(endpoint)
    }
}
