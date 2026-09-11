//
//  SquaredTests.swift
//  SquaredTests
//
//  Created by Iman Azher on 05/09/2026.
//

import Foundation
import Testing
@testable import Squared

struct SquaredTests {

    /// Exercises the exact path `RootView` relies on: `AppState.performInitialFetch()`.
    @Test func performInitialFetchPopulatesAppState() async throws {
        let apiClient = MockAPIClient()
        let appState = AppState(
            authService: AuthService(apiClient: apiClient),
            usersService: UsersService(apiClient: apiClient),
            groupsService: GroupsService(apiClient: apiClient),
            expensesService: ExpensesService(apiClient: apiClient)
        )

        #expect(appState.currentUser == nil)
        #expect(appState.users.isEmpty)
        #expect(appState.groups.isEmpty)
        #expect(appState.expenses.isEmpty)
        #expect(appState.balances.isEmpty)
        #expect(appState.isPerformingInitialFetch == false)

        await appState.performInitialFetch()

        #expect(appState.isPerformingInitialFetch == false)
        #expect(appState.currentUser == MockData.currentUser)
        #expect(appState.users == MockData.users)
        #expect(appState.groups == MockData.groups)
        #expect(appState.expenses == MockData.expenses)
        // Balances are now derived from expenses (temporary mock-stage calculation),
        // not fetched — check the one easy-to-hand-verify case rather than reimplementing
        // the netting logic here. "Apartment — SF" has a single $90 Wifi Bill paid by
        // Sam Rivera, split evenly, so Alex owes Sam exactly $45.
        let apartmentWifiDebt = Balance(
            groupID: MockData.groups[1].id,
            fromUserID: MockData.currentUser.id,
            toUserID: MockData.otherUser.id,
            amount: 45.00
        )
        #expect(appState.balances.contains(apartmentWifiDebt))
    }

    @Test func resetClearsAppState() async throws {
        let apiClient = MockAPIClient()
        let appState = AppState(
            authService: AuthService(apiClient: apiClient),
            usersService: UsersService(apiClient: apiClient),
            groupsService: GroupsService(apiClient: apiClient),
            expensesService: ExpensesService(apiClient: apiClient)
        )

        await appState.performInitialFetch()
        #expect(appState.currentUser != nil)

        appState.reset()

        #expect(appState.currentUser == nil)
        #expect(appState.users.isEmpty)
        #expect(appState.groups.isEmpty)
        #expect(appState.expenses.isEmpty)
        #expect(appState.balances.isEmpty)
    }
}
