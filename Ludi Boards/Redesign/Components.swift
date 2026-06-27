//
//  Components.swift
//  Ludi Boards
//
//  Reusable chrome: top bar, left tool rail, bottom control pill,
//  presence avatars and small building blocks. Icons use SF Symbols
//  (the redesign's custom line icons map cleanly onto these).
//

import SwiftUI
import CoreEngine

// MARK: - Presence avatar

struct PresenceAvatar: View {
    var initials: String
    var fill: LinearGradient
    var live: Bool = false
    var size: CGFloat = 30

    var body: some View {
        Text(initials)
            .font(AppFont.display(size * 0.37, .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(fill, in: Circle())
            .overlay(Circle().stroke(Brand.bgTop, lineWidth: 2))
            .overlay(alignment: .bottomTrailing) {
                if live {
                    Circle()
                        .fill(Brand.lime)
                        .frame(width: 9, height: 9)
                        .overlay(Circle().stroke(Brand.bgTop, lineWidth: 2))
                        .offset(x: 1, y: 1)
                }
            }
    }
}

// MARK: - Segmented mode switch (Plan / Animate / Present)

struct ModeSwitch: View {
    @Binding var mode: EditorMode

    var body: some View {
        HStack(spacing: 2) {
            ForEach(EditorMode.allCases) { m in
                Text(m.rawValue)
                    .font(AppFont.ui(13, .semibold))
                    .foregroundStyle(m == mode ? Brand.limeInk : Brand.textMuted)
                    .padding(.horizontal, 15).padding(.vertical, 6)
                    .background {
                        if m == mode {
                            RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Brand.lime)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { withAnimation(.snappy) { mode = m } }
            }
        }
        .padding(3)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).strokeBorder(Brand.hairline))
    }
}

// MARK: - Top bar

/// One board entry for the breadcrumb switcher (TASK-044).
struct BoardMenuItem: Identifiable, Equatable { let id: String; let label: String }

struct TopBar: View {
    @Binding var mode: EditorMode
    var title: String = "Activity 3 · Build-up"
    var squad: String = "U-12 Squad"
    /// Current user shown top-right (TASK-041). Empty = nothing to show.
    var userInitials: String = "CR"
    var userLive: Bool = true
    /// Board switcher data (TASK-044). Empty `boards` = plain, non-tappable title.
    var boards: [BoardMenuItem] = []
    var currentBoardId: String = ""
    var onSelectBoard: (String) -> Void = { _ in }
    var onCreateBoard: () -> Void = {}
    /// Text shared by the system sheet (TASK-046).
    var shareItem: String = "Ludi Board"

    var body: some View {
        HStack(spacing: 14) {
            // Brand + breadcrumb
            HStack(spacing: 14) {
                Image("AppIcon-Board")           // add to Assets; falls back to placeholder
                    .resizable().frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 9).strokeBorder(.white.opacity(0.1)))

                HStack(spacing: 8) {
                    Text(squad).foregroundStyle(Brand.textDim)
                    Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Brand.textFaint)
                    boardBreadcrumb
                }
                .font(AppFont.ui(14, .semibold))

                SportChip()
            }

            Spacer()
            ModeSwitch(mode: $mode)
            Spacer()

            // Presence + share
            HStack(spacing: 14) {
                if !userInitials.isEmpty {
                    PresenceAvatar(initials: userInitials, fill: .homeJersey, live: userLive)
                }
                // TASK-046: real system share of the board (text MVP; image export later).
                ShareLink(item: shareItem) { ShareButton() }
                    .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 58)
        .background(
            LinearGradient(colors: [Brand.bgTop.opacity(0.92), Brand.bgMid.opacity(0.82)],
                           startPoint: .top, endPoint: .bottom)
        )
        .overlay(alignment: .bottom) { Rectangle().fill(Brand.hairline).frame(height: 1) }
    }

    /// The board title — a dropdown when boards are supplied (TASK-044),
    /// otherwise plain text (preview / no-engine path).
    @ViewBuilder private var boardBreadcrumb: some View {
        if boards.isEmpty {
            Text(title).foregroundStyle(Brand.textMid)
        } else {
            Menu {
                ForEach(boards) { b in
                    Button {
                        onSelectBoard(b.id)
                    } label: {
                        if b.id == currentBoardId {
                            Label(b.label, systemImage: "checkmark")
                        } else {
                            Text(b.label)
                        }
                    }
                }
                Divider()
                Button { onCreateBoard() } label: { Label("New board", systemImage: "plus") }
            } label: {
                HStack(spacing: 5) {
                    Text(title).foregroundStyle(Brand.textMid)
                    Image(systemName: "chevron.down").font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Brand.textFaint)
                }
            }
        }
    }
}

/// Engine-wired top bar: breadcrumb dropdown from the live activities (TASK-044),
/// current-user presence + guest synthesis (TASK-041), real share (TASK-046).
struct EngineTopBar: View {
    @EnvironmentObject var BEO: BoardEngineObject
    @ObservedObject var state: BoardScreenState

