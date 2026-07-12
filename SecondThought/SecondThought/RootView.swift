//
//  RootView.swift
//  SecondThought
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Environment(NotificationRouter.self) private var router
    @Query(sort: \Urge.createdAt, order: .reverse) private var urges: [Urge]
    @State private var showingLog = false
    @State private var deciding: Urge?

    private var waiting: [Urge] { urges.filter(\.isWaiting) }
    private var ripe: [Urge]    { urges.filter(\.isRipe) }

    var body: some View {
        // Text(timerInterval:) ticks its own digits for free, but section
        // membership (waiting vs. ripe) is a plain computed property that
        // only re-evaluates when this body re-runs. Nothing about the
        // underlying data changes when the clock crosses readyAt, so without
        // this periodic nudge an item can sit at "0:00" indefinitely while
        // the app stays open and no other state changes. Every 5s is cheap
        // and far coarser than the countdown display itself.
        TimelineView(.periodic(from: .now, by: 5)) { _ in
            NavigationStack {
                List {
                    if !ripe.isEmpty {
                        Section("Time's up — decide") {
                            ForEach(ripe) { urge in
                                Button { deciding = urge } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(urge.itemName).font(.headline)
                                            Text("Still want it?").foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                }
                            }
                        }
                    }

                    Section("Cooling off") {
                        if waiting.isEmpty {
                            ContentUnavailableView("Nothing on ice",
                                systemImage: "hourglass",
                                description: Text("Next time you want to buy something, log it here first."))
                        }
                        ForEach(waiting) { urge in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(urge.itemName).font(.headline)
                                    Spacer()
                                    Text(urge.price, format: .currency(code: "USD"))
                                        .foregroundStyle(.secondary)
                                }
                                // Live countdown, no Timer needed:
                                Text(timerInterval: Date.now...urge.readyAt, countsDown: true)
                                    .font(.title3.monospacedDigit())
                                    .foregroundStyle(.tint)
                            }
                        }
                        .onDelete { idx in
                            for i in idx {
                                Notifier.cancel(id: waiting[i].id)
                                context.delete(waiting[i])
                            }
                        }
                    }
                }
                .navigationTitle("Second Thought")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Log an urge", systemImage: "plus") { showingLog = true }
                    }
                }
                .sheet(isPresented: $showingLog) { LogUrgeView() }
                .sheet(item: $deciding) { urge in VerdictView(urge: urge) }
                .onChange(of: router.pendingUrgeID) { _, newID in
                    guard let newID, let urge = urges.first(where: { $0.id == newID }) else { return }
                    deciding = urge
                    router.pendingUrgeID = nil
                }
            }
        }
    }
}
