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
        }
        .modelContainer(for: Urge.self)
    }
}
