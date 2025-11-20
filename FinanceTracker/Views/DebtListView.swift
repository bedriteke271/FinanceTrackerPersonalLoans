import SwiftUI

struct DebtListView: View {
    @ObservedObject var viewModel: FinanceTrackerViewModel
    
    var body: some View {
        NavigationView {
            List {
                if !viewModel.debts.isEmpty {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Total Debt")
                                    .font(.headline)
                                Spacer()
                                Text(formatCurrency(viewModel.totalDebtAmount))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Daily Payment Needed")
                                    .font(.headline)
                                Spacer()
                                Text(formatCurrency(viewModel.totalDailyPayment))
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                if !viewModel.overdueDebts.isEmpty {
                    Section(header: Text("Overdue")) {
                        ForEach(viewModel.overdueDebts) { debt in
                            DebtCardView(debt: debt)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                }
                
                if !viewModel.dueSoonDebts.isEmpty {
                    Section(header: Text("Due Soon")) {
                        ForEach(viewModel.dueSoonDebts) { debt in
                            DebtCardView(debt: debt)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                }
                
                Section(header: Text(viewModel.debts.isEmpty ? "" : "All Debts")) {
                    if viewModel.debts.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "creditcard.trianglebadge.exclamationmark")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("No Debts Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Add your first debt to start tracking")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(viewModel.debts) { debt in
                            NavigationLink(destination: DebtDetailView(debt: debt, viewModel: viewModel)) {
                                DebtCardView(debt: debt)
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    viewModel.deleteDebt(debt)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Finance Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddDebtView(viewModel: viewModel)) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
        }
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
    DebtListView(viewModel: FinanceTrackerViewModel())
}

