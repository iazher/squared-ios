//
//  MockScenario.swift
//  Squared
//

import Foundation

#if DEBUG
/// Selects which mock dataset `MockAPIClient` serves. Controlled via the
/// `-mockScenario <name>` launch argument, so QA/UI tests can reach a
/// brand-new-user empty state without touching the default `MockData`.
enum MockScenario: Equatable {
    case defaultScenario
    case newUser

    static var current: MockScenario {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-mockScenario"), index + 1 < arguments.count else {
            return .defaultScenario
        }
        switch arguments[index + 1] {
        case "newUser": return .newUser
        default: return .defaultScenario
        }
    }
}
#endif
