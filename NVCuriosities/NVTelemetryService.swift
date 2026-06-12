import FirebaseAnalytics
import FirebaseCore
import Foundation
import UserNotifications

final class NVTelemetryService {
    static let shared = NVTelemetryService()

    private init() {}

    func logAppOpen() {
        log("nv_curiosities_opened")
    }

    func logScreen(_ name: String) {
        guard isFirebaseReady else { return }
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name,
            AnalyticsParameterScreenClass: name
        ])
    }

    func logOnboardingCompleted(preferredSignalMoods: [String]) {
        log("nv_radar_onboarding_completed", [
            "signal_moods": preferredSignalMoods.joined(separator: ",")
        ])
    }

    func logEntryViewed(_ entry: NVCuriosityEntry, source: String) {
        log("nv_wonder_viewed", entryParameters(entry, source: source))
    }

    func logEntryVaulted(_ entry: NVCuriosityEntry, isVaulted: Bool) {
        var parameters = entryParameters(entry, source: "action")
        parameters["is_vaulted"] = isVaulted
        log("nv_wonder_vault_toggled", parameters)
    }

    func logEntryStarred(_ entry: NVCuriosityEntry, isStarred: Bool) {
        var parameters = entryParameters(entry, source: "action")
        parameters["is_starred"] = isStarred
        log("nv_wonder_star_toggled", parameters)
    }

    func logRevealStory(_ entry: NVCuriosityEntry) {
        log("nv_story_revealed", entryParameters(entry, source: "today"))
    }

    func logCategoryOpened(_ category: String) {
        log("nv_shelf_opened", ["shelf": category])
    }

    func logSignalDraw(signalMood: String?, result: NVCuriosityEntry?) {
        var parameters: [String: Any] = ["signal_mood": signalMood ?? "Any"]
        if let result {
            parameters.merge(entryParameters(result, source: "signal_draw")) { _, new in new }
        }
        log("nv_signal_drawn", parameters)
    }

    func logQuizAnswered(question: String, selectedAnswer: String, isCorrect: Bool) {
        log("nv_quiz_answered", [
            "question": question,
            "selected_answer": selectedAnswer,
            "is_correct": isCorrect
        ])
    }

    func logPushPermission(status: UNAuthorizationStatus) {
        log("nv_push_permission_status", ["status": String(describing: status)])
    }

    func logPushTokenRefresh() {
        log("nv_push_token_refreshed")
    }

    func logPushRegistrationFailed(_ message: String) {
        log("nv_push_registration_failed", ["message": message])
    }

    func logPushReceivedForeground(_ identifier: String) {
        log("nv_push_received_foreground", ["notification_id": identifier])
    }

    func logPushOpened(_ identifier: String) {
        log("nv_push_opened", ["notification_id": identifier])
    }

    private var isFirebaseReady: Bool {
        FirebaseApp.app() != nil
    }

    private func log(_ name: String, _ parameters: [String: Any]? = nil) {
        guard isFirebaseReady else { return }
        Analytics.logEvent(name, parameters: parameters)
    }

    private func entryParameters(_ entry: NVCuriosityEntry, source: String) -> [String: Any] {
        [
            "nv_wonder_id": entry.id,
            "wonder_title": entry.title,
            "shelf": entry.category,
            "rarity_band": entry.rarity,
            "signal_mood": entry.mood,
            "source": source
        ]
    }
}
