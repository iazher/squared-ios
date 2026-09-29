//
//  GroupMembersViewModel.swift
//  Squared
//

import Foundation
import Observation

/// Reads this group's members and their balances from `AppState`; adding a
/// member goes through `AddMemberViewModel`, which writes back into `AppState`.
@Observable
final class GroupMembersViewModel {
    private let appState: AppState
    private let groupsService: GroupsServiceProtocol
    let group: Group

    var errorMessage: String?

    struct MemberBalance: Identifiable {
        let id: String
        let displayName: String
        let initials: String
        let netBalance: Decimal
        /// Whether this member has any expense activity in this group — distinguishes
        /// an actually-settled $0.00 from a new member with no history yet.
        let hasActivity: Bool
    }

    init(appState: AppState, group: Group, groupsService: GroupsServiceProtocol) {
        self.appState = appState
        self.group = group
        self.groupsService = groupsService
    }

    /// Positive means the member is owed within this group; negative means they owe.
    var memberBalances: [MemberBalance] {
        currentGroup.memberIDs.map { memberID in
            MemberBalance(
                id: memberID,
                displayName: displayName(for: memberID),
                initials: MemberAvatar.initials(from: actualName(for: memberID)),
                netBalance: netBalance(for: memberID),
                hasActivity: hasActivity(for: memberID)
            )
        }
    }

    /// `group` is captured at push time; member edits land in `AppState`, so read the live copy.
    private var currentGroup: Group {
        appState.groups.first(where: { $0.id == group.id }) ?? group
    }

    private func displayName(for userID: String) -> String {
        if userID == appState.currentUser?.id {
            return "You"
        }
        return actualName(for: userID)
    }

    /// The member's real name, even for the current user — "You" is only for row labels,
    /// not for initials/color, so avatars stay identical wherever a member appears.
    private func actualName(for userID: String) -> String {
        appState.users.first(where: { $0.id == userID })?.name ?? userID
    }

    private func netBalance(for userID: String) -> Decimal {
        var total = Decimal.zero
        for balance in significantBalances(involving: userID) {
            if balance.toUserID == userID {
                total += balance.amount
            } else if balance.fromUserID == userID {
                total -= balance.amount
            }
        }
        return total
    }

    /// This member's own significant pairwise debts, shared by both the
    /// displayed net balance and the removal guard below.
    private func significantBalances(involving userID: String) -> [Balance] {
        appState.balances.filter {
            $0.groupID == group.id && $0.isSignificant && ($0.fromUserID == userID || $0.toUserID == userID)
        }
    }

    private func hasActivity(for userID: String) -> Bool {
        for expense in appState.expenses where expense.groupID == group.id {
            if expense.paidByUserID == userID {
                return true
            }
            if expense.splits.contains(where: { $0.userID == userID }) {
                return true
            }
        }
        return false
    }

    // MARK: - Member removal

    /// Net-zero isn't enough on its own — a cycle can leave a member's net at
    /// zero while they still have real, tappable Raw edges with other members,
    /// which the Settlement graph would otherwise render as owed to nobody
    /// (edges to a non-member silently don't draw at all).
    func canRemove(_ member: MemberBalance) -> Bool {
        significantBalances(involving: member.id).isEmpty
    }

    func blockedRemovalMessage(for member: MemberBalance) -> String {
        guard abs(member.netBalance) >= Balance.significantAmountThreshold else {
            return "\(member.displayName) still has open debts with other members. Settle up before removing them."
        }
        let amount = abs(member.netBalance).formatted(currencyCode: "USD")
        return member.netBalance > 0
            ? "\(member.displayName) is owed \(amount). Settle up before removing them."
            : "\(member.displayName) still owes \(amount). Settle up before removing them."
    }

    func removeMember(_ userID: String) async -> Bool {
        errorMessage = nil
        do {
            try await groupsService.removeMember(groupID: group.id, userID: userID)
            let updatedGroup = Group(
                id: currentGroup.id,
                name: currentGroup.name,
                memberIDs: currentGroup.memberIDs.filter { $0 != userID },
                createdAt: currentGroup.createdAt
            )
            appState.upsert(group: updatedGroup)
            return true
        } catch {
            errorMessage = friendlyErrorMessage(error)
            return false
        }
    }
}
