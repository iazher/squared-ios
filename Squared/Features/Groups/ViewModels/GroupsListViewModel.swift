//
//  GroupsListViewModel.swift
//  Squared
//

import Foundation
import Observation

/// Reads groups and balances from `AppState`; only calls services for mutations.
@Observable
final class GroupsListViewModel {
    private let appState: AppState
    private let groupsService: GroupsServiceProtocol
    private let settlementService: SettlementServiceProtocol

    init(appState: AppState, groupsService: GroupsServiceProtocol, settlementService: SettlementServiceProtocol) {
        self.appState = appState
        self.groupsService = groupsService
        self.settlementService = settlementService
    }

    // Newest first, so a freshly created group appears at the top.
    var groups: [Group] {
        appState.groups.sorted { $0.createdAt > $1.createdAt }
    }

    /// Positive means owed overall; negative means the user owes overall.
    var overallNetBalance: Decimal {
        var total = Decimal.zero
        for group in groups {
            total += netBalance(for: group)
        }
        return total
    }

    /// The current user's net balance within a single group.
    func netBalance(for group: Group) -> Decimal {
        guard let currentUserID = appState.currentUser?.id else { return .zero }
        var total = Decimal.zero
        for balance in appState.balances where balance.groupID == group.id {
            if balance.toUserID == currentUserID {
                total += balance.amount
            } else if balance.fromUserID == currentUserID {
                total -= balance.amount
            }
        }
        return total
    }

    /// Pull-to-refresh — the sanctioned exception to reading only from `AppState`.
    func refresh() async {
        try? await Task.sleep(nanoseconds: 700_000_000)

        async let fetchedGroups = try? groupsService.fetchGroups()
        async let fetchedBalances = try? settlementService.fetchBalances()

        if let groups = await fetchedGroups {
            appState.setGroups(groups)
        }
        if let balances = await fetchedBalances {
            appState.setBalances(balances)
        }
    }
}
