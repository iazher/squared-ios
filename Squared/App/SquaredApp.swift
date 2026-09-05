//
//  SquaredApp.swift
//  Squared
//
//  Created by Iman Azher on 05/09/2026.
//

import SwiftUI

@main
struct SquaredApp: App {
    var body: some Scene {
        WindowGroup {
            // TODO: switch to `.live` once the real backend exists.
            RootView(dependencies: .mock)
        }
    }
}
