//
//  Notifier.swift
//  SecondThought
//

import Foundation
import UserNotifications

enum Notifier {
    static let categoryID = "URGE_READY"
    static let stillWantID = "STILL_WANT"
    static let letGoID = "LET_GO"

    /// Registers the two buttons that appear when you long-press the notification.
    static func configureCategories() {
        let still = UNNotificationAction(identifier: stillWantID,
                                         title: "I still want it", options: [.foreground])
        let letGo = UNNotificationAction(identifier: letGoID,
                                         title: "Let it go", options: [.destructive])
        let category = UNNotificationCategory(identifier: categoryID,
                                              actions: [still, letGo],
                                              intentIdentifiers: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    @discardableResult
    static func requestPermission() async -> Bool {
        (try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    /// Takes plain values, not the Urge object — SwiftData models are not
    /// Sendable, so handing one into a Task is a Swift 6 concurrency error.
    static func schedule(id: UUID, itemName: String, reason: String,
                         wantLevel: Int, readyAt: Date) async {
        let content = UNMutableNotificationContent()
        content.title = "Still want the \(itemName)?"
        content.body = reason.isEmpty
            ? "You rated this \(wantLevel)/10. Still want it?"
            : "You said: \u{201C}\(reason)\u{201D} — still want it?"
        content.sound = .default
        content.categoryIdentifier = categoryID
        content.userInfo = ["urgeID": id.uuidString]

        let seconds = max(1, readyAt.timeIntervalSinceNow)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: id.uuidString,
                                            content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }

    /// Cancel if the user decides early or deletes the urge.
    static func cancel(id: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
}
