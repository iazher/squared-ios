//
//  GroupDetailView.swift
//  Squared
//

import SwiftUI

struct GroupDetailView: View {
    let appState: AppState
    let group: Group
    let expensesService: ExpensesServiceProtocol
    let settlementService: SettlementServiceProtocol

    var body: some View {
        List {
            Section("Expenses") {
                NavigationLink("View Expenses") {
                    ExpensesListView(appState: appState, group: group, expensesService: expensesService)
                }
            }
            Section("Settlement") {
                NavigationLink("View Balances") {
                    SettlementView(appState: appState, group: group, settlementService: settlementService)
                }
            }
        }
        .navigationTitle(group.name)
    }
}
