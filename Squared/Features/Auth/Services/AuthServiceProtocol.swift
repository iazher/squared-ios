//
//  AuthServiceProtocol.swift
//  Squared
//

import Foundation

protocol AuthServiceProtocol {
    func signInWithApple(userIdentifier: String, identityToken: String, fullName: PersonNameComponents?) async throws -> User
    func signOut() async throws
    func fetchCurrentUser() async throws -> User
}
