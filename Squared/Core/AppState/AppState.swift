//
//  AppState.swift
//  Squared
//

import Foundation
import Observation

/// The single source of truth for shared, cross-feature data.
@Observable
final class AppState {
    private(set) var currentUser: User?
    private(set) var users: [User] = []
    private(set) var groups: [Group] = []
    private(set) var expenses: [Expense] = []
    private(set) var balances: [Balance] = []

    /// True only while the one-time post-sign-in fetch is running.
    private(set) var isPerformingInitialFetch = false

    private let authService: AuthServiceProtocol
    private let usersService: UsersServiceProtocol
    private let groupsService: GroupsServiceProtocol
    private let expensesService: ExpensesServiceProtocol

    init(
        authService: AuthServiceProtocol,
        usersService: UsersServiceProtocol,
        groupsService: GroupsServiceProtocol,
        expensesService: ExpensesServiceProtocol
    ) {
        self.authService = authService
        self.usersService = usersService
        self.groupsService = groupsService
        self.expensesService = expensesService
    }

    // MARK: - Initial fetch

    /// Called once by `RootView` after a successful sign-in.
    func performInitialFetch() async {
        isPerformingInitialFetch = true
        defer { isPerformingInitialFetch = false }

        async let fetchedUser = fetchCurrentUser()
        async let fetchedUsers = fetchUsers()
        async let fetchedGroups = fetchGroups()
        async let fetchedExpenses = fetchExpenses()

        currentUser = await fetchedUser
        users = await fetchedUsers
        groups = await fetchedGroups
        expenses = await fetchedExpenses
        recomputeBalances()
    }

    /// Called on sign-out to clear shared state before returning to `.signedOut`.
    func reset() {
        currentUser = nil
        users = []
        groups = []
        expenses = []
        balances = []
    }

    // MARK: - Mutation sync points

    func upsert(user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        } else {
            users.append(user)
        }
    }

    func upsert(group: Group) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index] = group
        } else {
            groups.append(group)
        }
    }

    func upsert(expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
        } else {
            expenses.append(expense)
        }
        recomputeBalances()
    }

    func setGroups(_ groups: [Group]) {
        self.groups = groups
    }

    /// TEMPORARY mock-stage substitute for a real balances fetch: nets each
    /// expense's splits against its payer, pairwise, per group. This is not
    /// debt simplification (no multi-party reduction) — replace with a real
    /// fetch once the backend's simplify_debts() endpoint exists.
    func recomputeBalances() {
        balances = Self.computeBalances(from: expenses)
    }

    private static func computeBalances(from expenses: [Expense]) -> [Balance] {
        struct PairKey: Hashable {
            let groupID: String
            let lowUserID: String
            let highUserID: String
        }

        // Positive means `highUserID` owes `lowUserID`; negative means the reverse.
        var net: [PairKey: Decimal] = [:]

        for expense in expenses {
            for split in expense.splits where split.userID != expense.paidByUserID {
                let debtor = split.userID
                let creditor = expense.paidByUserID
                let low = min(debtor, creditor)
                let high = max(debtor, creditor)
                let key = PairKey(groupID: expense.groupID, lowUserID: low, highUserID: high)
                let delta = debtor == high ? split.amount : -split.amount
                net[key, default: .zero] += delta
            }
        }

        return net.compactMap { key, amount in
            guard amount != 0 else { return nil }
            if amount > 0 {
                return Balance(groupID: key.groupID, fromUserID: key.highUserID, toUserID: key.lowUserID, amount: amount)
            } else {
                return Balance(groupID: key.groupID, fromUserID: key.lowUserID, toUserID: key.highUserID, amount: -amount)
            }
        }
    }

    // MARK: - Placeholder fetches
    // TODO: these currently just delegate to the injected Services. Fill in
    // any additional composition/error-handling logic as the real backend
    // contract is defined.

    private func fetchCurrentUser() async -> User? {
        try? await authService.fetchCurrentUser()
    }

    private func fetchUsers() async -> [User] {
        (try? await usersService.fetchUsers()) ?? []
    }

    private func fetchGroups() async -> [Group] {
        (try? await groupsService.fetchGroups()) ?? []
    }

    private func fetchExpenses() async -> [Expense] {
        (try? await expensesService.fetchExpenses()) ?? []
    }
}
