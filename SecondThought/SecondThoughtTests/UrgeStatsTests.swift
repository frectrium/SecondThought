//
//  UrgeStatsTests.swift
//  SecondThoughtTests
//

import Testing
import Foundation
@testable import SecondThought

struct UrgeStatsTests {

    private func urge(price: Double, verdict: Verdict) -> Urge {
        let urge = Urge(itemName: "Test", price: price, cooldownSeconds: 100)
        urge.verdict = verdict
        return urge
    }

    @Test func emptyListHasZeroedStats() {
        let stats = UrgeStats(urges: [])
        #expect(stats.savedTotal == 0)
        #expect(stats.resistRate == 0)
        #expect(stats.skipped.isEmpty)
        #expect(stats.bought.isEmpty)
    }

    @Test func savedTotalSumsOnlySkippedPrices() {
        let urges = [
            urge(price: 100, verdict: .skipped),
            urge(price: 50, verdict: .skipped),
            urge(price: 999, verdict: .bought),
            urge(price: 20, verdict: .waiting),
        ]
        let stats = UrgeStats(urges: urges)
        #expect(stats.savedTotal == 150)
    }

    @Test func resistRateIgnoresStillWaitingUrges() {
        let urges = [
            urge(price: 10, verdict: .skipped),
            urge(price: 10, verdict: .bought),
            urge(price: 10, verdict: .waiting),
            urge(price: 10, verdict: .waiting),
        ]
        let stats = UrgeStats(urges: urges)
        // Only 1 skipped out of 2 decided (skipped + bought) = 50%.
        #expect(stats.resistRate == 0.5)
    }

    @Test func resistRateIsZeroWhenNothingHasBeenDecided() {
        let urges = [urge(price: 10, verdict: .waiting)]
        let stats = UrgeStats(urges: urges)
        #expect(stats.resistRate == 0)
    }

    @Test func resistRateIsOneWhenEverythingDecidedWasSkipped() {
        let urges = [
            urge(price: 10, verdict: .skipped),
            urge(price: 10, verdict: .skipped),
        ]
        let stats = UrgeStats(urges: urges)
        #expect(stats.resistRate == 1)
    }

    @Test func skippedAndBoughtPartitionCorrectly() {
        let urges = [
            urge(price: 10, verdict: .skipped),
            urge(price: 20, verdict: .bought),
            urge(price: 30, verdict: .waiting),
        ]
        let stats = UrgeStats(urges: urges)
        #expect(stats.skipped.count == 1)
        #expect(stats.bought.count == 1)
    }
}
