//
//  MainTabView.swift
//  Squared
//

import SwiftUI

/// The signed-in shell. Composes each feature's root view, handing down
/// `AppState` and the Services those features need for mutations.
struct MainTabView: View {
    let appState: AppState
    let dependencies: AppDependencies
    let onSignedOut: () -> Void

    var body: some View {
        TabView {
            GroupsListView(
                appState: appState,
                groupsService: dependencies.groupsService,
                expensesService: dependencies.expensesService,
                settlementService: dependencies.settlementService
            )
            .tabItem { Label("Groups", systemImage: "person.3") }

            SettingsView(
                appState: appState,
                authService: dependencies.authService,
                settingsService: dependencies.settingsService,
                onSignedOut: onSignedOut
            )
            .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
