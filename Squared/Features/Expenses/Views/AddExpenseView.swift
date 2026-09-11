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
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $viewModel.title)
                    TextField("Amount", text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                }

                Section("Paid by") {
                    Picker("Payer", selection: $viewModel.payerID) {
                        ForEach(viewModel.members) { member in
                            Text(member.displayName).tag(member.id)
                        }
                    }
                }

                Section("Split") {
                    Picker("Split Method", selection: $viewModel.splitMethod) {
                        Text("Equal").tag(SplitMethod.equal)
                        Text("Custom").tag(SplitMethod.exact)
                        Text("Percentage").tag(SplitMethod.percentage)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Participants") {
                    ForEach(viewModel.members) { member in
                        Toggle(member.displayName, isOn: Binding(
                            get: { viewModel.isParticipantSelected(member.id) },
                            set: { _ in viewModel.toggleParticipant(member.id) }
                        ))
                    }
                }

                Section("Split Preview") {
                    ForEach(viewModel.splitPreview) { row in
                        SplitPreviewRowView(
                            row: row,
                            splitMethod: viewModel.splitMethod,
                            customAmountText: Binding(
                                get: { viewModel.customAmountText[row.id] ?? "" },
                                set: { viewModel.customAmountText[row.id] = $0 }
                            ),
                            customPercentageText: Binding(
                                get: { viewModel.customPercentageText[row.id] ?? "" },
                                set: { viewModel.customPercentageText[row.id] = $0 }
                            )
                        )
                    }

                    if let message = viewModel.splitValidationMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Add Expense")
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
                    .disabled(!viewModel.canSave || viewModel.isSaving)
                }
            }
        }
    }
}

private struct SplitPreviewRowView: View {
    let row: AddExpenseViewModel.SplitPreviewRow
    let splitMethod: SplitMethod
    @Binding var customAmountText: String
    @Binding var customPercentageText: String

    var body: some View {
        HStack {
            Text(row.displayName)

            Spacer()

            switch splitMethod {
            case .equal:
                EmptyView()
            case .exact:
                TextField("0.00", text: $customAmountText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 70)
            case .percentage:
                TextField("0", text: $customPercentageText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 50)
                Text("%")
                    .foregroundStyle(.secondary)
            }

            Text(row.amount.formatted(currencyCode: "USD"))
                .foregroundStyle(.secondary)
                .frame(minWidth: 70, alignment: .trailing)
        }
    }
}
