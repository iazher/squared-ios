//
//  Expense.swift
//  Squared
//

import Foundation

/// Owned by the Expenses feature.
struct Expense: Identifiable, Codable, Hashable {
    let id: String
    let groupID: String
    let title: String
    let amount: Decimal
    let paidByUserID: String
    let splitMethod: SplitMethod
    let splits: [ExpenseSplit]
    let createdAt: Date
}
