import SwiftUI
import WebKit

struct FullScreenBrowserView: UIViewControllerRepresentable {
    let linkString: String
    @Binding var isLoading: Bool
    @Binding var hasInitiallyLoaded: Bool
    
    func makeUIViewController(context: Context) -> FullScreenBrowserViewController {
        let controller = FullScreenBrowserViewController()
        controller.linkString = linkString
        controller.isLoading = $isLoading
        controller.hasInitiallyLoaded = $hasInitiallyLoaded
        return controller
    }
    
    func updateUIViewController(_ uiViewController: FullScreenBrowserViewController, context: Context) {
    }
}

class FullScreenBrowserViewController: UIViewController {
    var linkString: String = ""
    var isLoading: Binding<Bool>?
    var hasInitiallyLoaded: Binding<Bool>?
    private var browserView: WKWebView!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppDelegate.orientationLock = .allButUpsideDown
        
        let configuration = WKWebViewConfiguration()
        browserView = WKWebView(frame: view.bounds, configuration: configuration)
        browserView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        browserView.navigationDelegate = self
        browserView.backgroundColor = .black
        browserView.scrollView.contentInsetAdjustmentBehavior = .never
        browserView.scrollView.contentInset = .zero
        browserView.scrollView.scrollIndicatorInsets = .zero
        
        view.addSubview(browserView)
        view.backgroundColor = .black
        
        if let address = URL(string: linkString) {
            let request = URLRequest(url: address)
            browserView.load(request)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.orientationLock = .allButUpsideDown
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.orientationLock = .portrait
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        browserView.frame = view.bounds
    }
}

extension FullScreenBrowserViewController: WKNavigationDelegate {
    func webView(_ browserView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if hasInitiallyLoaded?.wrappedValue == false {
            isLoading?.wrappedValue = true
        }
    }
    
    func webView(_ browserView: WKWebView, didFinish navigation: WKNavigation!) {
        if hasInitiallyLoaded?.wrappedValue == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.isLoading?.wrappedValue = false
                self.hasInitiallyLoaded?.wrappedValue = true
            }
        }
    }
    
    func webView(_ browserView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if hasInitiallyLoaded?.wrappedValue == false {
            isLoading?.wrappedValue = false
            hasInitiallyLoaded?.wrappedValue = true
        }
    }
}

