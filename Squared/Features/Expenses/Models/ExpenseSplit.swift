//
//  ExpenseSplit.swift
//  Squared
//

import Foundation

/// How an expense's total was divided among its participants.
enum SplitMethod: String, Codable, Hashable {
    case equal
    case exact
    case percentage
}

/// One participant's share of a single `Expense`. Owned by the Expenses feature.
struct ExpenseSplit: Identifiable, Codable, Hashable {
    var id: String { userID }
    let userID: String
    let amount: Decimal
}
