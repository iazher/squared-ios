//
//  AddMemberViewModel.swift
//  Squared
//

import Foundation
import Observation

/// Calls `GroupsServiceProtocol` directly, then writes the result into `AppState`.
@Observable
final class AddMemberViewModel {
    private let appState: AppState
    private let groupsService: GroupsServiceProtocol
    let group: Group

    var name: String = ""
    private(set) var isAdding = false
    var errorMessage: String?

    init(appState: AppState, group: Group, groupsService: GroupsServiceProtocol) {
        self.appState = appState
        self.group = group
        self.groupsService = groupsService
    }

    var canAdd: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func addMember() async -> Bool {
        guard canAdd else { return false }

        isAdding = true
        errorMessage = nil
        defer { isAdding = false }

        do {
            let newMember = try await groupsService.addMember(
                groupID: group.id,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            appState.upsert(user: newMember)

            let currentGroup = appState.groups.first(where: { $0.id == group.id }) ?? group
            let updatedGroup = Group(
                id: currentGroup.id,
                name: currentGroup.name,
                memberIDs: currentGroup.memberIDs + [newMember.id],
                createdAt: currentGroup.createdAt
            )
            appState.upsert(group: updatedGroup)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
