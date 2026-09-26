//
//  UsersServiceProtocol.swift
//  Squared
//

protocol UsersServiceProtocol {
    func fetchUsers() async throws -> [User]
    func updateProfile(_ user: User) async throws -> User
}
