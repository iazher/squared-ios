//
//  GradientButton.swift
//  Squared
//

import SwiftUI

/// The brand gradient (#7758D1 → #F7CBFD) primary action button, shared by
/// every screen that needs one (View Settlement, empty-state CTAs, etc).
struct GradientButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.4667, green: 0.3451, blue: 0.8196), // #7758D1
                            Color(red: 0.9686, green: 0.7961, blue: 0.9922)  // #F7CBFD
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
