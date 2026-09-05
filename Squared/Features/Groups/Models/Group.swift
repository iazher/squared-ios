//
//  Group.swift
//  Squared
//

import Foundation

/// Owned by the Groups feature. Referenced directly (same module, no import needed)
/// by Expenses and Settlement wherever a group needs to be identified.
struct Group: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let memberIDs: [String]
    let createdAt: Date
}
