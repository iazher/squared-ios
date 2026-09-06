//
//  APIClient.swift
//  Squared
//

/// Transport-level abstraction for talking to the backend.
protocol APIClient {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}
