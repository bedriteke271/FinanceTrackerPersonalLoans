import SwiftUI

struct DebtCardView: View {
    let debt: Debt
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(debt.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                if debt.isOverdue {
                    Text("OVERDUE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(8)
                } else if debt.isDueSoon {
                    Text("DUE SOON")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatCurrency(debt.remainingAmount))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(debt.isPaidOff ? .green : .red)
                    Text(debt.isPaidOff ? "Paid Off" : "Remaining")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatDate(debt.dueDate))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(debt.isOverdue ? .red : (debt.isDueSoon ? .orange : .black))
                    Text("Due Date")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            if debt.totalPaid > 0 {
                HStack {
                    Text("Paid: \(formatCurrency(debt.totalPaid))")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                    Spacer()
                    Text("Total: \(formatCurrency(debt.totalAmount))")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.top, 4)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Payment")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text(formatCurrency(debt.dailyPayment))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Days Left")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text("\(debt.daysUntilDue)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(debt.isOverdue ? .red : (debt.isDueSoon ? .orange : .black))
                }
            }
            
            if debt.interestRate > 0 {
                HStack {
                    Image(systemName: "percent")
                        .foregroundColor(.gray)
                    Text("Interest Rate: \(debt.interestRate, specifier: "%.2f")%")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.top, 4)
            }
            
            if !debt.notes.isEmpty {
                Text(debt.notes)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(debt.isOverdue ? Color.red.opacity(0.5) : (debt.isDueSoon ? Color.orange.opacity(0.5) : Color.blue.opacity(0.3)), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    DebtCardView(debt: Debt(
        title: "Credit Card Debt",
        amount: 5000.0,
        dueDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
        interestRate: 18.0,
        notes: "Chase credit card"
    ))
    .padding()
}

