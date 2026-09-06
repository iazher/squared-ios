//
//  LoadingView.swift
//  Squared
//

import SwiftUI

/// Shown only between a successful sign-in and the main TabView.
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.white)
            Text("Setting things up…")
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackground").ignoresSafeArea())
    }
}

#Preview {
    LoadingView()
}
