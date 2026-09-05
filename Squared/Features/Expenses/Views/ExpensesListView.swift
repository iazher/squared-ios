//
//  ExpensesListView.swift
//  Squared
//

import SwiftUI

struct ExpensesListView: View {
    @State private var viewModel: ExpensesListViewModel
    private let appState: AppState
    private let expensesService: ExpensesServiceProtocol

    init(appState: AppState, group: Group, expensesService: ExpensesServiceProtocol) {
        _viewModel = State(initialValue: ExpensesListViewModel(appState: appState, group: group))
        self.appState = appState
        self.expensesService = expensesService
    }

    var body: some View {
        // Reads straight from AppState — no per-screen fetch, no loading spinner.
        List(viewModel.expenses) { expense in
            VStack(alignment: .leading) {
                Text(expense.title)
                Text(expense.amount.formatted(currencyCode: "USD"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Expenses")
        .toolbar {
            NavigationLink("Add") {
                AddExpenseView(appState: appState, group: viewModel.group, expensesService: expensesService)
            }
        }
        .overlay {
            if viewModel.expenses.isEmpty {
                ContentUnavailableView("No Expenses Yet", systemImage: "creditcard")
            }
        }
    }
}
