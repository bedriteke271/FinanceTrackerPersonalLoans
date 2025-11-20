import SwiftUI

struct MainTabView: View {
    @StateObject private var debtViewModel = FinanceTrackerViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        PortraitLockedTabView(
            colorScheme: settingsViewModel.selectedTheme.colorScheme
        ) {
            TabView {
                DebtListView(viewModel: debtViewModel)
                    .tabItem {
                        Label("Debts", systemImage: "list.bullet")
                    }
                
                SummaryView(viewModel: debtViewModel)
                    .tabItem {
                        Label("Summary", systemImage: "chart.bar")
                    }
                
                CalendarView(viewModel: debtViewModel)
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                
                SettingsView(
                    settingsViewModel: settingsViewModel,
                    debtViewModel: debtViewModel
                )
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
    }
}

struct PortraitLockedTabView<Content: View>: UIViewControllerRepresentable {
    let content: Content
    let colorScheme: ColorScheme?
    
    init(colorScheme: ColorScheme?, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.colorScheme = colorScheme
    }
    
    func makeUIViewController(context: Context) -> PortraitTabHostingController<Content> {
        AppDelegate.orientationLock = .portrait
        
        let controller = PortraitTabHostingController(rootView: content)
        controller.colorScheme = colorScheme
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if #available(iOS 16.0, *) {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PortraitTabHostingController<Content>, context: Context) {
        uiViewController.rootView = content
        uiViewController.colorScheme = colorScheme
    }
}

class PortraitTabHostingController<Content: View>: UIHostingController<Content> {
    var colorScheme: ColorScheme? {
        didSet {
            if let colorScheme = colorScheme {
                overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light
            }
        }
    }
    
    private var orientationObserver: NSObjectProtocol?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override init(rootView: Content) {
        super.init(rootView: rootView)
        AppDelegate.orientationLock = .portrait
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if #available(iOS 16.0, *) {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let colorScheme = colorScheme {
            overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        
        lockPortraitOrientation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lockPortraitOrientation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lockPortraitOrientation()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        lockPortraitOrientation()
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if size.width > size.height {
            lockPortraitOrientation()
            return
        }
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    @objc private func orientationDidChange() {
        DispatchQueue.main.async { [weak self] in
            self?.lockPortraitOrientation()
        }
    }
    
    func lockPortraitOrientation() {
        if let windowScene = view.window?.windowScene ?? UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if #available(iOS 16.0, *) {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        }
    }
    
    deinit {
        if let observer = orientationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        NotificationCenter.default.removeObserver(self)
    }
}

#Preview {
    MainTabView()
}
