//
//  SettlementService.swift
//  Squared
//

import Foundation

final class SettlementService: SettlementServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchBalances() async throws -> [Balance] {
        let endpoint = Endpoint(path: "/settlement/balances")
        return try await apiClient.request(endpoint)
    }

    func recordSettlement(groupID: String, fromUserID: String, toUserID: String, amount: Decimal) async throws -> Settlement {
        let requestBody = RecordSettlementRequest(groupID: groupID, fromUserID: fromUserID, toUserID: toUserID, amount: amount)
        let body = try JSONEncoder().encode(requestBody)
        let endpoint = Endpoint(path: "/settlement/settlements", method: .post, body: body)
        return try await apiClient.request(endpoint)
    }
}

private struct RecordSettlementRequest: Encodable {
    let groupID: String
    let fromUserID: String
    let toUserID: String
    let amount: Decimal
}
