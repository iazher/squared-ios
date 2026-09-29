//
//  InitialFetchErrorView.swift
//  Squared
//

import SwiftUI

/// Shown when the post-sign-in fetch fails, so the user can retry without
/// being kicked back to the sign-in screen.
struct InitialFetchErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.3))
            Text("Couldn't load your data")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
            GradientButton(title: "Retry", action: onRetry)
                .padding(.horizontal, 40)
                .padding(.top, 8)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackground").ignoresSafeArea())
    }
}

#Preview {
    InitialFetchErrorView(message: "Couldn't reach the server. Check your connection and try again.") {}
}