    var body: some View {
        TopBar(mode: $state.mode,
               title: activityTitle,
               squad: "U-12 Squad",          // roster/team name lands in TASK-033
               userInitials: initials(from: BEO.currentUserName),
               userLive: BEO.isLoggedIn,
               boards: boardItems,
               currentBoardId: BEO.currentActivityId,
               onSelectBoard: { BEO.changeActivity(activityId: $0) },
               onCreateBoard: createBoard,
               shareItem: "Check out my board: \(activityTitle)")
            .onAppear(perform: ensureGuestIdentity)
    }

    private var activityTitle: String {
        if let plan = BEO.realmInstance.findByField(ActivityPlan.self, value: BEO.currentActivityId) {
            let parts = [plan.title, plan.subTitle].filter { !$0.isEmpty }
            if !parts.isEmpty { return parts.joined(separator: " · ") }
        }
        return "Untitled Activity"
    }

    /// All boards for the switcher (TASK-044), newest-stable order by orderIndex.
    private var boardItems: [BoardMenuItem] {
        BEO.realmInstance.objects(ActivityPlan.self)
            .sorted(byKeyPath: "orderIndex")
            .map { plan in
                let parts = [plan.title, plan.subTitle].filter { !$0.isEmpty }
                return BoardMenuItem(id: plan.id, label: parts.isEmpty ? "Untitled" : parts.joined(separator: " · "))
            }
    }

    /// Two-char initials from a name (matches the roster-editor logic, TASK-041).
    private func initials(from name: String) -> String {
        let chars = name.split(separator: " ").prefix(2).compactMap { $0.first }
        let s = String(chars).uppercased()
        return s.isEmpty ? "?" : s
    }

    /// Not-signed-up users still get a stable identity so the avatar shows a real
    /// name (TASK-041). Reuses the engine's existing guest generators.
    private func ensureGuestIdentity() {
        if BEO.currentUserId.isEmpty { BEO.currentUserId = generateRandomUserId() }
        if BEO.currentUserName.isEmpty { BEO.currentUserName = generateRandomName() }
    }

    /// Create a new board and switch to it (TASK-044).
    private func createBoard() {
        let count = BEO.realmInstance.objects(ActivityPlan.self).count
        let newId = UUID().uuidString
        BEO.realmInstance.safeWrite { r in
            let plan = ActivityPlan()
            plan.id = newId
            plan.title = "New Board"
            plan.subTitle = ""
            plan.orderIndex = count
            r.create(ActivityPlan.self, value: plan, update: .all)
        }
        BEO.changeActivity(activityId: newId)
    }
}

private struct SportChip: View {
    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "flag.fill").font(.system(size: 12))
            Text("Soccer · Full").font(AppFont.ui(12, .semibold))
            Image(systemName: "chevron.down").font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(Color(brandHex: "7FC4B3"))
        .padding(.horizontal, 11).padding(.vertical, 5)
        .background(Brand.teal.opacity(0.16), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 9).strokeBorder(Brand.teal.opacity(0.4)))
    }
}

struct ShareButton: View {
    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "point.3.connected.trianglepath.dotted").font(.system(size: 14, weight: .semibold))
            Text("Share").font(AppFont.ui(13, .bold))
        }
        .foregroundStyle(Brand.limeInk)
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(Brand.lime, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: Brand.lime.opacity(0.5), radius: 8, y: 6)
    }
}

// MARK: - Left tool rail

/// The rail's tools, typed so render / tap / active-state can't drift from a
/// positional index (TASK-025). Interaction modes only — add/colour tools live
/// in the Library / Squad / Properties panels, not the rail.
enum RailTool: String, CaseIterable, Identifiable {
    case select, drawStraight, drawCurved
    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .select:       return "cursorarrow"
        case .drawStraight: return "pencil.tip"
        case .drawCurved:   return "scribble.variable"
        }
    }
    /// Divider drawn after this tool (separates select from the draw tools).
    var dividerAfter: Bool { self == .select }
}

struct ToolRail: View {
    /// Active tool + tap handler. Pure visual — the engine wiring lives in
    /// `EngineToolRail` (TASK-006/025) so the BEO-less preview path renders.
    var active: RailTool = .select
    var onTap: (RailTool) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 5) {
            ForEach(RailTool.allCases) { tool in
                RailButton(symbol: tool.symbol, active: tool == active) { onTap(tool) }
                if tool.dividerAfter { Divider().overlay(Brand.hairline).frame(width: 28) }
            }
        }
        .padding(8)
        .glassPanel(fill: 0.78)
        .frame(width: 56)
    }
}

/// Engine-wired rail: derives the active tool from the board's draw state and
/// routes taps to engine actions (select, draw straight/curved).
struct EngineToolRail: View {
    @EnvironmentObject var BEO: BoardEngineObject

    private var active: RailTool {
        guard BEO.isDraw else { return .select }
        return BEO.shapeSubType == "line_curved" ? .drawCurved : .drawStraight
    }

    var body: some View {
        ToolRail(active: active, onTap: handleTap)
    }

    private func handleTap(_ tool: RailTool) {
        switch tool {
        case .select:       BEO.disableDrawing()
        case .drawStraight: BEO.toggleDrawingMode(subType: "line_straight")
        case .drawCurved:   BEO.toggleDrawingMode(subType: "line_curved")
        }
    }
}

