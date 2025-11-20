import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: FinanceTrackerViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.debts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Debts Scheduled")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Add debts to see calendar view")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(groupedDebts, id: \.key) { group in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(formatDate(group.key))
                                            .font(.headline)
                                        Spacer()
                                        if hasPaymentOnDate(group.key) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                                .font(.title3)
                                        }
                                    }
                                    .padding(.horizontal)
                                    
                                    ForEach(group.value) { debt in
                                        NavigationLink(destination: DebtDetailView(debt: debt, viewModel: viewModel)) {
                                            DebtCardView(debt: debt)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Calendar")
        }
    }
    
    private var groupedDebts: [(key: Date, value: [Debt])] {
        let grouped = Dictionary(grouping: viewModel.debts) { debt in
            Calendar.current.startOfDay(for: debt.dueDate)
        }
        return grouped.sorted { $0.key < $1.key }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    private func hasPaymentOnDate(_ date: Date) -> Bool {
        viewModel.debts.contains { debt in
            debt.hasPaymentOnDate(date)
        }
    }
}

#Preview {
    CalendarView(viewModel: FinanceTrackerViewModel())
}

