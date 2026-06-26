//
//  LudiBoardsApp.swift
//  Ludi Boards
//
//  App entry point. A small overlay switcher lets you flip between the
//  three redesign screens at runtime — remove it for production.
//

import SwiftUI

@main
struct LudiBoardsApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @State private var screen: BoardScreen = .board

    var body: some View {
        TacticalBoardView(screen: screen)
            .overlay(alignment: .bottomTrailing) {
                Picker("Screen", selection: $screen) {
                    ForEach(BoardScreen.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .frame(width: 280)
                .padding(10)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(20)
            }
    }
}
