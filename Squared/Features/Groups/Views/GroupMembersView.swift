//
//  GroupMembersView.swift
//  Squared
//

import SwiftUI

struct GroupMembersView: View {
    @State private var viewModel: GroupMembersViewModel
    @State private var isShowingAddMember = false
    private let appState: AppState
    private let group: Group
    private let groupsService: GroupsServiceProtocol

    init(appState: AppState, group: Group, groupsService: GroupsServiceProtocol) {
        _viewModel = State(initialValue: GroupMembersViewModel(appState: appState, group: group))
        self.appState = appState
        self.group = group
        self.groupsService = groupsService
    }

    var body: some View {
        List {
            ForEach(viewModel.memberBalances) { member in
                MemberRow(member: member)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color("AppBackground"))
        .navigationTitle("Members")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingAddMember = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Member")
            }
        }
        .sheet(isPresented: $isShowingAddMember) {
            AddMemberView(appState: appState, group: group, groupsService: groupsService)
        }
    }
}

private struct MemberRow: View {
    let member: GroupMembersViewModel.MemberBalance

    var body: some View {
        HStack(spacing: 12) {
            MemberAvatar(userID: member.id, initials: member.initials, size: 40)

            Text(member.displayName)
                .font(.headline)
                .foregroundStyle(.white)

            Spacer()

            Text(balanceText)
                .font(.subheadline.bold())
                .foregroundStyle(balanceColor)
        }
        .padding(12)
        .background(Color("CardSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var balanceText: String {
        if member.netBalance == 0 {
            return member.hasActivity ? "Settled up" : "No expenses yet"
        }
        let formatted = abs(member.netBalance).formatted(currencyCode: "USD")
        return member.netBalance > 0 ? "+\(formatted)" : "-\(formatted)"
    }

    private var balanceColor: Color {
        if member.netBalance == 0 {
            return member.hasActivity ? Color("PositiveBalance") : .white.opacity(0.5)
        }
        return member.netBalance > 0 ? Color("PositiveBalance") : .red
    }
}
