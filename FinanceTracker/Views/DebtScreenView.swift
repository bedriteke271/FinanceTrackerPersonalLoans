import SwiftUI
import WebKit

struct DebtScreenView: View {
    let linkString: String
    @State private var isLoading = true
    @State private var hasInitiallyLoaded = false
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            if isLoading && !hasInitiallyLoaded {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
            
            FullScreenBrowserView(
                linkString: linkString,
                isLoading: $isLoading,
                hasInitiallyLoaded: $hasInitiallyLoaded
            )
            .opacity(isLoading && !hasInitiallyLoaded ? 0 : 1)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            AppDelegate.orientationLock = .allButUpsideDown
        }
        .onDisappear {
            AppDelegate.orientationLock = .portrait
        }
    }
}


