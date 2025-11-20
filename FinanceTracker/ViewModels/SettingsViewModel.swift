import Foundation
import SwiftUI
import Combine

enum AppTheme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}

class SettingsViewModel: ObservableObject {
    @Published var selectedTheme: AppTheme = .system {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "appTheme")
        }
    }
    
    init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "appTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            selectedTheme = theme
        }
    }
    
    func resetAllData(viewModel: FinanceTrackerViewModel) {
        viewModel.debts.removeAll()
        UserDefaults.standard.removeObject(forKey: "SavedDebts")
    }
}

