import SwiftUI

struct LaunchView: View {
    private let serverService = ServerService.shared
    @State private var isLoading = true
    @State private var showDebtScreen = false
    @State private var showMainApp = false
    @State private var debtScreenLink: String = ""
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else if showDebtScreen {
                DebtScreenView(linkString: debtScreenLink)
            } else if showMainApp {
                MainTabView()
                    .onAppear {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            if #available(iOS 16.0, *) {
                                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                            }
                        }
                    }
            }
        }
        .onAppear {
            checkAndLoad()
        }
    }
    
    private func checkAndLoad() {
        if serverService.hasToken(), let link = serverService.savedLink {
            debtScreenLink = link
            showDebtScreen = true
            isLoading = false
        } else {
            fetchFromServer()
        }
    }
    
    private func fetchFromServer() {
        serverService.fetchServerData { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let data):
                    self.debtScreenLink = data.link
                    self.showDebtScreen = true
                case .failure:
                    self.showMainApp = true
                }
            }
        }
    }
}

