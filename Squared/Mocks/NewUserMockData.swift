//
//  NewUserMockData.swift
//  Squared
//

import Foundation

#if DEBUG
/// A brand-new signed-in user with no groups, expenses, or balances yet —
/// served instead of `MockData` when launched with `-mockScenario newUser`,
/// for exercising empty states through real app actions.
enum NewUserMockData {
    static let currentUser = User(id: "new-user-1", name: "Jamie Newcomer", email: "jamie@example.com", avatarURL: nil)
    static let users: [User] = [currentUser]
    static let groups: [Group] = []
    static let expenses: [Expense] = []
    static let balances: [Balance] = []
}
#endif
