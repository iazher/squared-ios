//
//  ExpensesService.swift
//  Squared
//

import Foundation

final class ExpensesService: ExpensesServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchExpenses() async throws -> [Expense] {
        let endpoint = Endpoint(path: "/expenses")
        return try await apiClient.request(endpoint)
    }

    func createExpense(groupID: String, title: String, amount: Decimal, paidByUserID: String, splitBetweenUserIDs: [String]) async throws -> Expense {
        let requestBody = CreateExpenseRequest(
            groupID: groupID,
            title: title,
            amount: amount,
            paidByUserID: paidByUserID,
            splitBetweenUserIDs: splitBetweenUserIDs
        )
        let body = try JSONEncoder().encode(requestBody)
        let endpoint = Endpoint(path: "/expenses", method: .post, body: body)
        return try await apiClient.request(endpoint)
    }
}

private struct CreateExpenseRequest: Encodable {
    let groupID: String
    let title: String
    let amount: Decimal
    let paidByUserID: String
    let splitBetweenUserIDs: [String]
}
