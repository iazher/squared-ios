//
//  GroupsListViewModel.swift
//  Squared
//

import Foundation
import Observation

/// Reads groups from `AppState`; only calls the service for mutations.
@Observable
final class GroupsListViewModel {
    private let appState: AppState
    private let groupsService: GroupsServiceProtocol

    private(set) var isCreatingGroup = false
    var errorMessage: String?

    init(appState: AppState, groupsService: GroupsServiceProtocol) {
        self.appState = appState
        self.groupsService = groupsService
    }

    var groups: [Group] {
        appState.groups
    }

    func createGroup(name: String, memberIDs: [String]) async {
        isCreatingGroup = true
        errorMessage = nil
        defer { isCreatingGroup = false }

        do {
            let group = try await groupsService.createGroup(name: name, memberIDs: memberIDs)
            appState.upsert(group: group)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
