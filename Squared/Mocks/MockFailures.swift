//
//  MockFailures.swift
//  Squared
//

import Foundation

#if DEBUG
/// Makes `MockAPIClient` throw on demand, via the `-mockFailures <mode>`
/// launch argument, so error-handling UI can be exercised without a real
/// backend. Two modes because a blanket throw would block the initial fetch
/// and leave nothing else reachable to test:
/// - `launch`: only requests made during `AppState.performInitialFetch()` fail.
/// - `afterLaunch`: initial fetch succeeds; every request after it fails.
enum MockFailures {
    enum Mode {
        case off
        case launch
        case afterLaunch
    }

    static let mode: Mode = {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-mockFailures"), index + 1 < arguments.count else {
            return .off
        }
        switch arguments[index + 1] {
        case "launch": return .launch
        case "afterLaunch": return .afterLaunch
        default: return .off
        }
    }()

    /// Flipped by `AppState.performInitialFetch()` once it finishes, success or
    /// not — so for `.launch`, only the very first attempt fails: after that
    /// attempt's `defer` runs, `shouldThrow` goes false and a Retry succeeds.
    static var hasCompletedInitialFetch = false

    static var shouldThrow: Bool {
        switch mode {
        case .off: return false
        case .launch: return !hasCompletedInitialFetch
        case .afterLaunch: return hasCompletedInitialFetch
        }
    }
}
#endif
