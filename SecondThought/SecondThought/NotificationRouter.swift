//
//  NotificationRouter.swift
//  SecondThought
//

import Foundation
import Observation
import UserNotifications

@Observable
final class NotificationRouter {
    var pendingUrgeID: UUID?
}

/// Bridges UNUserNotificationCenter's delegate callbacks (which are not
/// SwiftUI-aware) into the router, and tells iOS to show banners even while
/// the app is in the foreground — without this, a notification that fires
/// while you're looking at the app is delivered silently.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    let router: NotificationRouter

    init(router: NotificationRouter) {
        self.router = router
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse) async {
        guard let idString = response.notification.request.content.userInfo["urgeID"] as? String,
              let id = UUID(uuidString: idString) else { return }
        router.pendingUrgeID = id
    }
}
