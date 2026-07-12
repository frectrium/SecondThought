//
//  LogUrgeView.swift
//  SecondThought
//

import SwiftUI
import SwiftData

struct LogUrgeView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var itemName = ""
    @State private var price = ""
    @State private var link = ""
    @State private var reason = ""
    @State private var wantLevel = 5.0
    @State private var cooldown: Double = 86_400

    private let presets: [(String, Double)] = [
        ("20 minutes", 1_200), ("24 hours", 86_400),
        ("72 hours", 259_200), ("30 days", 2_592_000)
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("What do you want?") {
                    TextField("Item", text: $itemName)
                    TextField("Price", text: $price)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                    TextField("Link (optional)", text: $link)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                }
                Section("Why do you want it?") {
                    TextField("Write it out. Future you reads this.", text: $reason, axis: .vertical)
                        .lineLimit(3...6)
                    VStack(alignment: .leading) {
                        Text("How badly, right now: \(Int(wantLevel))/10")
                        Slider(value: $wantLevel, in: 1...10, step: 1)
                    }
                }
                Section("Wait how long?") {
                    Picker("Cooldown", selection: $cooldown) {
                        ForEach(presets, id: \.1) { Text($0.0).tag($0.1) }
                    }.pickerStyle(.segmented)
                }
            }
            .navigationTitle("Log an urge")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start timer") { save() }
                        .disabled(itemName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func save() {
        let urge = Urge(
            itemName: itemName.trimmingCharacters(in: .whitespaces),
            price: Double(price) ?? 0,
            link: link, reason: reason,
            wantLevel: Int(wantLevel),
            cooldownSeconds: cooldown
        )
        context.insert(urge)
        try? context.save()

        // Copy out plain values before the Task — never hand a SwiftData model
        // to another concurrency context. (Wired to Notifier in step 7.)
        // let id = urge.id, name = urge.itemName, why = urge.reason
        // let level = urge.wantLevel, readyAt = urge.readyAt
        // Task {
        //     await Notifier.schedule(id: id, itemName: name, reason: why,
        //                             wantLevel: level, readyAt: readyAt)
        // }
        dismiss()
    }
}
