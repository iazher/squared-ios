//
//  AppDependencies.swift
//  Squared
//

import Foundation

/// Wires concrete Service implementations to an `APIClient`. Swap `.mock` for
/// `.live` in `SquaredApp` once the real backend exists — nothing else in the
/// app needs to change, since every feature depends on the `*ServiceProtocol`
/// abstractions rather than these concrete types.
struct AppDependencies {
    let apiClient: APIClient
    let authService: AuthServiceProtocol
    let groupsService: GroupsServiceProtocol
    let expensesService: ExpensesServiceProtocol
    let settlementService: SettlementServiceProtocol
    let settingsService: SettingsServiceProtocol

    static var live: AppDependencies {
        // TODO: replace with the real API base URL once the backend exists.
        let apiClient = URLSessionAPIClient(baseURL: URL(string: "https://api.squared.app")!)
        return make(apiClient: apiClient)
    }

    static var mock: AppDependencies {
        make(apiClient: MockAPIClient())
    }

    private static func make(apiClient: APIClient) -> AppDependencies {
        AppDependencies(
            apiClient: apiClient,
            authService: AuthService(apiClient: apiClient),
            groupsService: GroupsService(apiClient: apiClient),
            expensesService: ExpensesService(apiClient: apiClient),
            settlementService: SettlementService(apiClient: apiClient),
            settingsService: SettingsService(apiClient: apiClient)
        )
    }
}
