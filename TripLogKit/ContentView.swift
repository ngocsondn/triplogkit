//
//  ContentView.swift
//  TripLogKit
//
//  Created by Sion-DEV on 12/2/25.
//

import SwiftUI

struct ContentView: View {
    let activities = ["Archery", "Baseball", "Basketball", "Bowling", "Boxing", "Cricket", "Curling", "Fencing", "Golf", "Hiking", "Lacrosse", "Rugby", "Squash"]
    
    let colors: [Color] = [.blue, .cyan, .gray, .green, .indigo, .mint, .orange, .pink, .purple, .red]


    @State private var selected = "Baseball"
    @State private var id = 1
    
    var body: some View {
        NavigationStack {
            Text("Why not try…").font(.largeTitle.bold())
            VStack {
                VStack {
                    Circle().fill(colors.randomElement() ?? .black).padding().overlay(Image(systemName: "figure.\(selected.lowercased())").font(.system(size: 144)).foregroundColor(.white))
                    Text(selected).font(.title)
                }
            }.transition(.slide).id(id)
            Spacer()
            Button("Try again") {
                withAnimation(.easeInOut(duration: 0.5)) {
                    selected = activities.randomElement() ?? "Archery"
                    id += 1
                }
            }
            .buttonStyle(.borderedProminent)

            NavigationLink("Auto Shuffle Demo (Memory Leak)") {
                AutoShuffleDetailView()
            }
            .padding(.top, 24)

            NavigationLink("Async/Await Demo (Fun Fact)") {
                AsyncFunFactView(activity: selected)
            }
            .padding(.top, 12)

            NavigationLink("Actor Demo (Race Condition)") {
                ActorRaceDemoView()
            }
            .padding(.top, 12)
        }
    }
}

#Preview {
    ContentView()
}
