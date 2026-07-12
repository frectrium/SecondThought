//
//  RootView.swift
//  SecondThought
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Urge.createdAt, order: .reverse) private var urges: [Urge]
    @State private var showingLog = false
    @State private var deciding: Urge?

    private var waiting: [Urge] { urges.filter(\.isWaiting) }
    private var ripe: [Urge]    { urges.filter(\.isRipe) }

    var body: some View {
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
            // .sheet(item: $deciding) { urge in VerdictView(urge: urge) }   // wired in step 8
        }
    }
}
