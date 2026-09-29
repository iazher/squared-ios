//
//  AddMemberView.swift
//  Squared
//

import SwiftUI

struct AddMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddMemberViewModel

    init(appState: AppState, group: Group, groupsService: GroupsServiceProtocol) {
        _viewModel = State(initialValue: AddMemberViewModel(appState: appState, group: group, groupsService: groupsService))
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Member name", text: $viewModel.name)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(
                        message: errorMessage,
                        background: Color(uiColor: .secondarySystemGroupedBackground),
                        onRetry: performAdd
                    ) {
                        viewModel.errorMessage = nil
                    }
                    .padding(.top, 8)
                }
            }
            .animation(.default, value: viewModel.errorMessage)
            .navigationTitle("Add Member")
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
                    Button(action: performAdd) {
                        if viewModel.isAdding {
                            ProgressView()
                        } else {
                            Text("Add")
                        }
                    }
                    .disabled(!viewModel.canAdd || viewModel.isAdding)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func performAdd() {
        Task {
            if await viewModel.addMember() {
                dismiss()
            }
        }
    }
}
