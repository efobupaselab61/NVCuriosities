import FirebaseCore
import FirebaseMessaging
import Foundation
import UIKit
import UserNotifications

@MainActor
final class PushNotificationService: ObservableObject {
    static let shared = PushNotificationService()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var fcmToken: String?

    private let permissionAskedKey = "nv.push.permissionAsked"

    private init() {}

    func configureNotificationsIfNeeded() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            authorizationStatus = settings.authorizationStatus
            NVTelemetryService.shared.logPushPermission(status: settings.authorizationStatus)

            guard FirebaseApp.app() != nil else { return }
            guard settings.authorizationStatus == .notDetermined else {
                await registerForRemoteNotificationsIfAuthorized(settings.authorizationStatus)
                return
            }

            guard !UserDefaults.standard.bool(forKey: permissionAskedKey) else { return }
            UserDefaults.standard.set(true, forKey: permissionAskedKey)
            await requestAuthorization()
        }
    }

    func updateFCMToken(_ token: String?) {
        fcmToken = token
    }

    private func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            let status: UNAuthorizationStatus = granted ? .authorized : .denied
            authorizationStatus = status
            NVTelemetryService.shared.logPushPermission(status: status)
            await registerForRemoteNotificationsIfAuthorized(status)
        } catch {
            NVTelemetryService.shared.logPushRegistrationFailed(error.localizedDescription)
        }
    }

    private func registerForRemoteNotificationsIfAuthorized(_ status: UNAuthorizationStatus) async {
        guard status == .authorized || status == .provisional || status == .ephemeral else { return }
        UIApplication.shared.registerForRemoteNotifications()
        do {
            fcmToken = try await Messaging.messaging().token()
            NVTelemetryService.shared.logPushTokenRefresh()
        } catch {
            NVTelemetryService.shared.logPushRegistrationFailed(error.localizedDescription)
        }
    }
}
