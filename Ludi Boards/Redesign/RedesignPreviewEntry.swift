//
//  RedesignPreviewEntry.swift
//  Ludi Boards — Canvas/Board redesign (imported handoff)
//
//  Isolated entry for the redesigned board. NOT the app's @main — the
//  shipping entry stays `LudiBoardsApp` → `CanvasEngine()`. Reached in the
//  running app via a DEBUG affordance in `CanvasEngine` (see TASK-002), and
//  used by the render harness. Holds the `BoardScreenState` and drives it
//  with a debug switcher that exercises the panel state machine
//  (none → Properties → Library). Removed at RD-6 cutover.
//
//  Source: docs/design/canvas-board-redesign/ (Claude Design SwiftUI handoff).
//

import SwiftUI
import CoreEngine

struct RedesignRootView: View {

    // Owns the scaffold state. The render harness can seed the initial
    // screen without a rebuild:
    //   SIMCTL_CHILD_REDESIGN_SCREEN=Selected xcrun simctl launch …
    @StateObject private var state: BoardScreenState = {
        switch ProcessInfo.processInfo.environment["REDESIGN_SCREEN"] {
        case "Selected": return BoardScreenState(demo: .selected)
        case "Library":  return BoardScreenState(demo: .library)
        default:         return BoardScreenState(demo: .board)
        }
    }()

    // The redesign board hosts the LIVE engine (TASK-013): one BEO, shared by
    // the canvas and the panels. Set `REDESIGN_ENGINE=0` to fall back to the
    // static mockup pitch (previews / pure-visual capture).
    @StateObject private var BEO = BoardEngineObject()
    private var engineConnected: Bool {
        ProcessInfo.processInfo.environment["REDESIGN_ENGINE"] != "0"
    }

    // Selection bridge: the engine stores the selected tool in this AppStorage
    // key (set by a tool tap). Reflect it into `BoardScreenState` so selecting a
    // tool opens Properties, and clearing in the UI clears engine selection.
    @AppStorage("selectedManagedViewId") private var engineSelectedId: String = ""

    var body: some View {
        TacticalBoardView(state: state, useEngineCanvas: engineConnected)
            .environmentObject(BEO)
            .overlay(alignment: .bottomTrailing) { stateSwitcher }
            .onAppear(perform: requestLandscapeOniPad)
            .onAppear(perform: configureRedesignBoard)
            // Initial sync: `selectedManagedViewId` persists across launches, so
            // reflect whatever the engine already holds — but VALIDATE it first
            // (TASK-021): a stale id from a prior launch / deleted tool / other
            // board must not ring a phantom selection.
            .onAppear {
                guard !engineSelectedId.isEmpty else { return }
                if let mv = BEO.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: engineSelectedId),
                   !mv.isDeleted, mv.boardId == BEO.currentActivityId {
                    state.select(engineSelectedId)
                } else {
                    engineSelectedId = ""   // drop the stale id
                }
            }
            // engine → state: a tapped tool opens Properties.
            .onChange(of: engineSelectedId) { _, newId in
                if newId.isEmpty { state.clearSelection() }
                else { state.select(newId) }
            }
            // state → engine: closing Properties (selection nil) clears engine
            // selection. Guarded so it never writes back on a select (no loop).
            .onChange(of: state.selectedToolId) { _, newId in
                if newId == nil, !engineSelectedId.isEmpty { engineSelectedId = "" }
            }
    }

    /// Point the live board at the redesign pitch. The override is applied by
    /// the engine AFTER its own `loadBoardSettings` (this parent `onAppear`
    /// fires before the child's load), so a direct `boardBgName` set would be
    /// overwritten — `boardBgOverride` wins.
    private func configureRedesignBoard() {
        guard engineConnected else { return }
        BEO.boardBgOverride = "Soccer Redesign Full View"
        #if DEBUG
        // Verify the rail reflects draw state headlessly (can't tap in simctl).
        switch ProcessInfo.processInfo.environment["REDESIGN_DRAW"] {
        case "straight": BEO.enableDrawing(subType: "line_straight")
        case "curved":   BEO.enableDrawing(subType: "line_curved")
        default:         break
        }
        if let z = ProcessInfo.processInfo.environment["REDESIGN_ZOOM"], let f = Double(z) {
            BEO.canvasScale = BoardEngineObject.defaultCanvasScale * f
        }
        if ProcessInfo.processInfo.environment["REDESIGN_LOCK"] == "1" {
            BEO.gesturesAreLocked = true
        }
        switch ProcessInfo.processInfo.environment["REDESIGN_MODE"] {
        case "present": state.mode = .present
        case "animate": state.mode = .animate
        default:        break
        }
        #endif
    }

    /// Bottom-right affordance. Production: a single Library toggle (the way to
    /// open the Add-to-board panel). DEBUG adds a Clear button for testing the
    /// panel state machine.
    private var stateSwitcher: some View {
        HStack(spacing: 8) {
            #if DEBUG
            Button("Clear") { state.clearSelection(); state.libraryOpen = false }
            #endif
            Button(state.libraryOpen ? "Done" : "Library") { state.toggleLibrary() }
        }
        .font(.system(size: 13, weight: .semibold))
        .buttonStyle(.bordered)
        .tint(Brand.lime)
        .padding(8)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(18)
    }

    /// Best-effort landscape on iPad (the design is landscape-first). No-ops
    /// on iPhone / if the scene declines. Full orientation lock is RD-6 polish.
    private func requestLandscapeOniPad() {
        #if os(iOS)
        guard UIDevice.current.userInterfaceIdiom == .pad,
              let scene = UIApplication.shared.connectedScenes
                  .first(where: { $0 is UIWindowScene }) as? UIWindowScene
        else { return }
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape)) { _ in }
        #endif
    }
}

#Preview("Redesign — state switcher", traits: .landscapeLeft) {
    RedesignRootView()
}
