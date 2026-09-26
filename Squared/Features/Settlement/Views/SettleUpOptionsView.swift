//
//  SettleUpOptionsView.swift
//  Squared
//

import SwiftUI

/// Presented when tapping a settlement edge, before Record Payment — lets the
/// user jump to Venmo/PayPal to actually send money, or just mark the debt as
/// paid directly. Venmo/PayPal only become tappable once the "from" member has
/// a stored username for that service; otherwise they show as disabled.
struct SettleUpOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    let fromDisplayName: String
    let venmoUsername: String?
    let paypalUsername: String?
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

                paymentOptionRow(service: "Venmo", username: venmoUsername, urlPrefix: "https://venmo.com/")
                paymentOptionRow(service: "PayPal", username: paypalUsername, urlPrefix: "https://paypal.me/")
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

    @ViewBuilder
    private func paymentOptionRow(service: String, username: String?, urlPrefix: String) -> some View {
        let title = "Open \(service)"
        if let username, !username.isEmpty, let url = paymentURL(prefix: urlPrefix, username: username) {
            Button {
                openURL(url)
            } label: {
                Label(title, systemImage: "arrow.up.forward.app")
            }
        } else {
            Button {
                // Disabled until this member has a stored username for this service.
            } label: {
                disabledOptionRow(title: title, systemImage: "arrow.up.forward.app", note: "No \(service) linked for \(fromDisplayName)")
            }
            .disabled(true)
            .accessibilityLabel(title)
        }
    }

    private func paymentURL(prefix: String, username: String) -> URL? {
        let encoded = username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? username
        return URL(string: prefix + encoded)
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
