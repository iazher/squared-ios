//
//  User.swift
//  Squared
//

import Foundation

/// Owned by the Auth feature.
struct User: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let email: String
    let avatarURL: URL?
}
