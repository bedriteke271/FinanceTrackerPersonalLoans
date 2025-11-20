import SwiftUI

struct SummaryView: View {
    @ObservedObject var viewModel: FinanceTrackerViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.debts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Summary Available")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Add debts to see summary")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            SummaryCard(
                                title: "Total Debt",
                                amount: viewModel.totalDebtAmount,
                                color: .red
                            )
                            
                            SummaryCard(
                                title: "Daily Payment",
                                amount: viewModel.totalDailyPayment,
                                color: .blue
                            )
                            
                            SummaryCard(
                                title: "Overdue Debts",
                                count: viewModel.overdueDebts.count,
                                color: .red
                            )
                            
                            SummaryCard(
                                title: "Due Soon",
                                count: viewModel.dueSoonDebts.count,
                                color: .orange
                            )
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Summary")
        }
    }
}

struct SummaryCard: View {
    let title: String
    var amount: Double? = nil
    var count: Int? = nil
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            
            if let amount = amount {
                Text(formatCurrency(amount))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(color)
            } else if let count = count {
                Text("\(count)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
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
    SummaryView(viewModel: FinanceTrackerViewModel())
}

