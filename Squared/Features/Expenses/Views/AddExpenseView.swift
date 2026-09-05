//
//  AddExpenseView.swift
//  Squared
//

import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddExpenseViewModel

    init(appState: AppState, group: Group, expensesService: ExpensesServiceProtocol) {
        _viewModel = State(initialValue: AddExpenseViewModel(appState: appState, group: group, expensesService: expensesService))
    }

    var body: some View {
        Form {
            TextField("Title", text: $viewModel.title)
            TextField("Amount", text: $viewModel.amountText)
                .keyboardType(.decimalPad)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle("Add Expense")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                // Spinner reflects this in-flight save action — not a data load.
                Button {
                    Task {
                        if await viewModel.save() {
                            dismiss()
                        }
                    }
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
                .disabled(viewModel.isSaving)
            }
        }
    }
}
