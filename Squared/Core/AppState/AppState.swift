//
//  AppState.swift
//  Squared
//

import Observation

/// The single source of truth for shared, cross-feature data.
@Observable
final class AppState {
    private(set) var currentUser: User?
    private(set) var groups: [Group] = []
    private(set) var expenses: [Expense] = []
    private(set) var balances: [Balance] = []

    /// True only while the one-time post-sign-in fetch is running.
    private(set) var isPerformingInitialFetch = false

    private let authService: AuthServiceProtocol
    private let groupsService: GroupsServiceProtocol
    private let expensesService: ExpensesServiceProtocol
    private let settlementService: SettlementServiceProtocol

    init(
        authService: AuthServiceProtocol,
        groupsService: GroupsServiceProtocol,
        expensesService: ExpensesServiceProtocol,
        settlementService: SettlementServiceProtocol
    ) {
        self.authService = authService
        self.groupsService = groupsService
        self.expensesService = expensesService
        self.settlementService = settlementService
    }

    // MARK: - Initial fetch

    /// Called once by `RootView` after a successful sign-in.
    func performInitialFetch() async {
        isPerformingInitialFetch = true
        defer { isPerformingInitialFetch = false }

        async let fetchedUser = fetchCurrentUser()
        async let fetchedGroups = fetchGroups()
        async let fetchedExpenses = fetchExpenses()
        async let fetchedBalances = fetchBalances()

        currentUser = await fetchedUser
        groups = await fetchedGroups
        expenses = await fetchedExpenses
        balances = await fetchedBalances
    }

    /// Called on sign-out to clear shared state before returning to `.signedOut`.
    func reset() {
        currentUser = nil
        groups = []
        expenses = []
        balances = []
    }

    // MARK: - Mutation sync points

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
    }

    func setGroups(_ groups: [Group]) {
        self.groups = groups
    }

    func setBalances(_ balances: [Balance]) {
        self.balances = balances
    }

    // MARK: - Placeholder fetches
    // TODO: these currently just delegate to the injected Services. Fill in
    // any additional composition/error-handling logic as the real backend
    // contract is defined.

    private func fetchCurrentUser() async -> User? {
        try? await authService.fetchCurrentUser()
    }

    private func fetchGroups() async -> [Group] {
        (try? await groupsService.fetchGroups()) ?? []
    }

    private func fetchExpenses() async -> [Expense] {
        (try? await expensesService.fetchExpenses()) ?? []
    }

    private func fetchBalances() async -> [Balance] {
        (try? await settlementService.fetchBalances()) ?? []
    }
}
