//
//  SoccerPlayerToolView.swift
//  CoreEngine — tactical board redesign (TASK-004)
//
//  Renders a soccer "player" tool as a numbered jersey disc (the redesign
//  token look) instead of the legacy flat asset image. Colour comes from the
//  tool's `toolColor`; the number is a deterministic PLACEHOLDER derived from
//  the tool id until the roster model lands (RD-5 / TASK-011) and supplies real
//  jersey numbers. Used by `ViewEngine.Tool.SoccerTool.Build` for player
//  subtypes; equipment subtypes keep their images.
//

import SwiftUI

public struct SoccerPlayerToolView: View {
    let viewId: String

    @State private var fill: Color = Color(hex: "4D8576")   // home default
    @State private var ink: Color = .white
    @State private var number: Int = 1

    public init(viewId: String) { self.viewId = viewId }

    public var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [fill.opacity(0.96), fill.opacity(0.72)],
                                         startPoint: .top, endPoint: .bottom))
                Circle()
                    .strokeBorder(Color.white.opacity(0.30), lineWidth: max(2, d * 0.05))
                Text("\(number)")
                    .font(.system(size: d * 0.46, weight: .bold, design: .rounded))
                    .foregroundColor(ink)
                    .shadow(color: .black.opacity(0.35), radius: d * 0.01, y: 1)
            }
            .frame(width: d, height: d)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
            .shadow(color: .black.opacity(0.42), radius: d * 0.05, y: d * 0.03)
        }
        .onAppear(perform: load)
    }

    private func load() {
        let realm = newRealm()
        guard let mv = realm.object(ofType: ManagedView.self, forPrimaryKey: viewId) else {
            number = Self.placeholderNumber(viewId); return
        }
        // Real roster number when linked (RD-5), else a stable placeholder.
        number = mv.jerseyNumber > 0 ? mv.jerseyNumber : Self.placeholderNumber(viewId)
        switch mv.teamSide {
        case "home":
            fill = Color(hex: "4D8576"); ink = .white
        case "away":
            fill = Color(hex: "E9EDF1"); ink = Color(hex: "1D2632")   // light jersey, dark ink
        default:
            ink = .white
            if !mv.toolColor.isEmpty {
                fill = ColorProvider.fromColorName(colorName: mv.toolColor).colorValue
            }
        }
    }

    /// Deterministic 1–30 placeholder from the tool id (stable across launches,
    /// unlike `String.hashValue`). Replaced by real roster numbers in RD-5.
    public static func placeholderNumber(_ id: String) -> Int {
        let sum = id.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return (sum % 30) + 1
    }
}
