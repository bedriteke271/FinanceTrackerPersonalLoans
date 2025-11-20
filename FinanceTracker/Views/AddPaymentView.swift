import SwiftUI

struct AddPaymentView: View {
    @ObservedObject var viewModel: FinanceTrackerViewModel
    let debt: Debt
    @Environment(\.dismiss) var dismiss
    
    @State private var amount: String = ""
    @State private var paymentDate: Date = Date()
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("PAYMENT INFORMATION")) {
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    DatePicker("Payment Date", selection: $paymentDate, displayedComponents: .date)
                }
                
                Section(header: Text("Notes (Optional)")) {
                    TextField("Add notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Remaining after payment:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(formatCurrency(remainingAfterPayment))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(remainingAfterPayment < 0 ? .red : .green)
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button(action: savePayment) {
                        Text("Add Payment")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(isValid ? Color.blue : Color.gray)
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Add Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isValid: Bool {
        !amount.isEmpty && Double(amount) != nil && Double(amount)! > 0
    }
    
    private var remainingAfterPayment: Double {
        guard let paymentAmount = Double(amount) else { return debt.remainingAmount }
        return max(0, debt.remainingAmount - paymentAmount)
    }
    
    private func savePayment() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        let newPayment = Payment(
            amount: amountValue,
            date: paymentDate,
            notes: notes
        )
        
        viewModel.addPayment(newPayment, to: debt)
        dismiss()
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

#Preview {
    AddPaymentView(
        viewModel: FinanceTrackerViewModel(),
        debt: Debt(
            title: "Credit Card",
            amount: 5000.0,
            dueDate: Date(),
            interestRate: 18.0
        )
    )
}

