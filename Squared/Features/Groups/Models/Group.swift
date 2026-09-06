//
//  Group.swift
//  Squared
//

import Foundation

/// Owned by the Groups feature.
struct Group: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let memberIDs: [String]
    let createdAt: Date
}
