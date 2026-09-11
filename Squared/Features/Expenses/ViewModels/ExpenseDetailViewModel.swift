//
//  ExpenseDetailViewModel.swift
//  Squared
//

import Foundation
import Observation

/// Reads a single expense's detail from `AppState`. View-only — no editing yet.
@Observable
final class ExpenseDetailViewModel {
    private let appState: AppState
    let expense: Expense

    struct ParticipantShare: Identifiable {
        let id: String
        let displayName: String
        let initials: String
        let amount: Decimal
        /// Non-nil only when the expense's split method is `.percentage`.
        let percentage: Decimal?
    }

    init(appState: AppState, expense: Expense) {
        self.appState = appState
        self.expense = expense
    }

    var title: String {
        currentExpense.title
    }

    var amountText: String {
        currentExpense.amount.formatted(currencyCode: "USD")
    }

    var payerName: String {
        displayName(for: currentExpense.paidByUserID)
    }

    var splitMethodLabel: String {
        switch currentExpense.splitMethod {
        case .equal: return "Equal"
        case .exact: return "Custom"
        case .percentage: return "Percentage"
        }
    }

    var showsPercentage: Bool {
        currentExpense.splitMethod == .percentage
    }

    var participantShares: [ParticipantShare] {
        let total = currentExpense.amount
        return currentExpense.splits.map { split in
            let percentage: Decimal? = (currentExpense.splitMethod == .percentage && total != 0)
                ? (split.amount / total * 100).rounded(to: 2)
                : nil
            return ParticipantShare(
                id: split.userID,
                displayName: displayName(for: split.userID),
                initials: MemberAvatar.initials(from: actualName(for: split.userID)),
                amount: split.amount,
                percentage: percentage
            )
        }
    }

    /// `expense` is captured at push time; read the live copy in case it's ever edited.
    private var currentExpense: Expense {
        appState.expenses.first(where: { $0.id == expense.id }) ?? expense
    }

    private func displayName(for userID: String) -> String {
        if userID == appState.currentUser?.id {
            return "You"
        }
        return actualName(for: userID)
    }

    private func actualName(for userID: String) -> String {
        appState.users.first(where: { $0.id == userID })?.name ?? userID
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
