import SwiftUI

struct OrientationLock: UIViewControllerRepresentable {
    let orientations: UIInterfaceOrientationMask
    
    func makeUIViewController(context: Context) -> OrientationLockController {
        let controller = OrientationLockController()
        controller.orientations = orientations
        return controller
    }
    
    func updateUIViewController(_ uiViewController: OrientationLockController, context: Context) {
        if uiViewController.orientations != orientations {
            uiViewController.orientations = orientations
        }
    }
}

class OrientationLockController: UIViewController {
    var orientations: UIInterfaceOrientationMask = .portrait {
        didSet {
            if orientations != oldValue {
                DispatchQueue.main.async {
                    self.setNeedsUpdateOfSupportedInterfaceOrientations()
                    if #available(iOS 16.0, *) {
                        if let windowScene = self.view.window?.windowScene {
                            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: self.orientations))
                        }
                    }
                }
            }
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return orientations
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 16.0, *) {
            if let windowScene = view.window?.windowScene {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientations))
            }
        }
    }
}

