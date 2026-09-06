//
//  AppDependencies.swift
//  Squared
//

import Foundation

/// Wires concrete Service implementations to an `APIClient`.
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
