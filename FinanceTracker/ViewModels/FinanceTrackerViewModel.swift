import Foundation
import SwiftUI
import Combine

class FinanceTrackerViewModel: ObservableObject {
    @Published var debts: [Debt] = []
    
    private let debtsKey = "SavedDebts"
    private var isLoading = false
    
    init() {
        loadDebts()
    }
    
    private func saveDebts() {
        guard !isLoading else { return }
        if let encoded = try? JSONEncoder().encode(debts) {
            UserDefaults.standard.set(encoded, forKey: debtsKey)
        }
    }
    
    private func loadDebts() {
        isLoading = true
        defer { isLoading = false }
        
        if let data = UserDefaults.standard.data(forKey: debtsKey),
           let decoded = try? JSONDecoder().decode([Debt].self, from: data) {
            debts = decoded
            debts.sort { $0.dueDate < $1.dueDate }
        }
    }
    
    func addDebt(_ debt: Debt) {
        debts.append(debt)
        debts.sort { $0.dueDate < $1.dueDate }
        saveDebts()
    }
    
    func deleteDebt(_ debt: Debt) {
        debts.removeAll { $0.id == debt.id }
        saveDebts()
    }
    
    func updateDebt(_ debt: Debt) {
        if let index = debts.firstIndex(where: { $0.id == debt.id }) {
            debts[index] = debt
            debts.sort { $0.dueDate < $1.dueDate }
            saveDebts()
        }
    }
    
    func addPayment(_ payment: Payment, to debt: Debt) {
        if let index = debts.firstIndex(where: { $0.id == debt.id }) {
            debts[index].payments.append(payment)
            debts[index].payments.sort { $0.date > $1.date }
            saveDebts()
        }
    }
    
    var totalDebtAmount: Double {
        debts.reduce(0) { $0 + $1.remainingAmount }
    }
    
    var totalDailyPayment: Double {
        debts.filter { !$0.isPaidOff }.reduce(0) { $0 + $1.dailyPayment }
    }
    
    var overdueDebts: [Debt] {
        debts.filter { $0.isOverdue }
    }
    
    var dueSoonDebts: [Debt] {
        debts.filter { $0.isDueSoon }
    }
}

