//
//  GroupDetailViewModel.swift
//  Squared
//

import Foundation
import Observation

/// Reads this group's member summary and expenses from `AppState`.
@Observable
final class GroupDetailViewModel {
    private let appState: AppState
    let group: Group

    init(appState: AppState, group: Group) {
        self.appState = appState
        self.group = group
    }

    struct MemberAvatarInfo: Identifiable {
        let id: String
        let initials: String
    }

    var memberCount: Int {
        currentGroup.memberIDs.count
    }

    /// Avatar info for the summary cluster, in member order.
    var memberAvatars: [MemberAvatarInfo] {
        currentGroup.memberIDs.map { userID in
            MemberAvatarInfo(id: userID, initials: MemberAvatar.initials(from: actualName(for: userID)))
        }
    }

    var expenses: [Expense] {
        appState.expenses
            .filter { $0.groupID == group.id }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func payerName(for expense: Expense) -> String {
        displayName(for: expense.paidByUserID)
    }

    /// `group` is captured at push time; member edits land in `AppState`, so read the live copy.
    private var currentGroup: Group {
        appState.groups.first(where: { $0.id == group.id }) ?? group
    }

    private func displayName(for userID: String) -> String {
        if userID == appState.currentUser?.id {
            return "You"
        }
        return appState.users.first(where: { $0.id == userID })?.name ?? userID
    }

    /// The member's real name, even for the current user — "You" is only for row labels,
    /// not for initials/color, so avatars stay identical wherever a member appears.
    private func actualName(for userID: String) -> String {
        appState.users.first(where: { $0.id == userID })?.name ?? userID
    }
}
