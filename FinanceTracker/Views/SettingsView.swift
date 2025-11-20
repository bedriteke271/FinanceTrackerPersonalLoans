import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var debtViewModel: FinanceTrackerViewModel
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Appearance")) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        HStack {
                            Text(theme.rawValue)
                            Spacer()
                            if settingsViewModel.selectedTheme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            settingsViewModel.selectedTheme = theme
                        }
                    }
                }
                
                Section(header: Text("Data")) {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Reset All Data")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset All Data", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    settingsViewModel.resetAllData(viewModel: debtViewModel)
                }
            } message: {
                Text("Are you sure you want to delete all debts? This action cannot be undone.")
            }
        }
    }
}

#Preview {
    SettingsView(
        settingsViewModel: SettingsViewModel(),
        debtViewModel: FinanceTrackerViewModel()
    )
}

