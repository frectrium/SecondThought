//
//  SecondThoughtApp.swift
//  SecondThought
//
//  Created by Parshv Joshi on 12/07/26.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct SecondThoughtApp: App {
    @State private var router = NotificationRouter()
    @State private var notificationDelegate: NotificationDelegate?

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .task {
                    let delegate = NotificationDelegate(router: router)
                    notificationDelegate = delegate
                    UNUserNotificationCenter.current().delegate = delegate

                    Notifier.configureCategories()
                    await Notifier.requestPermission()
                }
        }
        .modelContainer(for: Urge.self)
    }
}
