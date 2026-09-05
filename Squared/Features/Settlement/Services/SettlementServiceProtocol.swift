//
//  SettlementServiceProtocol.swift
//  Squared
//

import Foundation

protocol SettlementServiceProtocol {
    func fetchBalances() async throws -> [Balance]
    func recordSettlement(groupID: String, fromUserID: String, toUserID: String, amount: Decimal) async throws -> Settlement
}
