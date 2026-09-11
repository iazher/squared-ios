//
//  MemberAvatar.swift
//  Squared
//

import SwiftUI

/// A per-member colored, initials-based avatar. Color and initials are derived
/// deterministically from the user's id/name, so a given member renders
/// identically everywhere this is used (summary row, member list, etc).
struct MemberAvatar: View {
    let userID: String
    let initials: String
    var size: CGFloat = 32

    var body: some View {
        Circle()
            .fill(Self.color(for: userID))
            .frame(width: size, height: size)
            .overlay {
                Text(initials)
                    .font(.system(size: size * 0.36, weight: .semibold))
                    .foregroundStyle(.white)
            }
    }

    /// Fixed palette cycled per member — not randomized, so colors stay stable.
    private static let palette: [Color] = [
        Color(red: 0.467, green: 0.345, blue: 0.820), // purple (matches AccentColor)
        Color(red: 0.898, green: 0.318, blue: 0.541), // pink / rose
        Color(red: 0.298, green: 0.553, blue: 0.949), // blue
        Color(red: 0.145, green: 0.667, blue: 0.643)  // teal
    ]

    static func color(for userID: String) -> Color {
        // A manual, stable hash — String.hashValue is randomized per process
        // launch, which would make a member's color change between app runs.
        let hash = userID.utf8.reduce(0) { ($0 << 5) &+ $0 &+ Int($1) }
        return palette[abs(hash) % palette.count]
    }

    /// Two-letter initials from a display name, e.g. "Sam Rivera" -> "SR".
    static func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2, let first = parts.first?.first, let last = parts.last?.first {
            return "\(first)\(last)".uppercased()
        } else if let first = parts.first {
            return String(first.prefix(2)).uppercased()
        }
        return "?"
    }
}
