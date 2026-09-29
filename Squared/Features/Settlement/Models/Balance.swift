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

    /// Below this, an amount is residue (e.g. from a manually-edited payment
    /// that didn't exactly match a debt) rather than a real outstanding debt —
    /// shared by anywhere that needs to decide whether a balance still counts.
    static let significantAmountThreshold: Decimal = 0.01

    var isSignificant: Bool {
        abs(amount) >= Self.significantAmountThreshold
    }
}
