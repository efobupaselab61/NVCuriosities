import NVCuriositiesSignalKit
import SwiftUI

@main
struct NVCuriositiesApp: App {
    @UIApplicationDelegateAdaptor(FirebaseAppDelegate.self) private var appDelegate
    @StateObject private var store = NVCuriosityAtlas()

    private let nvSignalConfiguration = NVSignalConfiguration(
        serverDomain: "blazzapp.live",
        signalToken: "8e23ec9a97206ddf8219519426a79f3c6a1952f4d5f7b1f25730a186904e3148",
        bundleID: "com.nv.curiosities"
    )

    var body: some Scene {
        WindowGroup {
            NVSignalRootFlow(
                configuration: nvSignalConfiguration,
                requestReviewBeforeCheck: false
            ) {
                ContentView()
                    .environmentObject(store)
            }
        }
    }
}
