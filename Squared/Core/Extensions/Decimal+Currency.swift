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
        return formatter.string(for: self) ?? "\(self)"
    }
}
