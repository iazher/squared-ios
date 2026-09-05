//
//  ExpensesListViewModel.swift
//  Squared
//

import Observation

/// Reads shared expense data from `AppState` (already populated during the
/// post-sign-in initial fetch) filtered down to a single group, rather than
/// fetching that group's expenses independently.
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
