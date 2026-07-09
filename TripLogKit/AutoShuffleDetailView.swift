//
//  AutoShuffleDetailView.swift
//  TripLogKit
//

import SwiftUI

struct AutoShuffleDetailView: View {
    @State private var manager = AutoShuffleManager()

    var body: some View {
        VStack(spacing: 10) {
            Text("Auto Shuffle Demo")
                .font(.title)
            Text("Tick: \(manager.tick)")
                .font(.title2.monospacedDigit())
            Text("Mở màn này rồi quay lại nhiều lần,\nsau đó kiểm tra Instruments để thấy\ninstance không bị giải phóng.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Leak Demo")
        .onDisappear { manager.stop() }
    }
}

#Preview {
    NavigationStack {
        AutoShuffleDetailView()
    }
}
