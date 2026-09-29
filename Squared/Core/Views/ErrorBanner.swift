//
//  ErrorBanner.swift
//  Squared
//

import SwiftUI
import UIKit

/// Shared banner for a failed request — every form sheet and the Groups list's
/// pull-to-refresh use this one view. Styled as a card, not a full-bleed red
/// block, so it reads as an accent (red is already "you owe" elsewhere) and
/// can't visually bleed through a translucent nav bar placed above it.
struct ErrorBanner: View {
    let message: String
    /// Defaults to the list-row card color; form sheets pass the Form's own
    /// section color instead, so the banner reads as native to its context.
    var background: Color = Color("CardSurface")
    let onRetry: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 8)

            Button("Retry", action: onRetry)
                .font(.subheadline.bold())
                .foregroundStyle(Color.accentColor)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(12)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
        .sensoryFeedback(.error, trigger: message)
        .onAppear {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
}
