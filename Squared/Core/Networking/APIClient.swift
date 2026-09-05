//
//  APIClient.swift
//  Squared
//

/// Transport-level abstraction for talking to the backend. Fully decoupled from
/// feature logic — features depend on this protocol, never on a concrete client.
protocol APIClient {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}
