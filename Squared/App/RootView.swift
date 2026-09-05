//
//  RootView.swift
//  Squared
//

import SwiftUI

/// The app's root state machine: signedOut -> loading -> signedIn.
///
/// This is the one place that decides *when* `AppState` performs its initial
/// fetch — on a successful sign-in, not on any individual screen's appearance.
/// `LoadingView` is shown for the duration of that fetch so no other screen
/// needs its own loading state for AppState-backed data.
struct RootView: View {
    @State private var flowState: AppFlowState = .signedOut
    @State private var appState: AppState
    private let dependencies: AppDependencies

    init(dependencies: AppDependencies = .mock) {
        self.dependencies = dependencies
        _appState = State(initialValue: AppState(
            authService: dependencies.authService,
            groupsService: dependencies.groupsService,
            expensesService: dependencies.expensesService,
            settlementService: dependencies.settlementService
        ))
    }

    // `appState` is threaded down explicitly through view/view-model initializers
    // rather than read back via `@Environment` — see AppState.swift for why.
    var body: some View {
        content
    }

    // Not wrapped in a `Group` view: this module also defines a domain `Group`
    // model (see Features/Groups/Models/Group.swift), which shadows `SwiftUI.Group`
    // for unqualified lookups here. A `@ViewBuilder` property sidesteps the collision.
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
