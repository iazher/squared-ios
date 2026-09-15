//
//  SettlementViewModel.swift
//  Squared
//

import Foundation
import Observation

/// Reads this group's balances from `AppState`; settlements go through the service.
@Observable
final class SettlementViewModel {
    private let appState: AppState
    private let settlementService: SettlementServiceProtocol
    let group: Group

    enum DisplayMode: String, CaseIterable {
        case raw = "Who Owes What"
        case simplified = "Simplified"
    }

    struct Member: Identifiable {
        let id: String
        let displayName: String
        let initials: String
    }

    private(set) var isRecordingSettlement = false
    var errorMessage: String?

    init(appState: AppState, group: Group, settlementService: SettlementServiceProtocol) {
        self.appState = appState
        self.group = group
        self.settlementService = settlementService
    }

    var currentUserID: String? {
        appState.currentUser?.id
    }

    /// Members in a stable order, used for the graph's circular layout.
    var members: [Member] {
        currentGroup.memberIDs.map { id in
            Member(id: id, displayName: displayName(for: id), initials: MemberAvatar.initials(from: actualName(for: id)))
        }
    }

    /// Raw pairwise debts, already netted per pair — "who owes what" as it stands.
    var rawBalances: [Balance] {
        appState.balances.filter { $0.groupID == group.id }
    }

    /// Minimum-transaction settle-up: nets each member's overall position, then
    /// greedily matches the largest creditor with the largest debtor until
    /// everyone clears — the standard debt-simplification heuristic.
    var simplifiedBalances: [Balance] {
        var net: [String: Decimal] = [:]
        for balance in rawBalances {
            net[balance.toUserID, default: .zero] += balance.amount
            net[balance.fromUserID, default: .zero] -= balance.amount
        }

        var creditors = net.filter { $0.value > 0 }.map { (id: $0.key, amount: $0.value) }
        var debtors = net.filter { $0.value < 0 }.map { (id: $0.key, amount: -$0.value) }
        creditors.sort { $0.amount > $1.amount }
        debtors.sort { $0.amount > $1.amount }

        var result: [Balance] = []
        var creditorIndex = 0
        var debtorIndex = 0
        while creditorIndex < creditors.count && debtorIndex < debtors.count {
            let settled = min(creditors[creditorIndex].amount, debtors[debtorIndex].amount)
            if settled > 0 {
                result.append(Balance(
                    groupID: group.id,
                    fromUserID: debtors[debtorIndex].id,
                    toUserID: creditors[creditorIndex].id,
                    amount: settled
                ))
            }
            creditors[creditorIndex].amount -= settled
            debtors[debtorIndex].amount -= settled
            if creditors[creditorIndex].amount <= 0.005 { creditorIndex += 1 }
            if debtors[debtorIndex].amount <= 0.005 { debtorIndex += 1 }
        }
        return result
    }

    func displayName(for userID: String) -> String {
        if userID == appState.currentUser?.id {
            return "You"
        }
        return actualName(for: userID)
    }

    func recordSettlement(fromUserID: String, toUserID: String, amount: Decimal) async -> Bool {
        isRecordingSettlement = true
        errorMessage = nil
        defer { isRecordingSettlement = false }

        do {
            _ = try await settlementService.recordSettlement(
                groupID: group.id,
                fromUserID: fromUserID,
                toUserID: toUserID,
                amount: amount
            )
            // TEMPORARY: balances are derived from expenses only right now (see
            // AppState), so recording a settlement doesn't move them yet —
            // recompute anyway so this call site is correct once settlements
            // factor into the real calculation.
            appState.recomputeBalances()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    /// `group` is captured at push time; member edits land in `AppState`, so read the live copy.
    private var currentGroup: Group {
        appState.groups.first(where: { $0.id == group.id }) ?? group
    }

    private func actualName(for userID: String) -> String {
        appState.users.first(where: { $0.id == userID })?.name ?? userID
    }
}
