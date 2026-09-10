//
//  Decimal+Currency.swift
//  Squared
//

import Foundation

extension Decimal {
    /// Formats the value as a localized currency string, e.g. for expense/balance amounts.
    func formatted(currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        // Force en_US so "$" renders as "$", not "US$" regardless of device region.
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(for: self) ?? "\(self)"
    }
}
