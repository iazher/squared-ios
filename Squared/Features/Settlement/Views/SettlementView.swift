//
//  SettlementView.swift
//  Squared
//

import SwiftUI

struct SettlementView: View {
    @State private var viewModel: SettlementViewModel
    @State private var displayMode: SettlementViewModel.DisplayMode = .raw
    @State private var optionsEdge: SelectedEdge?
    @State private var paymentEdge: SelectedEdge?
    @State private var edgePendingMarkAsPaid: SelectedEdge?

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

    /// Whether EITHER mode has anything to show — a debt cycle (A owes B, B
    /// owes C, C owes A) can leave every person's net position at exactly
    /// zero, so Simplified shows nothing even though Raw still has real,
    /// unsettled per-pair debts. The toggle and the big empty state must key
    /// off this, not off whichever mode is currently selected, or switching
    /// to Simplified in that case would falsely claim the group is settled
    /// and hide the only way back to Raw.
    private var hasAnyEdges: Bool {
        !viewModel.rawBalances.isEmpty || !viewModel.simplifiedBalances.isEmpty
    }

    var body: some View {
        VStack(spacing: 16) {
            if hasAnyEdges {
                Picker("View", selection: $displayMode) {
                    ForEach(SettlementViewModel.DisplayMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }

            if !hasAnyEdges {
                Spacer()
                if viewModel.hasExpenses {
                    ContentUnavailableView {
                        Label("Everyone's squared up", systemImage: "checkmark.circle")
                    } description: {
                        Text("There are no outstanding debts in this group.")
                    }
                } else {
                    ContentUnavailableView {
                        Label("No expenses yet", systemImage: "tray")
                    } description: {
                        Text("Add an expense to start tracking who owes what.")
                    }
                }
                Spacer()
            } else if currentBalances.count > graphEdgeCountThreshold {
                SettlementBalanceListView(
                    balances: currentBalances,
                    currentUserID: viewModel.currentUserID,
                    displayName: viewModel.displayName(for:),
                    onSelect: { fromUserID, toUserID, amount in
                        optionsEdge = SelectedEdge(fromUserID: fromUserID, toUserID: toUserID, amount: amount)
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
                        optionsEdge = SelectedEdge(fromUserID: fromUserID, toUserID: toUserID, amount: amount)
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
        .sheet(item: $optionsEdge, onDismiss: {
            // The options sheet must fully dismiss before Record Payment can be
            // presented, or iOS can silently drop the second sheet presentation.
            if let edge = edgePendingMarkAsPaid {
                edgePendingMarkAsPaid = nil
                paymentEdge = edge
            }
        }) { edge in
            SettleUpOptionsView(
                fromDisplayName: viewModel.displayName(for: edge.fromUserID),
                venmoUsername: viewModel.venmoUsername(for: edge.fromUserID),
                paypalUsername: viewModel.paypalUsername(for: edge.fromUserID),
                onMarkAsPaid: {
                    edgePendingMarkAsPaid = edge
                    optionsEdge = nil
                }
            )
        }
        .sheet(item: $paymentEdge) { edge in
            RecordPaymentView(
                viewModel: viewModel,
                members: viewModel.members,
                fromUserID: edge.fromUserID,
                toUserID: edge.toUserID,
                amount: edge.amount
            )
        }
    }
}
