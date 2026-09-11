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
}
