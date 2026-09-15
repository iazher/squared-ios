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

    static let fourthUser = User(
        id: "user-4",
        name: "Morgan Blake",
        email: "morgan@example.com",
        avatarURL: nil
    )

    static let fifthUser = User(
        id: "user-5",
        name: "Casey Nguyen",
        email: "casey@example.com",
        avatarURL: nil
    )

    static let sixthUser = User(
        id: "user-6",
        name: "Riley Thompson",
        email: "riley@example.com",
        avatarURL: nil
    )

    static let seventhUser = User(
        id: "user-7",
        name: "Avery Martinez",
        email: "avery@example.com",
        avatarURL: nil
    )

    static let eighthUser = User(
        id: "user-8",
        name: "Drew Sullivan",
        email: "drew@example.com",
        avatarURL: nil
    )

    static let users: [User] = [currentUser, otherUser, thirdUser, fourthUser, fifthUser, sixthUser, seventhUser, eighthUser]

    static let groups: [Group] = [
        // Five members — exercises the avatar cluster's overflow ("+N") state.
        Group(
            id: "group-1",
            name: "Trip to Lisbon",
            memberIDs: [currentUser.id, otherUser.id, thirdUser.id, fourthUser.id, fifthUser.id],
            createdAt: Date(timeIntervalSinceNow: -86_400 * 10)
        ),
        // Current user owes here (net negative) — exercises the "owes" red path.
        Group(
            id: "group-2",
            name: "Apartment — SF",
            memberIDs: [currentUser.id, otherUser.id],
            createdAt: Date(timeIntervalSinceNow: -86_400 * 20)
        ),
        // Eight members, all sharing expenses with each other — a denser group
        // than Trip to Lisbon's five.
        Group(
            id: "group-3",
            name: "Ski Trip",
            memberIDs: [
                currentUser.id, otherUser.id, thirdUser.id, fourthUser.id,
                fifthUser.id, sixthUser.id, seventhUser.id, eighthUser.id
            ],
            createdAt: Date(timeIntervalSinceNow: -86_400 * 4)
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
            id: "expense-6",
            groupID: groups[0].id,
            title: "Museum Tickets",
            amount: 50.00,
            paidByUserID: fourthUser.id,
            splitMethod: .equal,
            splits: [
                ExpenseSplit(userID: currentUser.id, amount: 10.00),
                ExpenseSplit(userID: otherUser.id, amount: 10.00),
                ExpenseSplit(userID: thirdUser.id, amount: 10.00),
                ExpenseSplit(userID: fourthUser.id, amount: 10.00),
                ExpenseSplit(userID: fifthUser.id, amount: 10.00)
            ],
            createdAt: Date(timeIntervalSinceNow: -86_400 * 1)
        ),
        Expense(
            id: "expense-7",
            groupID: groups[0].id,
            title: "Breakfast",
            amount: 40.00,
            paidByUserID: fifthUser.id,
            splitMethod: .equal,
            splits: [
                ExpenseSplit(userID: currentUser.id, amount: 8.00),
                ExpenseSplit(userID: otherUser.id, amount: 8.00),
                ExpenseSplit(userID: thirdUser.id, amount: 8.00),
                ExpenseSplit(userID: fourthUser.id, amount: 8.00),
                ExpenseSplit(userID: fifthUser.id, amount: 8.00)
            ],
            createdAt: Date(timeIntervalSinceNow: -86_400 * 3)
        ),
        Expense(
            id: "expense-8",
            groupID: groups[0].id,
            title: "Train Tickets",
            amount: 150.00,
            paidByUserID: currentUser.id,
            splitMethod: .equal,
            splits: [
                ExpenseSplit(userID: currentUser.id, amount: 30.00),
                ExpenseSplit(userID: otherUser.id, amount: 30.00),
                ExpenseSplit(userID: thirdUser.id, amount: 30.00),
                ExpenseSplit(userID: fourthUser.id, amount: 30.00),
                ExpenseSplit(userID: fifthUser.id, amount: 30.00)
            ],
            createdAt: Date(timeIntervalSinceNow: -86_400 * 6)
        ),
        Expense(
            id: "expense-9",
            groupID: groups[0].id,
            title: "Souvenirs",
            amount: 75.00,
            paidByUserID: otherUser.id,
            splitMethod: .equal,
            splits: [
                ExpenseSplit(userID: currentUser.id, amount: 15.00),
                ExpenseSplit(userID: otherUser.id, amount: 15.00),
                ExpenseSplit(userID: thirdUser.id, amount: 15.00),
                ExpenseSplit(userID: fourthUser.id, amount: 15.00),
                ExpenseSplit(userID: fifthUser.id, amount: 15.00)
            ],
            createdAt: Date(timeIntervalSinceNow: -86_400 * 8)
        ),
        Expense(
            id: "expense-10",
            groupID: groups[0].id,
            title: "Airport Transfer",
            amount: 100.00,
            paidByUserID: thirdUser.id,
            splitMethod: .equal,
            splits: [
                ExpenseSplit(userID: currentUser.id, amount: 20.00),
                ExpenseSplit(userID: otherUser.id, amount: 20.00),
                ExpenseSplit(userID: thirdUser.id, amount: 20.00),
                ExpenseSplit(userID: fourthUser.id, amount: 20.00),
                ExpenseSplit(userID: fifthUser.id, amount: 20.00)
            ],
            createdAt: Date(timeIntervalSinceNow: -86_400 * 11)
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
        ),
        // Ski Trip: each expense is paid by a different member and split
        // equally across all 8, netting out to debts between many pairs.
        Expense(
            id: "expense-11",
            groupID: groups[2].id,
            title: "Chalet Rental",
            amount: 160.00,
            paidByUserID: currentUser.id,
            splitMethod: .equal,
            splits: allEightSplits(amountPerPerson: 20.00),
            createdAt: Date(timeIntervalSinceNow: -86_400 * 4)
        ),
        Expense(
            id: "expense-12",
            groupID: groups[2].id,
            title: "Lift Passes",
            amount: 80.00,
            paidByUserID: otherUser.id,
            splitMethod: .equal,
            splits: allEightSplits(amountPerPerson: 10.00),
            createdAt: Date(timeIntervalSinceNow: -86_400 * 3.5)
        ),
        Expense(
            id: "expense-13",
            groupID: groups[2].id,
            title: "Ski Rentals",
            amount: 240.00,
            paidByUserID: thirdUser.id,
            splitMethod: .equal,
            splits: allEightSplits(amountPerPerson: 30.00),
            createdAt: Date(timeIntervalSinceNow: -86_400 * 3)
        ),
        Expense(
            id: "expense-14",
            groupID: groups[2].id,
            title: "Groceries",
            amount: 56.00,
            paidByUserID: fourthUser.id,
            splitMethod: .equal,
            splits: allEightSplits(amountPerPerson: 7.00),
            createdAt: Date(timeIntervalSinceNow: -86_400 * 2.5)
        ),
        Expense(
            id: "expense-15",
            groupID: groups[2].id,
            title: "Dinner Out",
            amount: 120.00,
            paidByUserID: fifthUser.id,
            splitMethod: .equal,
            splits: allEightSplits(amountPerPerson: 15.00),
            createdAt: Date(timeIntervalSinceNow: -86_400 * 2)
        ),
        Expense(
            id: "expense-16",
            groupID: groups[2].id,
            title: "Hot Tub Rental",
            amount: 88.00,
            paidByUserID: sixthUser.id,
            splitMethod: .equal,
            splits: allEightSplits(amountPerPerson: 11.00),
            createdAt: Date(timeIntervalSinceNow: -86_400 * 1.5)
        ),
        Expense(
            id: "expense-17",
            groupID: groups[2].id,
            title: "Gas",
            amount: 64.00,
            paidByUserID: seventhUser.id,
            splitMethod: .equal,
            splits: allEightSplits(amountPerPerson: 8.00),
            createdAt: Date(timeIntervalSinceNow: -86_400 * 1)
        ),
        Expense(
            id: "expense-18",
            groupID: groups[2].id,
            title: "Lodge Dinner",
            amount: 200.00,
            paidByUserID: eighthUser.id,
            splitMethod: .equal,
            splits: allEightSplits(amountPerPerson: 25.00),
            createdAt: Date(timeIntervalSinceNow: -86_400 * 0.5)
        )
    ]

    /// One equal split per Ski Trip member, all at the same per-person amount.
    private static func allEightSplits(amountPerPerson: Decimal) -> [ExpenseSplit] {
        [currentUser, otherUser, thirdUser, fourthUser, fifthUser, sixthUser, seventhUser, eighthUser]
            .map { ExpenseSplit(userID: $0.id, amount: amountPerPerson) }
    }

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
