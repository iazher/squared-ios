//
//  LoadingView.swift
//  Squared
//

import SwiftUI

/// Shown only between a successful sign-in and the main TabView, while
/// `AppState` performs its one-time initial fetch. This is the single
/// exception to the "no spinners for AppState data" rule — every other
/// screen assumes that data is already available by the time it appears.
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Setting things up…")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    LoadingView()
}
