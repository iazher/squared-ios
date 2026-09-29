//
//  NetworkError.swift
//  Squared
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int)
    case decodingFailed
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL was invalid."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .requestFailed(let statusCode):
            return "The request failed with status code \(statusCode)."
        case .decodingFailed:
            return "The response could not be decoded."
        case .underlying(let error):
            return error.localizedDescription
        }
    }

    /// Text safe to show a user — distinct from `errorDescription`, which can
    /// leak technical detail (e.g. `.underlying`'s wrapped error).
    var userFacingMessage: String {
        switch self {
        case .invalidURL, .invalidResponse, .decodingFailed:
            return "Something went wrong. Please try again."
        case .requestFailed, .underlying:
            return "Couldn't reach the server."
        }
    }
}

/// The one place a caught error becomes user-facing text — call sites should
/// never show `error.localizedDescription` directly.
func friendlyErrorMessage(_ error: Error) -> String {
    (error as? NetworkError)?.userFacingMessage ?? "Something went wrong. Please try again."
}
