//
//  TacticalBoardView.swift
//  Ludi Boards
//
//  Composes the full board screen: canvas background, floating chrome
//  (top bar, left rail, bottom pill) and the swappable right panel.
//  A built-in screen switcher reproduces the three redesign states.
//

import SwiftUI
import CoreEngine
import RealmSwift

enum BoardScreen: String, CaseIterable, Identifiable {
    case board     = "Board"
    case selected  = "Selected"
    case library   = "Library"
    var id: String { rawValue }
}

struct TacticalBoardView: View {
    @ObservedObject var state: BoardScreenState

    /// When true, the board layer hosts the LIVE engine canvas
    /// (`RedesignBoardCanvas` → real `ManagedView` tools). When false (previews
    /// / render harness) it draws the self-contained static `PitchView`.
    var useEngineCanvas: Bool = false

    /// State-driven scaffold (live use): owner holds the `@StateObject`.
    init(state: BoardScreenState, useEngineCanvas: Bool = false) {
        self.state = state
        self.useEngineCanvas = useEngineCanvas
    }

    /// Convenience for previews / the render harness — seeds a fresh state
    /// from a static demo screen.
    init(screen: BoardScreen = .board) { self.state = BoardScreenState(demo: screen) }

    var body: some View {
        // Floating chrome is the PRIMARY content; the canvas + background sit
        // behind it via `.background`. This guarantees the chrome stays on top —
        // the engine canvas's `GlobalPositioningZStack` hard-frames itself to
        // 20000×20000, so as a ZStack sibling it would occlude the chrome.
        ZStack {
            // Floating chrome. Present mode goes full-screen: only the top bar
            // stays (to switch back); rail / pill / panels / context bar hide.
            let presenting = state.mode == .present

            VStack(spacing: 0) {
                Group {
                    if useEngineCanvas { EngineTopBar(state: state) } else { TopBar(mode: $state.mode) }
                }
                Spacer()
            }

            if !presenting {
                // Context toolbar on the selected engine tool (duplicate / delete).
                if useEngineCanvas, state.hasSelection {
                    VStack {
                        RedesignContextToolbar(state: state).padding(.top, 78)
                        Spacer()
                    }
                }

                HStack {
                    Group {
                        if useEngineCanvas { EngineToolRail() } else { ToolRail() }
                    }
                    .padding(.leading, 16)
                    Spacer()
                    rightPanel
                        .padding(.trailing, 16)
                }
                .padding(.top, 74)
                .padding(.bottom, 80)

                VStack {
                    Spacer()
                    Group {
                        if useEngineCanvas { EngineControlPill() } else { ControlPill() }
                    }
                    .padding(.bottom, 24)
                    // align under the pitch (offset left to clear the panel)
                    .padding(.trailing, 300)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(alignment: .center) {
            ZStack {
                CanvasBackground()
                DotGrid().opacity(0.45)
                boardLayer
            }
            .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.18), value: state.panel)
    }

    @ViewBuilder private var boardLayer: some View {
        if useEngineCanvas {
            // Live engine canvas fills the board area; chrome floats over it.
            // Constrain + clip so the 20000×20000 canvas doesn't expand the
            // parent ZStack (which would push the floating chrome off-screen).
            RedesignBoardCanvas()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
        } else {
            // Static mockup pitch, centered with breathing room for rail + panel.
            HStack(spacing: 0) {
                Spacer(minLength: 88)
                PitchView(
                    selectedNumber: state.hasSelection ? 9 : nil,
                    showArrows: state.panel != .library
                )
                .frame(maxWidth: 780)
                .overlay(alignment: .top) {
                    if state.hasSelection { contextToolbar.offset(y: -54) }
                }
                Spacer(minLength: 320)
            }
            .padding(.top, 58)
            .padding(.bottom, 24)
        }
    }

    @ViewBuilder private var rightPanel: some View {
        switch state.panel {
        case .squad:      if useEngineCanvas { EngineSquadPanel(state: state) } else { SquadPanel() }
        case .properties: if useEngineCanvas { EnginePropertiesPanel(state: state) } else { PropertiesPanel() }
        case .library:    if useEngineCanvas { EngineLibraryPanel() } else { LibraryPanel() }
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

// MARK: - Context toolbar (engine-wired duplicate / delete on the selected tool)

struct RedesignContextToolbar: View {
    @EnvironmentObject var BEO: BoardEngineObject
    @ObservedObject var state: BoardScreenState

    var body: some View {
        HStack(spacing: 2) {
            iconButton("square.on.square", Brand.textMid, action: duplicateSelected)
            iconButton("link", Brand.textMid) { /* link to roster player — RD-5 */ }
            Rectangle().fill(.white.opacity(0.12)).frame(width: 1, height: 18).padding(.horizontal, 3)
            iconButton("trash", Brand.danger, action: deleteSelected)
        }
        .padding(5)
        .background(Brand.bgMid.opacity(0.95), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 11).strokeBorder(.white.opacity(0.1)))
        .shadow(color: .black.opacity(0.7), radius: 14, y: 12)
    }

    private func iconButton(_ symbol: String, _ tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol).font(.system(size: 15, weight: .medium))
                .foregroundStyle(tint).frame(width: 30, height: 30)
        }
        .buttonStyle(.plain)
    }

    private func deleteSelected() {
        guard let id = state.selectedToolId,
              let mv = BEO.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: id) else { return }
        BEO.realmInstance.safeWrite { _ in mv.isDeleted = true }   // soft delete
        state.clearSelection()
        BEO.refreshBoard()
    }

    private func duplicateSelected() {
        guard let id = state.selectedToolId,
              let mv = BEO.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: id) else { return }
        BEO.realmInstance.safeWrite { r in
            let copy = ManagedView(value: mv)
            copy.id = UUID().uuidString
            copy.x = mv.x + 300
            copy.y = mv.y + 300
            copy.dateUpdated = Int(Date().timeIntervalSince1970)
            r.create(ManagedView.self, value: copy, update: .all)
        }
        BEO.refreshBoard()
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
