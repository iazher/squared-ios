//
//  MockData.swift
//  Squared
//

import Foundation

/// Hardcoded sample data used by `MockAPIClient`.
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

    static let thirdUser = User(
        id: "user-3",
        name: "Jordan Lee",
        email: "jordan@example.com",
        avatarURL: nil
    )

    static let groups: [Group] = [
        Group(
            id: "group-1",
            name: "Trip to Lisbon",
            memberIDs: [currentUser.id, otherUser.id, thirdUser.id],
            createdAt: Date(timeIntervalSinceNow: -86_400 * 10)
        ),
        // Current user owes here (net negative) — exercises the "owes" red path.
        Group(
            id: "group-2",
            name: "Apartment — SF",
            memberIDs: [currentUser.id, otherUser.id],
            createdAt: Date(timeIntervalSinceNow: -86_400 * 20)
        )
    ]

    // Covers all three split methods.
    static let expenses: [Expense] = [
        Expense(
            id: "expense-1",
            groupID: groups[0].id,
            title: "Hotel",
            amount: 240.00,
            paidByUserID: currentUser.id,
            splitMethod: .equal,
            splits: [
                ExpenseSplit(userID: currentUser.id, amount: 80.00),
                ExpenseSplit(userID: otherUser.id, amount: 80.00),
                ExpenseSplit(userID: thirdUser.id, amount: 80.00)
            ],
            createdAt: Date(timeIntervalSinceNow: -86_400 * 9)
        ),
        Expense(
            id: "expense-2",
            groupID: groups[0].id,
            title: "Dinner",
            amount: 96.00,
            paidByUserID: otherUser.id,
            splitMethod: .exact,
            splits: [
                ExpenseSplit(userID: currentUser.id, amount: 40.00),
                ExpenseSplit(userID: otherUser.id, amount: 36.00),
                ExpenseSplit(userID: thirdUser.id, amount: 20.00)
            ],
            createdAt: Date(timeIntervalSinceNow: -86_400 * 7)
        ),
        Expense(
            id: "expense-3",
            groupID: groups[0].id,
            title: "Taxi",
            amount: 45.00,
            paidByUserID: thirdUser.id,
            splitMethod: .percentage,
            // 50% / 30% / 20% of $45, resolved to exact dollar amounts.
            splits: [
                ExpenseSplit(userID: currentUser.id, amount: 22.50),
                ExpenseSplit(userID: otherUser.id, amount: 13.50),
                ExpenseSplit(userID: thirdUser.id, amount: 9.00)
            ],
            createdAt: Date(timeIntervalSinceNow: -86_400 * 5)
        ),
        Expense(
            id: "expense-4",
            groupID: groups[0].id,
            title: "Groceries",
            amount: 60.00,
            paidByUserID: currentUser.id,
            splitMethod: .equal,
            // Only two of the three members were involved in this one.
            splits: [
                ExpenseSplit(userID: currentUser.id, amount: 30.00),
                ExpenseSplit(userID: otherUser.id, amount: 30.00)
            ],
            createdAt: Date(timeIntervalSinceNow: -86_400 * 2)
        ),
        Expense(
            id: "expense-5",
            groupID: groups[1].id,
            title: "Wifi Bill",
            amount: 90.00,
            paidByUserID: otherUser.id,
            splitMethod: .equal,
            splits: [
                ExpenseSplit(userID: currentUser.id, amount: 45.00),
                ExpenseSplit(userID: otherUser.id, amount: 45.00)
            ],
            createdAt: Date(timeIntervalSinceNow: -86_400 * 3)
        )
    ]

    static let balances: [Balance] = [
        Balance(
            groupID: groups[0].id,
            fromUserID: otherUser.id,
            toUserID: currentUser.id,
            amount: 70.00
        ),
        Balance(
            groupID: groups[0].id,
            fromUserID: thirdUser.id,
            toUserID: currentUser.id,
            amount: 96.50
        ),
        Balance(
            groupID: groups[1].id,
            fromUserID: currentUser.id,
            toUserID: otherUser.id,
            amount: 45.00
        )
    ]

    static let settlement = Settlement(
        id: "settlement-1",
        groupID: groups[0].id,
        fromUserID: otherUser.id,
        toUserID: currentUser.id,
        amount: 70.00,
        settledAt: Date(timeIntervalSinceNow: -86_400)
    )

    static let preferences = UserPreferences(
        preferredCurrencyCode: "USD",
        notificationsEnabled: true
    )
}
