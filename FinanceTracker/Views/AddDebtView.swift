import SwiftUI

struct AddDebtView: View {
    @ObservedObject var viewModel: FinanceTrackerViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var dueDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    @State private var interestRate: String = "0"
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("DEBT INFORMATION")) {
                    TextField("e.g., Credit Card, Loan", text: $title)
                    
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
                
                Section(header: Text("Interest (Optional)")) {
                    HStack {
                        Text("Annual Interest Rate (%)")
                        Spacer()
                        TextField("0.0", text: $interestRate)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Notes (Optional)")) {
                    TextField("Add notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Button(action: saveDebt) {
                        Text("Add Debt")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(isValid ? Color.blue : Color.gray)
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Add Debt")
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
        !title.isEmpty && !amount.isEmpty && Double(amount) != nil && Double(amount)! > 0
    }
    
    private func saveDebt() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        let interestRateValue = Double(interestRate) ?? 0.0
        
        let newDebt = Debt(
            title: title,
            amount: amountValue,
            dueDate: dueDate,
            interestRate: interestRateValue,
            notes: notes
        )
        
        viewModel.addDebt(newDebt)
        dismiss()
    }
}


#Preview {
    AddDebtView(viewModel: FinanceTrackerViewModel())
}

