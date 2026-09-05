//
//  MockData.swift
//  Squared
//

import Foundation

/// Hardcoded sample data used by `MockAPIClient` so the app can be built and
/// exercised end-to-end before the real backend exists.
enum MockData {
    static let currentUser = User(
        id: "user-1",
        name: "Alex Chen",
        email: "alex@example.com",
        avatarURL: nil
    )

    static let otherUser = User(
        id: "user-2",
        name: "Sam Rivera",
        email: "sam@example.com",
        avatarURL: nil
    )

    static let groups: [Group] = [
        Group(
            id: "group-1",
            name: "Trip to Lisbon",
            memberIDs: [currentUser.id, otherUser.id],
            createdAt: Date(timeIntervalSinceNow: -86_400 * 10)
        )
    ]

    static let expenses: [Expense] = [
        Expense(
            id: "expense-1",
            groupID: groups[0].id,
            title: "Hotel",
            amount: 240.00,
            paidByUserID: currentUser.id,
            splitBetweenUserIDs: [currentUser.id, otherUser.id],
            createdAt: Date(timeIntervalSinceNow: -86_400 * 9)
        )
    ]

    static let balances: [Balance] = [
        Balance(
            groupID: groups[0].id,
            fromUserID: otherUser.id,
            toUserID: currentUser.id,
            amount: 120.00
        )
    ]

    static let settlement = Settlement(
        id: "settlement-1",
        groupID: groups[0].id,
        fromUserID: otherUser.id,
        toUserID: currentUser.id,
        amount: 120.00,
        settledAt: Date(timeIntervalSinceNow: -86_400)
    )

    static let preferences = UserPreferences(
        preferredCurrencyCode: "USD",
        notificationsEnabled: true
    )
}
