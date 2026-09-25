//
//  SettleUpOptionsView.swift
//  Squared
//

import SwiftUI

/// Presented when tapping a settlement edge, before Record Payment — lets the
/// user jump to Venmo/PayPal to actually send money, or just mark the debt as
/// paid directly. Venmo/PayPal aren't wired up yet since members don't have a
/// stored username for either, so those two are disabled placeholders.
struct SettleUpOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    let fromDisplayName: String
    let onMarkAsPaid: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Button(action: onMarkAsPaid) {
                    HStack {
                        Text("Mark as Paid")
                            .foregroundStyle(.white)
                        Spacer()
                        // A chevron, not a checkmark: this proceeds to another screen
                        // rather than marking the row itself as a selected option.
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }

                Button {
                    // Disabled until members have a stored Venmo username.
                } label: {
                    disabledOptionRow(title: "Open Venmo", systemImage: "arrow.up.forward.app", note: "No Venmo linked for \(fromDisplayName)")
                }
                .disabled(true)
                .accessibilityLabel("Open Venmo")

                Button {
                    // Disabled until members have a stored PayPal username.
                } label: {
                    disabledOptionRow(title: "Open PayPal", systemImage: "arrow.up.forward.app", note: "No PayPal linked for \(fromDisplayName)")
                }
                .disabled(true)
                .accessibilityLabel("Open PayPal")
            }
            .navigationTitle("Settle Up")
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

    /// One opacity over the whole row so icon/title/subtext dim as a single
    /// unit; title vs. subtext contrast is set before that shared opacity.
    private func disabledOptionRow(title: String, systemImage: String, note: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundStyle(.white)
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .opacity(0.4)
    }
}
