//
//  SettlementView.swift
//  Squared
//

import SwiftUI

struct SettlementView: View {
    @State private var viewModel: SettlementViewModel
    @State private var displayMode: SettlementViewModel.DisplayMode = .raw
    @State private var selectedEdge: SelectedEdge?

    /// Above this many simultaneous edges, no amount of per-edge collision
    /// avoidance keeps the graph legible, so this falls back to a plain list.
    private let graphEdgeCountThreshold = 15

    private struct SelectedEdge: Identifiable {
        let id = UUID()
        let fromUserID: String
        let toUserID: String
        let amount: Decimal
    }

    init(appState: AppState, group: Group, settlementService: SettlementServiceProtocol) {
        _viewModel = State(initialValue: SettlementViewModel(appState: appState, group: group, settlementService: settlementService))
    }

    private var currentBalances: [Balance] {
        displayMode == .raw ? viewModel.rawBalances : viewModel.simplifiedBalances
    }

    var body: some View {
        VStack(spacing: 16) {
            Picker("View", selection: $displayMode) {
                ForEach(SettlementViewModel.DisplayMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 12)

            if viewModel.rawBalances.isEmpty {
                Spacer()
                ContentUnavailableView("All Settled Up", systemImage: "checkmark.circle")
                Spacer()
            } else if currentBalances.count > graphEdgeCountThreshold {
                SettlementBalanceListView(
                    balances: currentBalances,
                    currentUserID: viewModel.currentUserID,
                    displayName: viewModel.displayName(for:),
                    onSelect: { fromUserID, toUserID, amount in
                        selectedEdge = SelectedEdge(fromUserID: fromUserID, toUserID: toUserID, amount: amount)
                    }
                )
            } else {
                Spacer(minLength: 0)
                SettlementGraphView(
                    members: viewModel.members,
                    rawBalances: viewModel.rawBalances,
                    simplifiedBalances: viewModel.simplifiedBalances,
                    displayMode: displayMode,
                    currentUserID: viewModel.currentUserID,
                    onTapEdge: { fromUserID, toUserID, amount in
                        selectedEdge = SelectedEdge(fromUserID: fromUserID, toUserID: toUserID, amount: amount)
                    }
                )
                .frame(maxWidth: .infinity)
                .frame(height: 460)
                Spacer(minLength: 0)
            }
        }
        .background(Color("AppBackground"))
        .navigationTitle("Balances")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedEdge) { edge in
            RecordPaymentView(
                viewModel: viewModel,
                fromDisplayName: viewModel.displayName(for: edge.fromUserID),
                toDisplayName: viewModel.displayName(for: edge.toUserID),
                fromUserID: edge.fromUserID,
                toUserID: edge.toUserID,
                amount: edge.amount
            )
        }
    }
}
