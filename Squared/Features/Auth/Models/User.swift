//
//  User.swift
//  Squared
//

import Foundation

/// Owned by the Auth feature. Referenced directly (same module, no import needed)
/// by Groups, Expenses, and Settlement wherever a user needs to be identified.
struct User: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let email: String
    let avatarURL: URL?
}
