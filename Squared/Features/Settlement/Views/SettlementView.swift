//
//  SettlementView.swift
//  Squared
//

import SwiftUI

struct SettlementView: View {
    @State private var viewModel: SettlementViewModel

    init(appState: AppState, group: Group, settlementService: SettlementServiceProtocol) {
        _viewModel = State(initialValue: SettlementViewModel(appState: appState, group: group, settlementService: settlementService))
    }

    var body: some View {
        // Reads straight from AppState — no per-screen fetch, no loading spinner.
        List(viewModel.balances) { balance in
            HStack {
                Text("\(balance.fromUserID) owes \(balance.toUserID)")
                Spacer()
                Text(balance.amount.formatted(currencyCode: "USD"))
            }
        }
        .navigationTitle("Balances")
        .overlay {
            if viewModel.balances.isEmpty {
                ContentUnavailableView("All Settled Up", systemImage: "checkmark.circle")
            }
        }
    }
}
