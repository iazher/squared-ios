//
//  SettlementBalanceListView.swift
//  Squared
//

import SwiftUI

/// Plain-list fallback for the Settlement screen, shown instead of
/// `SettlementGraphView` once a display mode's edge count is too dense for the
/// graph to stay readable — no amount of per-edge decluttering makes a
/// near-complete graph on many members legible in a small circle.
struct SettlementBalanceListView: View {
    let balances: [Balance]
    let currentUserID: String?
    let displayName: (String) -> String
    let onSelect: (_ fromUserID: String, _ toUserID: String, _ amount: Decimal) -> Void

    var body: some View {
        List(balances) { balance in
            Button {
                onSelect(balance.fromUserID, balance.toUserID, balance.amount)
            } label: {
                row(for: balance)
            }
            .buttonStyle(.plain)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func row(for balance: Balance) -> some View {
        HStack(spacing: 12) {
            Text("\(displayName(balance.fromUserID)) owes \(displayName(balance.toUserID))")
                .font(.subheadline)
                .foregroundStyle(.white)

            Spacer()

            Text(balance.amount.formatted(currencyCode: "USD"))
                .font(.subheadline.bold())
                .foregroundStyle(amountColor(for: balance))

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(12)
        .background(Color("CardSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func amountColor(for balance: Balance) -> Color {
        if balance.fromUserID == currentUserID {
            return .red
        } else if balance.toUserID == currentUserID {
            return Color("PositiveBalance")
        }
        return .white.opacity(0.7)
    }
}
