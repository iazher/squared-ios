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
    let group: Group

    struct MemberBalance: Identifiable {
        let id: String
        let displayName: String
        let initials: String
        let netBalance: Decimal
        /// Whether this member has any expense activity in this group — distinguishes
        /// an actually-settled $0.00 from a new member with no history yet.
        let hasActivity: Bool
    }

    init(appState: AppState, group: Group) {
        self.appState = appState
        self.group = group
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
        for balance in appState.balances where balance.groupID == group.id {
            if balance.toUserID == userID {
                total += balance.amount
            } else if balance.fromUserID == userID {
                total -= balance.amount
            }
        }
        return total
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
}
