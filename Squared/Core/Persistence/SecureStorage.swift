//
//  SecureStorage.swift
//  Squared
//

import Foundation

/// Abstraction over persisted secrets (e.g. an auth session token).
protocol SecureStorage {
    func string(forKey key: String) -> String?
    func set(_ value: String?, forKey key: String)
}

// TODO: swap for a real Keychain-backed implementation before shipping.
final class UserDefaultsSecureStorage: SecureStorage {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func string(forKey key: String) -> String? {
        defaults.string(forKey: key)
    }

    func set(_ value: String?, forKey key: String) {
        defaults.set(value, forKey: key)
    }
}
