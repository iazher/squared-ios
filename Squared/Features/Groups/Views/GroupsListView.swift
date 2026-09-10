//
//  GroupsListView.swift
//  Squared
//

import SwiftUI

struct GroupsListView: View {
    @State private var viewModel: GroupsListViewModel
    // Driven manually (not NavigationLink) so the chevron stays inside GroupRow's card.
    @State private var path: [Group] = []
    private let appState: AppState
    private let expensesService: ExpensesServiceProtocol
    private let settlementService: SettlementServiceProtocol

    init(appState: AppState, groupsService: GroupsServiceProtocol, expensesService: ExpensesServiceProtocol, settlementService: SettlementServiceProtocol) {
        _viewModel = State(initialValue: GroupsListViewModel(appState: appState, groupsService: groupsService, settlementService: settlementService))
        self.appState = appState
        self.expensesService = expensesService
        self.settlementService = settlementService
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !viewModel.groups.isEmpty {
                    overallBalanceHeader
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 12, trailing: 16))
                }

                ForEach(viewModel.groups) { group in
                    Button {
                        path.append(group)
                    } label: {
                        GroupRow(group: group, netBalance: viewModel.netBalance(for: group))
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color("AppBackground"))
            .navigationTitle("Groups")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    // TODO: full create-group flow is a stretch goal.
                    Button {
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: Group.self) { group in
                GroupDetailView(appState: appState, group: group, expensesService: expensesService, settlementService: settlementService)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .overlay {
                if viewModel.groups.isEmpty {
                    ContentUnavailableView("No Groups Yet", systemImage: "person.3")
                }
            }
        }
    }

    private var overallBalanceHeader: some View {
        let overall = viewModel.overallNetBalance
        return Text(overallBalanceText(for: overall))
            .font(.subheadline.bold())
            .foregroundStyle(overall > 0 ? Color("PositiveBalance") : (overall < 0 ? .red : .white.opacity(0.6)))
    }

    private func overallBalanceText(for overall: Decimal) -> String {
        if overall == 0 {
            return "You're all settled up"
        }
        let amount = abs(overall).formatted(currencyCode: "USD")
        return overall > 0 ? "You're owed \(amount) overall" : "You owe \(amount) overall"
    }
}

private struct GroupRow: View {
    let group: Group
    let netBalance: Decimal

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.accentColor.opacity(0.15))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: "person.3.fill")
                        .foregroundStyle(Color.accentColor)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(group.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("\(group.memberIDs.count) people")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            Text(balanceText)
                .font(.subheadline.bold())
                .foregroundStyle(netBalance >= 0 ? Color("PositiveBalance") : .red)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(12)
        .background(Color("CardSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var balanceText: String {
        let formatted = abs(netBalance).formatted(currencyCode: "USD")
        return netBalance >= 0 ? "+\(formatted)" : "-\(formatted)"
    }
}
