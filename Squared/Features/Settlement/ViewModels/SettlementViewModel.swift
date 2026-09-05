//
//  SettlementViewModel.swift
//  Squared
//

import Foundation
import Observation

/// Reads shared balance data from `AppState` (already populated during the
/// post-sign-in initial fetch) filtered down to a single group. Recording a
/// settlement is a mutation, so that goes straight through `SettlementServiceProtocol`
/// and the result is written back into `AppState` afterwards.
@Observable
final class SettlementViewModel {
    private let appState: AppState
    private let settlementService: SettlementServiceProtocol
    let group: Group

    private(set) var isRecordingSettlement = false
    var errorMessage: String?

    init(appState: AppState, group: Group, settlementService: SettlementServiceProtocol) {
        self.appState = appState
        self.group = group
        self.settlementService = settlementService
    }

    var balances: [Balance] {
        appState.balances.filter { $0.groupID == group.id }
    }

    func recordSettlement(fromUserID: String, toUserID: String, amount: Decimal) async {
        isRecordingSettlement = true
        errorMessage = nil
        defer { isRecordingSettlement = false }

        do {
            _ = try await settlementService.recordSettlement(
                groupID: group.id,
                fromUserID: fromUserID,
                toUserID: toUserID,
                amount: amount
            )
            let refreshedBalances = try await settlementService.fetchBalances()
            appState.setBalances(refreshedBalances)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
