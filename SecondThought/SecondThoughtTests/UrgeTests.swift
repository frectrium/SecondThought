//
//  UrgeTests.swift
//  SecondThoughtTests
//

import Testing
import Foundation
@testable import SecondThought

struct UrgeTests {

    @Test func readyAtIsDerivedFromCreatedAtAndCooldown() {
        let urge = Urge(itemName: "AirPods Max", price: 549, cooldownSeconds: 3600)
        let expected = urge.createdAt.addingTimeInterval(3600)
        #expect(abs(urge.readyAt.timeIntervalSince(expected)) < 0.001)
    }

    @Test func isWaitingWhenCooldownHasNotElapsed() {
        let urge = Urge(itemName: "AirPods Max", price: 549, cooldownSeconds: 3600)
        #expect(urge.isWaiting)
        #expect(!urge.isRipe)
    }

    @Test func isRipeWhenCooldownHasElapsed() {
        let urge = Urge(itemName: "AirPods Max", price: 549, cooldownSeconds: 0.01)
        Thread.sleep(forTimeInterval: 0.05)
        #expect(urge.isRipe)
        #expect(!urge.isWaiting)
    }

    @Test func verdictDefaultsToWaiting() {
        let urge = Urge(itemName: "AirPods Max", price: 549, cooldownSeconds: 100)
        #expect(urge.verdict == .waiting)
    }

    @Test func verdictRoundTripsThroughRawValue() {
        let urge = Urge(itemName: "AirPods Max", price: 549, cooldownSeconds: 100)
        urge.verdict = .skipped
        #expect(urge.verdictRaw == "skipped")
        #expect(urge.verdict == .skipped)
    }

    @Test func neitherRipeNorWaitingOnceDecided() {
        let urge = Urge(itemName: "AirPods Max", price: 549, cooldownSeconds: 0.01)
        Thread.sleep(forTimeInterval: 0.05)
        urge.verdict = .bought
        #expect(!urge.isRipe)
        #expect(!urge.isWaiting)
    }

    @Test func defaultWantLevelIsFive() {
        let urge = Urge(itemName: "AirPods Max", price: 549, cooldownSeconds: 100)
        #expect(urge.wantLevel == 5)
    }
}
