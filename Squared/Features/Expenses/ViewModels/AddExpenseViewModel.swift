//
//  AddExpenseViewModel.swift
//  Squared
//

import Foundation
import Observation

/// Creating an expense is a mutation, not a read of shared state, so this view
/// model calls `ExpensesServiceProtocol` directly. On success it writes the new
/// expense back into `AppState` so every screen reading `expenses` stays in sync.
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
            let expense = try await expensesService.createExpense(
                groupID: group.id,
                title: title,
                amount: amount,
                paidByUserID: currentUser.id,
                splitBetweenUserIDs: group.memberIDs
            )
            appState.upsert(expense: expense)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
