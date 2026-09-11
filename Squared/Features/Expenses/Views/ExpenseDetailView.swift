//
//  ExpenseDetailView.swift
//  Squared
//

import SwiftUI

struct ExpenseDetailView: View {
    @State private var viewModel: ExpenseDetailViewModel

    init(appState: AppState, expense: Expense) {
        _viewModel = State(initialValue: ExpenseDetailViewModel(appState: appState, expense: expense))
    }

    var body: some View {
        List {
            Section {
                SummaryCard(
                    title: viewModel.title,
                    amountText: viewModel.amountText,
                    payerName: viewModel.payerName,
                    splitMethodLabel: viewModel.splitMethodLabel
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }

            Section {
                // A plain row, not a `header:` — `.plain` list style pins section
                // headers to the top while scrolling, which we don't want here.
                Text("Split Breakdown")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 0, trailing: 16))

                ForEach(viewModel.participantShares) { share in
                    ParticipantShareRow(share: share, showsPercentage: viewModel.showsPercentage)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color("AppBackground"))
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SummaryCard: View {
    let title: String
    let amountText: String
    let payerName: String
    let splitMethodLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                Text(amountText)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
            }

            Divider()
                .overlay(Color.white.opacity(0.1))

            HStack {
                Text("Paid by")
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
                Text(payerName)
                    .foregroundStyle(.white)
            }
            .font(.subheadline)

            HStack {
                Text("Split")
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
                Text(splitMethodLabel)
                    .foregroundStyle(.white)
            }
            .font(.subheadline)
        }
        .padding(16)
        .background(Color("CardSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct ParticipantShareRow: View {
    let share: ExpenseDetailViewModel.ParticipantShare
    let showsPercentage: Bool

    var body: some View {
        HStack(spacing: 12) {
            MemberAvatar(userID: share.id, initials: share.initials, size: 36)

            Text(share.displayName)
                .font(.headline)
                .foregroundStyle(.white)

            Spacer()

            if showsPercentage, let percentage = share.percentage {
                Text("\(percentage)%")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Text(share.amount.formatted(currencyCode: "USD"))
                .font(.subheadline.bold())
                .foregroundStyle(.white)
        }
        .padding(12)
        .background(Color("CardSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
