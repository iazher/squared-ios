//
//  GroupsListView.swift
//  Squared
//

import SwiftUI

struct GroupsListView: View {
    @State private var viewModel: GroupsListViewModel
    private let appState: AppState
    private let expensesService: ExpensesServiceProtocol
    private let settlementService: SettlementServiceProtocol

    init(appState: AppState, groupsService: GroupsServiceProtocol, expensesService: ExpensesServiceProtocol, settlementService: SettlementServiceProtocol) {
        _viewModel = State(initialValue: GroupsListViewModel(appState: appState, groupsService: groupsService))
        self.appState = appState
        self.expensesService = expensesService
        self.settlementService = settlementService
    }

    var body: some View {
        NavigationStack {
            // `viewModel.groups` reads straight from AppState — no spinner here,
            // the data was already fetched during the post-sign-in loading state.
            List(viewModel.groups) { group in
                NavigationLink(value: group) {
                    Text(group.name)
                }
            }
            .navigationTitle("Groups")
            .navigationDestination(for: Group.self) { group in
                GroupDetailView(appState: appState, group: group, expensesService: expensesService, settlementService: settlementService)
            }
            .overlay {
                if viewModel.groups.isEmpty {
                    ContentUnavailableView("No Groups Yet", systemImage: "person.3")
                }
            }
        }
    }
}
