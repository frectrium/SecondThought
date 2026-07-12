//
//  UrgeStats.swift
//  SecondThought
//

import Foundation

struct UrgeStats {
    let skipped: [Urge]
    let bought: [Urge]
    let savedTotal: Double
    let resistRate: Double

    init(urges: [Urge]) {
        skipped = urges.filter { $0.verdict == .skipped }
        bought = urges.filter { $0.verdict == .bought }
        savedTotal = skipped.reduce(0) { $0 + $1.price }
        let decided = skipped.count + bought.count
        resistRate = decided == 0 ? 0 : Double(skipped.count) / Double(decided)
    }
}
