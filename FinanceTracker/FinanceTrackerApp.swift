import SwiftUI
import CoreData

@main
struct FinanceTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            LaunchView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

