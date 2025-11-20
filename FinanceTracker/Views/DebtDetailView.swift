import SwiftUI

struct DebtDetailView: View {
    let debt: Debt
    @ObservedObject var viewModel: FinanceTrackerViewModel
    @State private var showAddPayment = false
    
    private var currentDebt: Debt {
        viewModel.debts.first { $0.id == debt.id } ?? debt
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(currentDebt.title)
                            .font(.system(size: 24, weight: .bold))
                        Spacer()
                        if currentDebt.isPaidOff {
                            Text("PAID OFF")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                    }
                    
                    HStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(formatCurrency(currentDebt.remainingAmount))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(currentDebt.isPaidOff ? .green : .red)
                            Text("Remaining")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(formatCurrency(currentDebt.totalAmount))
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.black)
                            Text("Total Amount")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if currentDebt.totalPaid > 0 {
                        HStack {
                            Text("Paid: \(formatCurrency(currentDebt.totalPaid))")
                                .font(.system(size: 16))
                                .foregroundColor(.green)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.vertical, 8)
            }
            
            if !currentDebt.isPaidOff {
                Section {
                    Button(action: {
                        showAddPayment = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Payment")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            
            if !currentDebt.payments.isEmpty {
                Section(header: Text("Payment History")) {
                    ForEach(currentDebt.payments) { payment in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(formatCurrency(payment.amount))
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.green)
                                Text(formatDate(payment.date))
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if !payment.notes.isEmpty {
                                Text(payment.notes)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            Section(header: Text("Details")) {
                HStack {
                    Text("Due Date")
                    Spacer()
                    Text(formatDate(currentDebt.dueDate))
                        .foregroundColor(.gray)
                }
                
                if currentDebt.interestRate > 0 {
                    HStack {
                        Text("Interest Rate")
                        Spacer()
                        Text("\(currentDebt.interestRate, specifier: "%.2f")%")
                            .foregroundColor(.gray)
                    }
                }
                
                if !currentDebt.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes")
                        Text(currentDebt.notes)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle("Debt Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddPayment) {
            AddPaymentView(viewModel: viewModel, debt: currentDebt)
        }
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
    NavigationView {
        DebtDetailView(
            debt: Debt(
                title: "Credit Card",
                amount: 5000.0,
                dueDate: Date(),
                interestRate: 18.0,
                payments: [
                    Payment(amount: 500.0, date: Date())
                ]
            ),
            viewModel: FinanceTrackerViewModel()
        )
    }
}

