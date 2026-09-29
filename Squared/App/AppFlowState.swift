//
//  AppFlowState.swift
//  Squared
//

/// The states `RootView` switches on.
enum AppFlowState {
    case signedOut
    case loading
    case loadingFailed(String)
    case signedIn
}
