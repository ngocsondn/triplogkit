//
//  ActorRaceDemoView.swift
//  TripLogKit
//
//  Demo actor & Sendable: chạy N Task đồng thời cùng tăng 1 counter,
//  so sánh class thường (mất update) với actor (luôn đúng).
//

import SwiftUI

struct ActorRaceDemoView: View {
    private let iterations = 200

    @State private var isRunning = false
    @State private var unsafeResult: Int?
    @State private var safeResult: Int?

    var body: some View {
        VStack(spacing: 20) {
            Text("Actor vs Race Condition")
                .font(.title2.bold())

            Text("Chạy \(iterations) Task đồng thời, mỗi Task tăng 1 counter dùng chung lên 1.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 12) {
                resultRow(title: "class thường (race)", value: unsafeResult)
                resultRow(title: "actor (an toàn)", value: safeResult)
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)

            Button(isRunning ? "Đang chạy…" : "Chạy race") {
                Task { await runRace() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRunning)
        }
        .padding()
        .navigationTitle("Actor Demo")
    }

    @ViewBuilder
    private func resultRow(title: String, value: Int?) -> some View {
        HStack {
            Text(title)
            Spacer()
            if let value {
                Text("\(value) / \(iterations)")
                    .bold()
                    .foregroundStyle(value == iterations ? .green : .red)
            } else {
                Text("—").foregroundStyle(.secondary)
            }
        }
    }

    private func runRace() async {
        isRunning = true
        unsafeResult = nil
        safeResult = nil

        let unsafeCounter = UnsafeScoreCounter()
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<iterations {
                group.addTask { await unsafeCounter.increment() }
            }
        }
        unsafeResult = unsafeCounter.score

        let safeCounter = ScoreCounter()
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<iterations {
                group.addTask { await safeCounter.increment() }
            }
        }
        safeResult = await safeCounter.score

        isRunning = false
    }
}

#Preview {
    NavigationStack {
        ActorRaceDemoView()
    }
}
