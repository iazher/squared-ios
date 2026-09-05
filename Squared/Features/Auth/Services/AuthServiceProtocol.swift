//
//  AuthServiceProtocol.swift
//  Squared
//

protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws -> User
    func signOut() async throws
    func fetchCurrentUser() async throws -> User
}
