//
//  AppFlowState.swift
//  Squared
//

/// The three states `RootView` switches on. `.loading` is the dedicated screen
/// shown between a successful sign-in and the main TabView, while `AppState`
/// performs its one-time initial fetch.
enum AppFlowState {
    case signedOut
    case loading
    case signedIn
}
