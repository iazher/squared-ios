//
//  Balance.swift
//  Squared
//

import Foundation

/// A computed net balance between two users within a group. Owned by the Settlement feature.
struct Balance: Identifiable, Codable, Hashable {
    var id: String { "\(groupID)-\(fromUserID)-\(toUserID)" }
    let groupID: String
    let fromUserID: String
    let toUserID: String
    let amount: Decimal
}
