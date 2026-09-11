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

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("New Group")
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
                            if await viewModel.createGroup() {
                                dismiss()
                            }
                        }
                    } label: {
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
}
