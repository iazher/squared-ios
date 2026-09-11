//
//  UsersServiceProtocol.swift
//  Squared
//

protocol UsersServiceProtocol {
    func fetchUsers() async throws -> [User]
}
