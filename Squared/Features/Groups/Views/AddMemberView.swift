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

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Add Member")
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
                            if await viewModel.addMember() {
                                dismiss()
                            }
                        }
                    } label: {
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
}
