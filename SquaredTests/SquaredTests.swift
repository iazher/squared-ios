//
//  SquaredTests.swift
//  SquaredTests
//
//  Created by Iman Azher on 05/09/2026.
//

import Testing
@testable import Squared

struct SquaredTests {

    /// Exercises the exact path `RootView` relies on after a successful
    /// sign-in: `AppState.performInitialFetch()` against the mock service
    /// stack. If this silently failed to populate state, or hung, or threw,
    /// the loading -> signedIn transition would never fire in the real app.
    @Test func performInitialFetchPopulatesAppState() async throws {
        let apiClient = MockAPIClient()
        let appState = AppState(
            authService: AuthService(apiClient: apiClient),
            groupsService: GroupsService(apiClient: apiClient),
            expensesService: ExpensesService(apiClient: apiClient),
            settlementService: SettlementService(apiClient: apiClient)
        )

        #expect(appState.currentUser == nil)
        #expect(appState.groups.isEmpty)
        #expect(appState.expenses.isEmpty)
        #expect(appState.balances.isEmpty)
        #expect(appState.isPerformingInitialFetch == false)

        await appState.performInitialFetch()

        #expect(appState.isPerformingInitialFetch == false)
        #expect(appState.currentUser == MockData.currentUser)
        #expect(appState.groups == MockData.groups)
        #expect(appState.expenses == MockData.expenses)
        #expect(appState.balances == MockData.balances)
    }

    @Test func resetClearsAppState() async throws {
        let apiClient = MockAPIClient()
        let appState = AppState(
            authService: AuthService(apiClient: apiClient),
            groupsService: GroupsService(apiClient: apiClient),
            expensesService: ExpensesService(apiClient: apiClient),
            settlementService: SettlementService(apiClient: apiClient)
        )

        await appState.performInitialFetch()
        #expect(appState.currentUser != nil)

        appState.reset()

        #expect(appState.currentUser == nil)
        #expect(appState.groups.isEmpty)
        #expect(appState.expenses.isEmpty)
        #expect(appState.balances.isEmpty)
    }
}
