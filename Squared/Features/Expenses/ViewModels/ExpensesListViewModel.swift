//
//  ExpensesListViewModel.swift
//  Squared
//

import Observation

/// Reads this group's expenses from `AppState` rather than fetching independently.
@Observable
final class ExpensesListViewModel {
    private let appState: AppState
    let group: Group

    init(appState: AppState, group: Group) {
        self.appState = appState
        self.group = group
    }

    var expenses: [Expense] {
        appState.expenses.filter { $0.groupID == group.id }
    }
}
