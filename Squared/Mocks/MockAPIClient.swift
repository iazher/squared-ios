//
//  MockAPIClient.swift
//  Squared
//

import Foundation

/// Stands in for `URLSessionAPIClient` before the real backend exists.
final class MockAPIClient: APIClient {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let sample: Any

        switch (endpoint.method, endpoint.path) {
        case (.get, "/auth/me"), (.post, "/auth/sign-in"):
            sample = activeCurrentUser
        case (.get, "/users"):
            sample = activeUsers
        case (.put, "/users/me"):
            if let body = endpoint.body,
               let payload = try? JSONDecoder().decode(User.self, from: body) {
                sample = payload
            } else {
                throw NetworkError.invalidResponse
            }
        case (.post, "/auth/sign-out"):
            sample = EmptyResponse()
        case (.get, "/groups"):
            sample = activeGroups
        case (.post, "/groups"):
            if let body = endpoint.body,
               let payload = try? JSONDecoder().decode(GroupCreationPayload.self, from: body) {
                sample = Group(id: UUID().uuidString, name: payload.name, memberIDs: payload.memberIDs, createdAt: Date())
            } else {
                sample = MockData.groups[0]
            }
        case (.get, "/expenses"):
            sample = activeExpenses
        case (.post, "/expenses"):
            if let body = endpoint.body,
               let payload = try? JSONDecoder().decode(CreateExpensePayload.self, from: body) {
                sample = Expense(
                    id: UUID().uuidString,
                    groupID: payload.groupID,
                    title: payload.title,
                    amount: payload.amount,
                    paidByUserID: payload.paidByUserID,
                    splitMethod: payload.splitMethod,
                    splits: payload.splits,
                    createdAt: Date()
                )
            } else {
                throw NetworkError.invalidResponse
            }
        case let (.delete, path) where path.hasPrefix("/expenses/"):
            sample = EmptyResponse()
        case (.get, "/settlement/balances"):
            sample = activeBalances
        case (.post, "/settlement/settlements"):
            if let body = endpoint.body,
               let payload = try? JSONDecoder().decode(RecordSettlementPayload.self, from: body) {
                sample = Settlement(
                    id: UUID().uuidString,
                    groupID: payload.groupID,
                    fromUserID: payload.fromUserID,
                    toUserID: payload.toUserID,
                    amount: payload.amount,
                    settledAt: Date()
                )
            } else {
                throw NetworkError.invalidResponse
            }
        case (.get, "/settings/preferences"):
            sample = MockData.preferences
        case (.put, "/settings/preferences"):
            if let body = endpoint.body,
               let payload = try? JSONDecoder().decode(UserPreferences.self, from: body) {
                sample = payload
            } else {
                throw NetworkError.invalidResponse
            }
        case let (.post, path) where path.hasPrefix("/groups/") && path.hasSuffix("/members"):
            if let body = endpoint.body,
               let payload = try? JSONDecoder().decode(AddMemberPayload.self, from: body) {
                sample = User(id: UUID().uuidString, name: payload.name, email: "", avatarURL: nil)
            } else {
                throw NetworkError.invalidResponse
            }
        case let (.delete, path) where path.hasPrefix("/groups/") && path.contains("/members/"):
            sample = EmptyResponse()
        default:
            throw NetworkError.invalidResponse
        }

        guard let typed = sample as? T else {
            throw NetworkError.decodingFailed
        }
        return typed
    }

    private var activeCurrentUser: User {
        #if DEBUG
        if MockScenario.current == .newUser { return NewUserMockData.currentUser }
        #endif
        return MockData.currentUser
    }

    private var activeUsers: [User] {
        #if DEBUG
        if MockScenario.current == .newUser { return NewUserMockData.users }
        #endif
        return MockData.users
    }

    private var activeGroups: [Group] {
        #if DEBUG
        if MockScenario.current == .newUser { return NewUserMockData.groups }
        #endif
        return MockData.groups
    }

    private var activeExpenses: [Expense] {
        #if DEBUG
        if MockScenario.current == .newUser { return NewUserMockData.expenses }
        #endif
        return MockData.expenses
    }

    private var activeBalances: [Balance] {
        #if DEBUG
        if MockScenario.current == .newUser { return NewUserMockData.balances }
        #endif
        return MockData.balances
    }
}

private struct GroupCreationPayload: Decodable {
    let name: String
    let memberIDs: [String]
}

private struct AddMemberPayload: Decodable {
    let name: String
}

private struct CreateExpensePayload: Decodable {
    let groupID: String
    let title: String
    let amount: Decimal
    let paidByUserID: String
    let splitMethod: SplitMethod
    let splits: [ExpenseSplit]
}

private struct RecordSettlementPayload: Decodable {
    let groupID: String
    let fromUserID: String
    let toUserID: String
    let amount: Decimal
}
