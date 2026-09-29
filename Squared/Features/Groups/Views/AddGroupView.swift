//
//  AddGroupView.swift
//  Squared
//

import SwiftUI

struct AddGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddGroupViewModel

    init(appState: AppState, groupsService: GroupsServiceProtocol) {
        _viewModel = State(initialValue: AddGroupViewModel(appState: appState, groupsService: groupsService))
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Group name", text: $viewModel.name)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(
                        message: errorMessage,
                        background: Color(uiColor: .secondarySystemGroupedBackground),
                        onRetry: performCreate
                    ) {
                        viewModel.errorMessage = nil
                    }
                    .padding(.top, 8)
                }
            }
            .animation(.default, value: viewModel.errorMessage)
            .navigationTitle("New Group")
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
                    Button(action: performCreate) {
                        if viewModel.isCreating {
                            ProgressView()
                        } else {
                            Text("Create")
                        }
                    }
                    .disabled(!viewModel.canCreate || viewModel.isCreating)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func performCreate() {
        Task {
            if await viewModel.createGroup() {
                dismiss()
            }
        }
    }
}
