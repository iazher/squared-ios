//
//  SettlementViewModel.swift
//  Squared
//

import Foundation
import Observation

/// Reads this group's balances from `AppState`; settlements go through the service.
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
            // TEMPORARY: balances are derived from expenses only right now, so
            // recording a settlement doesn't yet move them — recompute anyway so
            // this call site is correct once settlements factor into the real calculation.
            appState.recomputeBalances()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
