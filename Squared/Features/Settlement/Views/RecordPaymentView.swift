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
                    .onChange(of: amountText) { _, newValue in
                        let sanitized = Self.sanitizedAmountText(newValue)
                        if sanitized != amountText {
                            amountText = sanitized
                        }
                    }

                if fromUserID == toUserID {
                    Text("From and To must be different people.")
                        .foregroundStyle(.red)
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(
                        message: errorMessage,
                        background: Color(uiColor: .secondarySystemGroupedBackground),
                        onRetry: performSave
                    ) {
                        viewModel.errorMessage = nil
                    }
                    .padding(.top, 8)
                }
            }
            .animation(.default, value: viewModel.errorMessage)
            .navigationTitle("Record Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.errorMessage = nil
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    // Spinner reflects this in-flight save action — not a data load.
                    Button(action: performSave) {
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
        // `viewModel` is owned by the presenting `SettlementView`, not recreated
        // per sheet — without this, a failure left over from a previous payment
        // would show its stale banner the instant this sheet reopens.
        .onAppear {
            viewModel.errorMessage = nil
        }
    }

    private func performSave() {
        guard let amount = Decimal(string: amountText) else { return }
        Task {
            if await viewModel.recordSettlement(fromUserID: fromUserID, toUserID: toUserID, amount: amount) {
                dismiss()
            }
        }
    }

    /// Strips anything but digits and a single decimal point, then truncates to
    /// at most 2 digits after it — currency amounts don't need sub-cent input.
    private static func sanitizedAmountText(_ text: String) -> String {
        var seenDecimalPoint = false
        var result = ""
        for character in text {
            if character.isNumber {
                result.append(character)
            } else if character == ".", !seenDecimalPoint {
                seenDecimalPoint = true
                result.append(character)
            }
        }
        if let dotIndex = result.firstIndex(of: ".") {
            let afterDot = result.index(after: dotIndex)
            let maxEnd = result.index(afterDot, offsetBy: 2, limitedBy: result.endIndex) ?? result.endIndex
            result = String(result[result.startIndex..<maxEnd])
        }
        return result
    }
}
