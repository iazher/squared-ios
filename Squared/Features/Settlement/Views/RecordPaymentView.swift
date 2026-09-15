//
//  RecordPaymentView.swift
//  Squared
//

import SwiftUI

/// Presented when tapping a settlement edge; from/to/amount come from that edge.
struct RecordPaymentView: View {
    @Environment(\.dismiss) private var dismiss
    private let viewModel: SettlementViewModel
    private let fromDisplayName: String
    private let toDisplayName: String
    private let fromUserID: String
    private let toUserID: String
    @State private var amountText: String

    init(viewModel: SettlementViewModel, fromDisplayName: String, toDisplayName: String, fromUserID: String, toUserID: String, amount: Decimal) {
        self.viewModel = viewModel
        self.fromDisplayName = fromDisplayName
        self.toDisplayName = toDisplayName
        self.fromUserID = fromUserID
        self.toUserID = toUserID
        _amountText = State(initialValue: "\(amount)")
    }

    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    Text("From")
                    Spacer()
                    Text(fromDisplayName)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("To")
                    Spacer()
                    Text(toDisplayName)
                        .foregroundStyle(.secondary)
                }
                TextField("Amount", text: $amountText)
                    .keyboardType(.decimalPad)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Record Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    // Spinner reflects this in-flight save action — not a data load.
                    Button {
                        Task {
                            guard let amount = Decimal(string: amountText) else { return }
                            if await viewModel.recordSettlement(fromUserID: fromUserID, toUserID: toUserID, amount: amount) {
                                dismiss()
                            }
                        }
                    } label: {
                        if viewModel.isRecordingSettlement {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(viewModel.isRecordingSettlement || Decimal(string: amountText) == nil)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
