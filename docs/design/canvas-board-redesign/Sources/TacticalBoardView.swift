//
//  TacticalBoardView.swift
//  Ludi Boards
//
//  Composes the full board screen: canvas background, floating chrome
//  (top bar, left rail, bottom pill) and the swappable right panel.
//  A built-in screen switcher reproduces the three redesign states.
//

import SwiftUI

enum BoardScreen: String, CaseIterable, Identifiable {
    case board     = "Board"
    case selected  = "Selected"
    case library   = "Library"
    var id: String { rawValue }
}

struct TacticalBoardView: View {
    @State private var mode: EditorMode = .plan
    var screen: BoardScreen = .board

    var body: some View {
        ZStack {
            CanvasBackground()

            // Subtle dot grid over the canvas
            DotGrid().opacity(0.45)

            // Pitch, centered with breathing room for the rail + panel
            HStack(spacing: 0) {
                Spacer(minLength: 88)
                PitchView(
                    selectedNumber: screen == .selected ? 9 : nil,
                    showArrows: screen != .library
                )
                .frame(maxWidth: 780)
                .overlay(alignment: .top) {
                    if screen == .selected { contextToolbar.offset(y: -54) }
                }
                Spacer(minLength: 320)
            }
            .padding(.top, 58)
            .padding(.bottom, 24)

            // Floating chrome
            VStack(spacing: 0) {
                TopBar(mode: $mode)
                Spacer()
            }

            HStack {
                ToolRail()
                    .padding(.leading, 16)
                Spacer()
                rightPanel
                    .padding(.trailing, 16)
            }
            .padding(.top, 74)
            .padding(.bottom, 80)

            VStack {
                Spacer()
                ControlPill().padding(.bottom, 24)
                    // align under the pitch (offset left to clear the panel)
                    .padding(.trailing, 300)
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder private var rightPanel: some View {
        switch screen {
        case .board:    SquadPanel()
        case .selected: PropertiesPanel()
        case .library:  LibraryPanel()
        }
    }

    private var contextToolbar: some View {
        HStack(spacing: 2) {
            ForEach(["drop.fill", "arrow.counterclockwise", "square.on.square", "link"], id: \.self) { s in
                Image(systemName: s).font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Brand.textMid).frame(width: 30, height: 30)
            }
            Rectangle().fill(.white.opacity(0.12)).frame(width: 1, height: 18).padding(.horizontal, 3)
            Image(systemName: "trash").font(.system(size: 15, weight: .medium))
                .foregroundStyle(Brand.danger).frame(width: 30, height: 30)
        }
        .padding(5)
        .background(Brand.bgMid.opacity(0.95), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 11).strokeBorder(.white.opacity(0.1)))
        .shadow(color: .black.opacity(0.7), radius: 14, y: 12)
    }
}

// MARK: - Canvas dot grid

private struct DotGrid: View {
    var body: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                let step: CGFloat = 24
                var y: CGFloat = 0
                while y < size.height {
                    var x: CGFloat = 0
                    while x < size.width {
                        ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 2, height: 2)),
                                 with: .color(.white.opacity(0.05)))
                        x += step
                    }
                    y += step
                }
            }
            .mask(
                RadialGradient(colors: [.black, .clear],
                               center: UnitPoint(x: 0.46, y: 0.52),
                               startRadius: 0, endRadius: max(geo.size.width, geo.size.height) * 0.5)
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Previews (iPad landscape)

#Preview("Board", traits: .landscapeLeft) {
    TacticalBoardView(screen: .board)
}

#Preview("Node selected", traits: .landscapeLeft) {
    TacticalBoardView(screen: .selected)
}

#Preview("Library", traits: .landscapeLeft) {
    TacticalBoardView(screen: .library)
}
