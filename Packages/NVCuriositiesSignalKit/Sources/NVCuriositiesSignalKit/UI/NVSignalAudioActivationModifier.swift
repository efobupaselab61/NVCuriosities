import SwiftUI

#if canImport(UIKit)
import UIKit

private struct NVSignalAudioActivationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                NVSignalBrowserRuntime.activateGameAudio()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                NVSignalBrowserRuntime.activateGameAudio()
            }
    }
}

extension View {
    func nvSignalKeepsAudioAlive() -> some View {
        modifier(NVSignalAudioActivationModifier())
    }
}
#endif
