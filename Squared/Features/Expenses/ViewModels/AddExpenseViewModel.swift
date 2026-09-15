//
//  AddExpenseViewModel.swift
//  Squared
//

import Foundation
import Observation

/// Calls `ExpensesServiceProtocol` directly, then writes the result into `AppState`.
@Observable
final class AddExpenseViewModel {
    private let appState: AppState
    private let expensesService: ExpensesServiceProtocol
    let group: Group

    struct Member: Identifiable {
        let id: String
        let displayName: String
    }

    struct SplitPreviewRow: Identifiable {
        let id: String
        let displayName: String
        let amount: Decimal
    }

    var title: String = ""
    var amountText: String = ""
    var payerID: String
    var splitMethod: SplitMethod = .equal {
        didSet {
            guard splitMethod != oldValue else { return }
            prefillCustomInputsIfNeeded()
        }
    }
    private(set) var selectedParticipantIDs: Set<String> {
        didSet {
            guard selectedParticipantIDs != oldValue else { return }
            prefillCustomInputsIfNeeded()
        }
    }
    var customAmountText: [String: String] = [:]
    var customPercentageText: [String: String] = [:]

    private(set) var isSaving = false
    var errorMessage: String?

    init(appState: AppState, group: Group, expensesService: ExpensesServiceProtocol) {
        self.appState = appState
        self.group = group
        self.expensesService = expensesService
        self.payerID = appState.currentUser?.id ?? group.memberIDs.first ?? ""
        self.selectedParticipantIDs = Set(group.memberIDs)
    }

    var members: [Member] {
        group.memberIDs.map { Member(id: $0, displayName: displayName(for: $0)) }
    }

    func isParticipantSelected(_ userID: String) -> Bool {
        selectedParticipantIDs.contains(userID)
    }

    func toggleParticipant(_ userID: String) {
        if selectedParticipantIDs.contains(userID) {
            selectedParticipantIDs.remove(userID)
        } else {
            selectedParticipantIDs.insert(userID)
        }
    }

    /// Live preview of each selected participant's share, in member order.
    var splitPreview: [SplitPreviewRow] {
        let shares = computeShares()
        return group.memberIDs
            .filter { selectedParticipantIDs.contains($0) }
            .map { SplitPreviewRow(id: $0, displayName: displayName(for: $0), amount: shares[$0] ?? .zero) }
    }

    /// Non-nil when the current split inputs don't add up — keeps Save disabled until they do.
    var splitValidationMessage: String? {
        guard let amount, !selectedParticipantIDs.isEmpty else { return nil }
        let participants = group.memberIDs.filter { selectedParticipantIDs.contains($0) }

        switch splitMethod {
        case .equal:
            return nil
        case .exact:
            let total = participants.reduce(Decimal.zero) { $0 + (Decimal(string: customAmountText[$1] ?? "") ?? .zero) }
            guard total != amount else { return nil }
            return "Amounts total \(total.formatted(currencyCode: "USD")), but the expense is \(amount.formatted(currencyCode: "USD"))."
        case .percentage:
            let total = participants.reduce(Decimal.zero) { $0 + (Decimal(string: customPercentageText[$1] ?? "") ?? .zero) }
            guard total != 100 else { return nil }
            return "Percentages total \(total)%, not 100%."
        }
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && amount != nil
            && !selectedParticipantIDs.isEmpty
            && splitValidationMessage == nil
    }

    func save() async -> Bool {
        guard canSave, let amount else {
            errorMessage = "Enter a valid amount."
            return false
        }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        let shares = computeShares()
        let splits = group.memberIDs
            .filter { selectedParticipantIDs.contains($0) }
            .map { ExpenseSplit(userID: $0, amount: shares[$0] ?? .zero) }

        do {
            let expense = try await expensesService.createExpense(
                groupID: group.id,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                amount: amount,
                paidByUserID: payerID,
                splitMethod: splitMethod,
                splits: splits
            )
            appState.upsert(expense: expense)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private var amount: Decimal? {
        Decimal(string: amountText)
    }

    private func displayName(for userID: String) -> String {
        if userID == appState.currentUser?.id {
            return "You"
        }
        return appState.users.first(where: { $0.id == userID })?.name ?? userID
    }

    private func computeShares() -> [String: Decimal] {
        guard let amount else { return [:] }
        let participants = group.memberIDs.filter { selectedParticipantIDs.contains($0) }
        guard !participants.isEmpty else { return [:] }

        switch splitMethod {
        case .equal:
            let shares = evenSplit(of: amount, into: participants.count)
            return Dictionary(uniqueKeysWithValues: zip(participants, shares))
        case .exact:
            return Dictionary(uniqueKeysWithValues: participants.map { ($0, Decimal(string: customAmountText[$0] ?? "") ?? .zero) })
        case .percentage:
            return Dictionary(uniqueKeysWithValues: participants.map { userID in
                let percentage = Decimal(string: customPercentageText[userID] ?? "") ?? .zero
                return (userID, (amount * percentage / 100).rounded(to: 2))
            })
        }
    }

    /// Resets custom inputs to an even split whenever the method or participant
    /// set changes, so the preview never starts from a blank/mismatched state.
    private func prefillCustomInputsIfNeeded() {
        guard let amount, !selectedParticipantIDs.isEmpty else { return }
        let participants = group.memberIDs.filter { selectedParticipantIDs.contains($0) }

        switch splitMethod {
        case .equal:
            break
        case .exact:
            let shares = evenSplit(of: amount, into: participants.count)
            for (id, share) in zip(participants, shares) {
                customAmountText[id] = "\(share)"
            }
        case .percentage:
            let shares = evenSplit(of: 100, into: participants.count)
            for (id, share) in zip(participants, shares) {
                customPercentageText[id] = "\(share)"
            }
        }
    }

    /// Divides `total` evenly among `count` shares rounded to `scale` decimal
    /// places, assigning any rounding remainder to the first few shares one unit
    /// at a time so they always sum back to exactly `total` (e.g. $10.00 / 3
    /// would otherwise round to $3.33 × 3 = $9.99).
    private func evenSplit(of total: Decimal, into count: Int, scale: Int = 2) -> [Decimal] {
        guard count > 0 else { return [] }
        let base = (total / Decimal(count)).rounded(to: scale)
        var shares = Array(repeating: base, count: count)
        var remainder = (total - base * Decimal(count)).rounded(to: scale)
        let unit = Decimal(sign: .plus, exponent: -scale, significand: 1)
        var index = 0
        while remainder != 0 && index < count {
            if remainder > 0 {
                shares[index] += unit
                remainder -= unit
            } else {
                shares[index] -= unit
                remainder += unit
            }
            index += 1
        }
        return shares
    }
}

private extension Decimal {
    func rounded(to scale: Int) -> Decimal {
        var result = Decimal()
        var value = self
        NSDecimalRound(&result, &value, scale, .plain)
        return result
    }
}
