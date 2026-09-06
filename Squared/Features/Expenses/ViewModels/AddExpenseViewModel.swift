//
//  AddExpenseViewModel.swift
//  Squared
//

import Foundation
import Observation

/// Calls `ExpensesServiceProtocol` directly, then writes the result into `AppState`.
@Observable
final class AddExpenseViewModel {
    private let appState: AppState
    private let expensesService: ExpensesServiceProtocol
    let group: Group

    var title: String = ""
    var amountText: String = ""
    private(set) var isSaving = false
    var errorMessage: String?

    init(appState: AppState, group: Group, expensesService: ExpensesServiceProtocol) {
        self.appState = appState
        self.group = group
        self.expensesService = expensesService
    }

    func save() async -> Bool {
        guard let amount = Decimal(string: amountText), let currentUser = appState.currentUser else {
            errorMessage = "Enter a valid amount."
            return false
        }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            // No split editor yet — defaults to an equal split across the group.
            let splits = Self.equalSplits(of: amount, among: group.memberIDs)
            let expense = try await expensesService.createExpense(
                groupID: group.id,
                title: title,
                amount: amount,
                paidByUserID: currentUser.id,
                splitMethod: .equal,
                splits: splits
            )
            appState.upsert(expense: expense)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private static func equalSplits(of amount: Decimal, among memberIDs: [String]) -> [ExpenseSplit] {
        guard !memberIDs.isEmpty else { return [] }
        let share = (amount / Decimal(memberIDs.count)).rounded(to: 2)
        return memberIDs.map { ExpenseSplit(userID: $0, amount: share) }
    }
}

private extension Decimal {
    func rounded(to scale: Int) -> Decimal {
        var result = Decimal()
        var value = self
        NSDecimalRound(&result, &value, scale, .plain)
        return result
    }
}
