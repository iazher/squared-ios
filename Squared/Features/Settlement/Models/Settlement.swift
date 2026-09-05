//
//  Settlement.swift
//  Squared
//

import Foundation

/// A recorded settle-up payment between two users. Owned by the Settlement feature.
struct Settlement: Identifiable, Codable, Hashable {
    let id: String
    let groupID: String
    let fromUserID: String
    let toUserID: String
    let amount: Decimal
    let settledAt: Date
}
