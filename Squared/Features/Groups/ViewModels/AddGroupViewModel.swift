//
//  AddGroupViewModel.swift
//  Squared
//

import Foundation
import Observation

/// Calls `GroupsServiceProtocol` directly, then writes the result into `AppState`.
@Observable
final class AddGroupViewModel {
    private let appState: AppState
    private let groupsService: GroupsServiceProtocol

    var name: String = ""
    private(set) var isCreating = false
    var errorMessage: String?

    init(appState: AppState, groupsService: GroupsServiceProtocol) {
        self.appState = appState
        self.groupsService = groupsService
    }

    var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func createGroup() async -> Bool {
        guard canCreate, let currentUser = appState.currentUser else { return false }

        isCreating = true
        errorMessage = nil
        defer { isCreating = false }

        do {
            let group = try await groupsService.createGroup(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                memberIDs: [currentUser.id]
            )
            appState.upsert(group: group)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
