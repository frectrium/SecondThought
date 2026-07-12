//
//  StatsView.swift
//  SecondThought
//

import SwiftUI
import SwiftData

struct StatsView: View {
    @Query private var urges: [Urge]

    private var stats: UrgeStats { UrgeStats(urges: urges) }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 4) {
                        Text(stats.savedTotal, format: .currency(code: "USD"))
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                        Text("not spent").foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                Section("Track record") {
                    LabeledContent("Urges resisted", value: "\(stats.skipped.count)")
                    LabeledContent("Bought anyway", value: "\(stats.bought.count)")
                    LabeledContent("Resist rate", value: stats.resistRate.formatted(.percent.precision(.fractionLength(0))))
                }
                Section("Let go") {
                    if stats.skipped.isEmpty {
                        ContentUnavailableView("Nothing let go yet",
                            systemImage: "banknote",
                            description: Text("Resist an urge and it'll show up here."))
                    }
                    ForEach(stats.skipped) { urge in
                        LabeledContent(urge.itemName,
                                       value: urge.price.formatted(.currency(code: "USD")))
                    }
                }
            }
            .navigationTitle("Saved")
        }
    }
}
