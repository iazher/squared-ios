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

    func createExpense(groupID: String, title: String, amount: Decimal, paidByUserID: String, splitMethod: SplitMethod, splits: [ExpenseSplit]) async throws -> Expense {
        let requestBody = CreateExpenseRequest(
            groupID: groupID,
            title: title,
            amount: amount,
            paidByUserID: paidByUserID,
            splitMethod: splitMethod,
            splits: splits
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
    let splitMethod: SplitMethod
    let splits: [ExpenseSplit]
}
