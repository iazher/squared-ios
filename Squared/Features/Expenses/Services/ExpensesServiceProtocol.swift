//
//  ExpensesServiceProtocol.swift
//  Squared
//

import Foundation

protocol ExpensesServiceProtocol {
    func fetchExpenses() async throws -> [Expense]
    func createExpense(groupID: String, title: String, amount: Decimal, paidByUserID: String, splitMethod: SplitMethod, splits: [ExpenseSplit]) async throws -> Expense
}
