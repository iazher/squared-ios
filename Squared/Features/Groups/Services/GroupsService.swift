//
//  GroupsService.swift
//  Squared
//

import Foundation

final class GroupsService: GroupsServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchGroups() async throws -> [Group] {
        let endpoint = Endpoint(path: "/groups")
        return try await apiClient.request(endpoint)
    }

    func createGroup(name: String, memberIDs: [String]) async throws -> Group {
        let requestBody = CreateGroupRequest(name: name, memberIDs: memberIDs)
        let body = try JSONEncoder().encode(requestBody)
        let endpoint = Endpoint(path: "/groups", method: .post, body: body)
        return try await apiClient.request(endpoint)
    }

    func addMember(groupID: String, name: String) async throws -> User {
        let requestBody = AddMemberRequest(name: name)
        let body = try JSONEncoder().encode(requestBody)
        let endpoint = Endpoint(path: "/groups/\(groupID)/members", method: .post, body: body)
        return try await apiClient.request(endpoint)
    }
}

private struct CreateGroupRequest: Encodable {
    let name: String
    let memberIDs: [String]
}

private struct AddMemberRequest: Encodable {
    let name: String
}
