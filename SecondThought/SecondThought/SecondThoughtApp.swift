//
//  SecondThoughtApp.swift
//  SecondThought
//
//  Created by Parshv Joshi on 12/07/26.
//

import SwiftUI
import SwiftData

@main
struct SecondThoughtApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    Notifier.configureCategories()
                    await Notifier.requestPermission()
                }
        }
        .modelContainer(for: Urge.self)
    }
}
