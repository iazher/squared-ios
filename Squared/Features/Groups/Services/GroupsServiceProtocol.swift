//
//  GroupsServiceProtocol.swift
//  Squared
//

protocol GroupsServiceProtocol {
    func fetchGroups() async throws -> [Group]
    func createGroup(name: String, memberIDs: [String]) async throws -> Group
}
