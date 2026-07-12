//
//  VerdictView.swift
//  SecondThought
//

import SwiftUI
import SwiftData
#if os(iOS)
import UIKit
#endif

struct VerdictView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let urge: Urge

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                Text("Still want\n\(urge.itemName)?")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                VStack(spacing: 8) {
                    Text("\(urge.createdAt, style: .relative) ago you said:")
                    if !urge.reason.isEmpty {
                        Text("\u{201C}\(urge.reason)\u{201D}")
                            .italic()
                            .multilineTextAlignment(.center)
                    }
                    Text("You wanted it \(urge.wantLevel)/10.")
                        .foregroundStyle(.secondary)
                }
                .font(.callout)
                .padding(.horizontal)

                Spacer()

                Button {
                    resolve(.skipped)
                } label: {
                    Label("No — let it go", systemImage: "wind")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("Yes, I still want it") { resolve(.bought) }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)

                Text("Saying yes is allowed. The point was to decide on purpose.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle(urge.price.formatted(.currency(code: "USD")))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    private func resolve(_ verdict: Verdict) {
        urge.verdict = verdict
        urge.decidedAt = .now
        try? context.save()
        Notifier.cancel(id: urge.id)
        if verdict == .skipped {
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            #endif
        }
        dismiss()
    }
}