private struct RailButton: View {
    var symbol: String
    var active: Bool
    var action: () -> Void
    @State private var hover = false

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(active ? Brand.limeInk : (hover ? Brand.text : Brand.textMuted))
                .frame(width: 40, height: 40)
                .background {
                    if active {
                        RoundedRectangle(cornerRadius: 11, style: .continuous).fill(Brand.lime)
                            .shadow(color: Brand.lime.opacity(0.5), radius: 7, y: 5)
                    } else if hover {
                        RoundedRectangle(cornerRadius: 11, style: .continuous).fill(.white.opacity(0.06))
                    }
                }
        }
        .buttonStyle(.plain)
        .onHover { hover = $0 }
    }
}

// MARK: - Bottom control pill

struct ControlPill: View {
    // Pure visual; the engine wiring lives in `EngineControlPill` (TASK-007).
    var zoom: Int = 100
    var locked: Bool = false
    var recording: Bool = false
    var onLock: () -> Void = {}
    var onUndo: () -> Void = {}
    var onRedo: () -> Void = {}
    var onZoomOut: () -> Void = {}
    var onZoomIn: () -> Void = {}
    var onScope: () -> Void = {}
    var onRotateLeft: () -> Void = {}
    var onRotateRight: () -> Void = {}
    var onRecord: () -> Void = {}

    var body: some View {
        HStack(spacing: 3) {
            PillIcon(locked ? "lock.fill" : "lock", tint: locked ? Brand.lime : nil, action: onLock)
            PillIcon("arrow.uturn.backward", action: onUndo)
            PillIcon("arrow.uturn.forward", action: onRedo)
            divider
            PillIcon("minus.magnifyingglass", action: onZoomOut)
            Text("\(zoom)%")
                .font(AppFont.mono(13))
                .foregroundStyle(Brand.textMid)
                .frame(minWidth: 46)
            PillIcon("plus.magnifyingglass", action: onZoomIn)
            PillIcon("scope", action: onScope)
            divider
            // TASK-042: rotate the canvas ±90° (wired to BEO.canvasRotation in EngineControlPill).
            PillIcon("rotate.left", action: onRotateLeft)
            PillIcon("rotate.right", action: onRotateRight)
            divider
            Button(action: onRecord) {
                HStack(spacing: 7) {
                    Image(systemName: recording ? "stop.fill" : "circle.fill").font(.system(size: 13))
                    Text(recording ? "Stop" : "Record").font(AppFont.ui(12, .semibold))
                }
                .foregroundStyle(Brand.danger)
                .padding(.leading, 9).padding(.trailing, 12)
                .frame(height: 34)
                .background(Brand.danger.opacity(recording ? 0.28 : 0.14), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 9).padding(.vertical, 7)
        .glassPanel(radius: 14, fill: 0.86)
    }

    private var divider: some View {
        Rectangle().fill(.white.opacity(0.1)).frame(width: 1, height: 22).padding(.horizontal, 5)
    }
}

/// Engine-wired control pill: zoom % from `canvasScale`, lock/undo/zoom/scope/
/// record routed to BEO.
struct EngineControlPill: View {
    @EnvironmentObject var BEO: BoardEngineObject

    var body: some View {
        ControlPill(
            zoom: Int((BEO.canvasScale / BoardEngineObject.defaultCanvasScale * 100).rounded()),
            locked: BEO.gesturesAreLocked,
            recording: BEO.isRecording,
            onLock:    { BEO.gesturesAreLocked.toggle() },
            onUndo:    { BEO.undoLastToolAction() },
            onRedo:    { BEO.undoLastToolAction() },   // no redo in engine yet; undo for now
            onZoomOut: { BEO.zoomOut() },
            onZoomIn:  { BEO.zoomIn() },
            onScope:   { BEO.resetZoom() },
            onRotateLeft:  { BEO.canvasRotation += -90.0 },   // TASK-042
            onRotateRight: { BEO.canvasRotation +=  90.0 },
            onRecord:  { BEO.isRecording ? BEO.stopRecording() : BEO.startRecording() }
        )
    }
}

private struct PillIcon: View {
    var symbol: String
    var tint: Color? = nil
    var action: () -> Void = {}
    init(_ s: String, tint: Color? = nil, action: @escaping () -> Void = {}) {
        symbol = s; self.tint = tint; self.action = action
    }
    @State private var hover = false
    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(tint ?? (hover ? Brand.text : Brand.textMuted))
                .frame(width: 34, height: 34)
                .background {
                    if hover { RoundedRectangle(cornerRadius: 9, style: .continuous).fill(.white.opacity(0.06)) }
                }
        }
        .buttonStyle(.plain)
        .onHover { hover = $0 }
    }
}

// MARK: - Small shared bits

/// Uppercase section label used across panels.
struct SectionLabel: View {
    var text: String
    var body: some View {
        Text(text)
            .font(AppFont.ui(11, .semibold))
            .tracking(1.6)
            .foregroundStyle(Brand.textFaint)
    }
}
