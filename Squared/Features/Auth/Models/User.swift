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
    let venmoUsername: String?
    let paypalUsername: String?

    init(id: String, name: String, email: String, avatarURL: URL?, venmoUsername: String? = nil, paypalUsername: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.venmoUsername = venmoUsername
        self.paypalUsername = paypalUsername
    }
}
