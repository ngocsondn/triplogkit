//
//  AsyncFunFactView.swift
//  TripLogKit
//
//  Demo async/await cơ bản trong SwiftUI: .task(id:) tự chạy khi view
//  xuất hiện / khi `activity` đổi, và tự cancel khi view biến mất —
//  không cần tự quản lý Task { } thủ công như kiểu onAppear cũ.
//

import SwiftUI

struct AsyncFunFactView: View {
    let activity: String

    @State private var fact: String?
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Fun fact về \(activity)")
                .font(.title2.bold())

            Group {
                if isLoading {
                    ProgressView("Đang tải...")
                } else if let fact {
                    Text(fact)
                        .multilineTextAlignment(.center)
                } else if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .frame(minHeight: 80)
            .padding(.horizontal)

            Button("Tải lại") {
                Task { await load() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
        }
        .padding()
        .navigationTitle("Async Demo")
        .task(id: activity) {
            await load()
        }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        fact = nil
        do {
            fact = try await FunFactService.fetchFunFact(for: activity)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        AsyncFunFactView(activity: "Archery")
    }
}
