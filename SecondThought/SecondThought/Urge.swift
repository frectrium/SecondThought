//
//  Urge.swift
//  SecondThought
//

import Foundation
import SwiftData

enum Verdict: String, Codable, CaseIterable {
    case waiting, bought, skipped
}

@Model
final class Urge {
    var id: UUID = UUID()
    var itemName: String = ""
    var price: Double = 0
    var link: String = ""
    var reason: String = ""          // why I want it, in my own words
    var wantLevel: Int = 5            // 1-10, how badly I wanted it AT THE TIME
    var createdAt: Date = Date.now
    var cooldownSeconds: Double = 86_400
    var verdictRaw: String = Verdict.waiting.rawValue
    var decidedAt: Date? = nil

    init(itemName: String, price: Double, link: String = "", reason: String = "",
         wantLevel: Int = 5, cooldownSeconds: Double) {
        self.id = UUID()
        self.itemName = itemName
        self.price = price
        self.link = link
        self.reason = reason
        self.wantLevel = wantLevel
        self.createdAt = .now
        self.cooldownSeconds = cooldownSeconds
        self.verdictRaw = Verdict.waiting.rawValue
    }

    var verdict: Verdict {
        get { Verdict(rawValue: verdictRaw) ?? .waiting }
        set { verdictRaw = newValue.rawValue }
    }

    /// Derived, never stored — the single source of truth for the timer.
    var readyAt: Date { createdAt.addingTimeInterval(cooldownSeconds) }
    var isRipe: Bool { verdict == .waiting && Date.now >= readyAt }
    var isWaiting: Bool { verdict == .waiting && Date.now < readyAt }
}
