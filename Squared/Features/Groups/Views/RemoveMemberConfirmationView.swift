//
//  RemoveMemberConfirmationView.swift
//  Squared
//

import SwiftUI

/// Presented when swiping to remove an already-settled-up member, before
/// they're actually removed — same sheet style as `DeleteExpenseConfirmationView`.
struct RemoveMemberConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    let memberName: String
    /// Returns nil on success, or a user-facing message on failure.
    let onRemove: () async -> String?

    @State private var isRemoving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Remove \(memberName)?")
                        .foregroundStyle(.white)
                    Text("This can't be undone.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Button(role: .destructive) {
                    Task {
                        isRemoving = true
                        errorMessage = nil
                        let failure = await onRemove()
                        isRemoving = false
                        if let failure {
                            errorMessage = failure
                        } else {
                            dismiss()
                        }
                    }
                } label: {
                    HStack {
                        if isRemoving {
                            ProgressView()
                        }
                        Text("Remove Member")
                    }
                }
                .disabled(isRemoving)
            }
            .navigationTitle("Remove Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isRemoving)
                }
            }
        }
        .interactiveDismissDisabled(isRemoving)
        .presentationDetents([.medium])
    }
}
