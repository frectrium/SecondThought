# Second Thought

An iOS app that intercepts impulse purchases: log the thing you want, sit out a
cooling-off timer, and when it ends the app asks once — do you still need it?
SwiftUI + SwiftData + local notifications (UserNotifications). Built and tested
on the iOS 26.5 simulator (iPhone 17) in Xcode 26.6.

## Source of truth

This build follows `work-artifacts/walkthrough-curriculum.json` step by step
(12 steps, schema `live_coach_curriculum.v1`). That file has the full
instructions, code listings, success criteria, and "why it matters" reasoning
for every step — read it before assuming anything about scope or ordering.
Don't re-derive the plan from scratch; it's already fully specified there.

## Decisions locked so far

- **App name: Second Thought** (target/bundle name `SecondThought`). Display
  name under the icon can still change later; the Xcode project/target name
  cannot without pain, which is why this was decided first (step 1).
- **Core loop (v1 scope, do not expand):** "I log the thing I want, the app
  makes me wait, and when the timer ends it asks me once: do you still need
  it?" Out of scope for v1: bank/card sync, blocking Amazon/Safari,
  accounts/login, social/sharing, widgets, Apple Watch.
- **4 screens:** Waiting list, Log an urge, The Verdict, Stats.

## Toolchain state (verified on this Mac)

- Xcode 26.6, macOS 26.5.1, iOS 26.5 simulators (iPhone 17 family, iPhone Air,
  iPad) installed.
- `xcode-select` switched from Command Line Tools to
  `/Applications/Xcode.app/Contents/Developer` — `xcodebuild -version` now
  reports Xcode 26.6.
- iPhone 17 (iOS 26.5) simulator is booted and visible.

## Platform note

The Xcode 26 wizard set `SUPPORTED_PLATFORMS` to iPhone + iPad + Mac +
visionOS by default (`TARGETED_DEVICE_FAMILY = "1,2,7"`), even though step 3
only asked for "iOS > App". This means UIKit-only APIs
(`.keyboardType`, `.textInputAutocapitalization`, `UIImpactFeedbackGenerator`,
etc.) must be wrapped in `#if os(iOS) ... #endif` or the macOS/visionOS build
fails. Verify new view code against both `platform=iOS Simulator,name=iPhone
17` and `platform=macOS` destinations, not just the iOS one, since Xcode's own
Cmd+R may target either depending on the selected scheme destination.

## Data model conventions (once step 4 lands)

- `Urge.readyAt` is **computed** from `createdAt + cooldownSeconds`, never
  stored — keeps the countdown timer from ever drifting out of sync.
- `wantLevel` is captured once at logging time and never updated — it's the
  evidence shown back to the user in The Verdict.
- Countdown UI must use `Text(timerInterval:countsDown:)`, not a hand-rolled
  `Timer` — avoids per-second view redraws.
- Notification scheduling takes plain values (id/name/reason/date), never the
  `Urge` `@Model` object itself — SwiftData models aren't `Sendable`.
- `RootView`'s "waiting" vs. "ripe" section membership is a plain computed
  property, so it only re-evaluates when the view body re-runs. Nothing about
  the underlying SwiftData changes when the clock crosses `readyAt`, so
  without a periodic nudge an item can sit at "0:00" indefinitely while the
  app stays open. Fixed by wrapping `RootView`'s body in
  `TimelineView(.periodic(from: .now, by: 5))` — a 5s cadence is cheap and far
  coarser than the countdown digits themselves, which still tick every second
  via `Text(timerInterval:)` independent of this.
- No notification banner while the app is foregrounded is expected until step
  8's `willPresent` delegate is wired — iOS suppresses foreground banners
  without it. Always test notification delivery by backgrounding the app
  (Cmd+Shift+H / Cmd+L in the simulator), not by watching the app stay open.

## Testing

`SecondThoughtTests` is a Swift Testing (`import Testing`, `@Test`/`#expect`)
unit test target, added by script (`xcodeproj` Ruby gem) since the Xcode
wizard in step 3 was told `Testing System: None`. Run the suite with:

    cd SecondThought && xcodebuild test -scheme SecondThought \
      -destination 'platform=iOS Simulator,name=iPhone 17'

Add a test alongside each pure-logic step (model, verdict resolution, stats
math) as it's built — don't wait until the end to write these.

## Working agreement

- Go step by step through the curriculum; don't skip ahead.
- Steps marked `human_only` or with a `mac_permission` gate (Xcode project
  wizard, notification permission tap, Apple ID sign-in/2FA, payment) must
  stop and hand back to the user — never attempt to perform or simulate these.
- Never ask for or handle an Apple ID password, 2FA code, or payment details.
- Prefer showing exact code and exact Xcode menu paths over describing them.
- On a build failure, ask for the exact red error text rather than guessing.
