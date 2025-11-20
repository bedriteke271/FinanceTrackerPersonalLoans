import Foundation

struct Debt: Identifiable, Codable {
    let id: UUID
    var title: String
    var amount: Double
    var dueDate: Date
    var interestRate: Double
    var notes: String
    var payments: [Payment]
    
    init(id: UUID = UUID(), title: String, amount: Double, dueDate: Date, interestRate: Double = 0.0, notes: String = "", payments: [Payment] = []) {
        self.id = id
        self.title = title
        self.amount = amount
        self.dueDate = dueDate
        self.interestRate = interestRate
        self.notes = notes
        self.payments = payments
    }
    
    var daysUntilDue: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let due = calendar.startOfDay(for: dueDate)
        return calendar.dateComponents([.day], from: today, to: due).day ?? 0
    }
    
    var dailyPayment: Double {
        guard daysUntilDue > 0 && !isPaidOff else { return remainingAmount }
        
        if interestRate > 0 {
            let dailyRate = interestRate / 100 / 365.0
            let remainingWithInterest = remainingAmount * pow(1 + dailyRate, Double(daysUntilDue))
            return remainingWithInterest / Double(daysUntilDue)
        } else {
            return remainingAmount / Double(daysUntilDue)
        }
    }
    
    var totalAmount: Double {
        guard interestRate > 0 && daysUntilDue > 0 else { return amount }
        let dailyRate = interestRate / 100 / 365.0
        return amount * pow(1 + dailyRate, Double(daysUntilDue))
    }
    
    var totalPaid: Double {
        payments.reduce(0) { $0 + $1.amount }
    }
    
    var remainingAmount: Double {
        max(0, totalAmount - totalPaid)
    }
    
    var isPaidOff: Bool {
        remainingAmount <= 0.01
    }
    
    var isOverdue: Bool {
        return daysUntilDue < 0 && !isPaidOff
    }
    
    var isDueSoon: Bool {
        return daysUntilDue >= 0 && daysUntilDue <= 7 && !isPaidOff
    }
    
    func hasPaymentOnDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return payments.contains { payment in
            calendar.isDate(payment.date, inSameDayAs: date)
        }
    }
    
    func totalPaidOnDate(_ date: Date) -> Double {
        let calendar = Calendar.current
        return payments
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .reduce(0) { $0 + $1.amount }
    }
}

