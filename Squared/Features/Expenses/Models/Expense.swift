//
//  Expense.swift
//  Squared
//

import Foundation

/// Owned by the Expenses feature. Referenced directly (same module, no import
/// needed) by Settlement when computing balances.
struct Expense: Identifiable, Codable, Hashable {
    let id: String
    let groupID: String
    let title: String
    let amount: Decimal
    let paidByUserID: String
    let splitBetweenUserIDs: [String]
    let createdAt: Date
}
