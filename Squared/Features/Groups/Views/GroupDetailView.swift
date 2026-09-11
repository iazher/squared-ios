//
//  GroupDetailView.swift
//  Squared
//

import SwiftUI

struct GroupDetailView: View {
    @State private var viewModel: GroupDetailViewModel
    @State private var isShowingAddExpense = false
    @State private var isShowingMembers = false
    @State private var isShowingSettlement = false
    @State private var selectedExpense: Expense?
    private let appState: AppState
    private let group: Group
    private let groupsService: GroupsServiceProtocol
    private let expensesService: ExpensesServiceProtocol
    private let settlementService: SettlementServiceProtocol

    init(appState: AppState, group: Group, groupsService: GroupsServiceProtocol, expensesService: ExpensesServiceProtocol, settlementService: SettlementServiceProtocol) {
        _viewModel = State(initialValue: GroupDetailViewModel(appState: appState, group: group))
        self.appState = appState
        self.group = group
        self.groupsService = groupsService
        self.expensesService = expensesService
        self.settlementService = settlementService
    }

    var body: some View {
        List {
            Section {
                // Manually driven (not NavigationLink) so this card's own chevron is the only one shown.
                Button {
                    isShowingMembers = true
                } label: {
                    MemberSummaryRow(memberAvatars: viewModel.memberAvatars, totalCount: viewModel.memberCount)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }

            Section {
                // A plain row, not a `header:` — `.plain` list style pins section
                // headers to the top while scrolling, which we don't want here.
                Text("Expenses")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 0, trailing: 16))

                if viewModel.expenses.isEmpty {
                    Text("No expenses yet")
                        .foregroundStyle(.white.opacity(0.5))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(viewModel.expenses) { expense in
                        Button {
                            selectedExpense = expense
                        } label: {
                            ExpenseRow(expense: expense, payerName: viewModel.payerName(for: expense))
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color("AppBackground"))
        .navigationTitle(group.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Expense")
            }
        }
        .sheet(isPresented: $isShowingAddExpense) {
            AddExpenseView(appState: appState, group: group, expensesService: expensesService)
        }
        .navigationDestination(isPresented: $isShowingMembers) {
            GroupMembersView(appState: appState, group: group, groupsService: groupsService)
        }
        .navigationDestination(isPresented: $isShowingSettlement) {
            SettlementView(appState: appState, group: group, settlementService: settlementService)
        }
        .navigationDestination(item: $selectedExpense) { expense in
            ExpenseDetailView(appState: appState, expense: expense)
        }
        // Pinned footer — reserves its own space so the list scrolls independently and stops short of it.
        .safeAreaInset(edge: .bottom) {
            Button {
                isShowingSettlement = true
            } label: {
                Text("View Settlement")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.4667, green: 0.3451, blue: 0.8196), // #7758D1
                                Color(red: 0.9686, green: 0.7961, blue: 0.9922)  // #F7CBFD
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(Color("AppBackground"))
        }
    }
}

private struct MemberSummaryRow: View {
    let memberAvatars: [GroupDetailViewModel.MemberAvatarInfo]
    let totalCount: Int

    var body: some View {
        HStack(spacing: 12) {
            avatarCluster
            Text("\(totalCount) \(totalCount == 1 ? "Member" : "Members")")
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(12)
        .background(Color("CardSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var avatarCluster: some View {
        let maxAvatars = 3
        let shown = totalCount > maxAvatars ? Array(memberAvatars.prefix(maxAvatars - 1)) : Array(memberAvatars.prefix(maxAvatars))
        let overflowCount = totalCount - shown.count

        // A modest overlap keeps the stacked look without clipping 2-letter initials.
        return HStack(spacing: -6) {
            ForEach(shown) { avatar in
                MemberAvatar(userID: avatar.id, initials: avatar.initials)
                    .overlay {
                        Circle().stroke(Color("CardSurface"), lineWidth: 2)
                    }
            }
            if overflowCount > 0 {
                overflowBadge(count: overflowCount)
            }
        }
    }

    private func overflowBadge(count: Int) -> some View {
        // A distinct neutral gray — reads as "a count," not a person, unlike the colored avatars.
        Circle()
            .fill(Color(white: 0.32))
            .frame(width: 32, height: 32)
            .overlay {
                Text("+\(count)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .overlay {
                Circle().stroke(Color("CardSurface"), lineWidth: 2)
            }
    }
}

private struct ExpenseRow: View {
    let expense: Expense
    let payerName: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Paid by \(payerName)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            Text(expense.amount.formatted(currencyCode: "USD"))
                .font(.subheadline.bold())
                .foregroundStyle(.white)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(12)
        .background(Color("CardSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
