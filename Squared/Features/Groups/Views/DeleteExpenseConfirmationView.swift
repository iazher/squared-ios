//
//  DeleteExpenseConfirmationView.swift
//  Squared
//

import SwiftUI

/// Presented when swiping to delete an expense, before it's actually removed —
/// same sheet style as `SettleUpOptionsView`, since deleting changes everyone's
/// balances and shouldn't happen from a single accidental tap.
struct DeleteExpenseConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    let expenseTitle: String
    let onDelete: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Delete \"\(expenseTitle)\"?")
                        .foregroundStyle(.white)
                    Text("This will change everyone's balances.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Button(role: .destructive) {
                    onDelete()
                    dismiss()
                } label: {
                    Text("Delete Expense")
                }
            }
            .navigationTitle("Delete Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
