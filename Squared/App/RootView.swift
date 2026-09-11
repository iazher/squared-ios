//
//  RootView.swift
//  Squared
//

import SwiftUI

/// The app's root state machine: signedOut -> loading -> signedIn.
struct RootView: View {
    @State private var flowState: AppFlowState = .signedOut
    @State private var appState: AppState
    private let dependencies: AppDependencies

    init(dependencies: AppDependencies = .mock) {
        self.dependencies = dependencies
        _appState = State(initialValue: AppState(
            authService: dependencies.authService,
            usersService: dependencies.usersService,
            groupsService: dependencies.groupsService,
            expensesService: dependencies.expensesService,
            settlementService: dependencies.settlementService
        ))
    }

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        switch flowState {
        case .signedOut:
            SignInView(authService: dependencies.authService, onSignedIn: handleSignedIn)
        case .loading:
            LoadingView()
        case .signedIn:
            MainTabView(appState: appState, dependencies: dependencies, onSignedOut: handleSignedOut)
        }
    }

    private func handleSignedIn(_ user: User) {
        flowState = .loading
        Task {
            await appState.performInitialFetch()
            flowState = .signedIn
        }
    }

    private func handleSignedOut() {
        flowState = .signedOut
    }
}

#Preview {
    RootView()
}
