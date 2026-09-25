//
//  RecordPaymentView.swift
//  Squared
//

import SwiftUI

/// Presented when tapping a settlement edge; from/to/amount are prefilled from
/// that edge but stay editable, since this doubles as a general "record a
/// payment" form.
struct RecordPaymentView: View {
    @Environment(\.dismiss) private var dismiss
    private let viewModel: SettlementViewModel
    private let members: [SettlementViewModel.Member]
    @State private var fromUserID: String
    @State private var toUserID: String
    @State private var amountText: String

    init(viewModel: SettlementViewModel, members: [SettlementViewModel.Member], fromUserID: String, toUserID: String, amount: Decimal) {
        self.viewModel = viewModel
        self.members = members
        _fromUserID = State(initialValue: fromUserID)
        _toUserID = State(initialValue: toUserID)
        _amountText = State(initialValue: "\(amount)")
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("From", selection: $fromUserID) {
                    ForEach(members) { member in
                        Text(member.displayName).tag(member.id)
                    }
                }
                Picker("To", selection: $toUserID) {
                    ForEach(members) { member in
                        Text(member.displayName).tag(member.id)
                    }
                }
                TextField("Amount", text: $amountText)
                    .keyboardType(.decimalPad)

                if fromUserID == toUserID {
                    Text("From and To must be different people.")
                        .foregroundStyle(.red)
                }
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
                    .disabled(viewModel.isRecordingSettlement || Decimal(string: amountText) == nil || fromUserID == toUserID)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
