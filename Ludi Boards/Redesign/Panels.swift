//
//  Panels.swift
//  Ludi Boards
//
//  The three right-hand side panels: Squad roster, Properties (node
//  selected), and the Add-to-board Library.
//

import SwiftUI
import CoreEngine
import RealmSwift

// MARK: - Shared panel shell

private struct PanelShell<Header: View, Content: View, Footer: View>: View {
    var width: CGFloat = 268
    @ViewBuilder var header: Header
    @ViewBuilder var content: Content
    @ViewBuilder var footer: Footer

    var body: some View {
        VStack(spacing: 0) {
            header.padding(.horizontal, 18).padding(.top, 16).padding(.bottom, 12)
            Rectangle().fill(Brand.hairline).frame(height: 1)
            // TASK-039: extra bottom inset so the last scrolled row clears the
            // panel edge and the floating bottom-right buttons.
            ScrollView { content.padding(16).padding(.bottom, 52) }
            footer
        }
        .frame(width: width)
        .frame(maxHeight: .infinity)   // TASK-039: fill the drawer's reserved height so tall panels (Add-to-board) aren't clipped
        .glassPanel()
    }
}

// MARK: - 1. Squad panel

struct SquadPanel: View {
    var body: some View {
        PanelShell {
            HStack {
                Text("Squad").font(AppFont.display(15, .bold)).foregroundStyle(Brand.textHi)
                Spacer()
                Image(systemName: "arrow.up.arrow.down").font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Brand.textMuted)
            }
        } content: {
            VStack(alignment: .leading, spacing: 0) {
                RosterHeader(swatch: .homeJersey, title: "HOME", count: 11)
                    .padding(.bottom, 11)
                VStack(spacing: 3) {
                    RosterRow(player: Sample.homeRoster[0], highlighted: true)
                    ForEach(Sample.homeRoster.dropFirst()) { RosterRow(player: $0) }
                }
                RosterHeader(swatch: nil, title: "AWAY", count: 5)
                    .padding(.top, 18).padding(.bottom, 11)
                VStack(spacing: 3) {
                    ForEach(Sample.awayRoster) { RosterRow(player: $0) }
                }
            }
        } footer: {
            PanelFooter {
                FooterButton(symbol: "plus", label: "Add player")
            }
        }
    }
}

/// Engine-wired Squad panel: reads the board roster and places a player on the
/// board (linked jersey tool) on tap.
struct EngineSquadPanel: View {
    @EnvironmentObject var BEO: BoardEngineObject
    @ObservedObject var state: BoardScreenState

    // Live roster (TASK-028): observing `RosterPlayer` means add/edit/delete
    // redraw the panel automatically — no `refreshBoard()` needed for roster
    // changes, which is the bug class the audit's CRITICAL finding described.
    // Filtered by board/side in `body` (not via the `where:` initialiser)
    // because `currentActivityId` is a runtime value, not known at init.
    @ObservedResults(RosterPlayer.self) private var allRosterPlayers
    @State private var editTarget: RosterEditTarget?

    private func roster(_ side: String) -> [RosterPlayer] {
        allRosterPlayers
            .filter { $0.boardId == BEO.currentActivityId && $0.teamSide == side }
            .sorted { $0.orderIndex < $1.orderIndex }
    }
    private func squad(_ p: RosterPlayer) -> SquadPlayer {
        let kind: TeamKind = p.position == "GK" ? .goalkeeper : (p.teamSide == "away" ? .away : .home)
        return SquadPlayer(number: p.number, name: p.name, position: p.position, kind: kind)
    }

    var body: some View {
        let home = roster("home"), away = roster("away")
        PanelShell {
            HStack {
                Text("Squad").font(AppFont.display(15, .bold)).foregroundStyle(Brand.textHi)
                Spacer()
                Image(systemName: "arrow.up.arrow.down").font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Brand.textMuted)
            }
        } content: {
            VStack(alignment: .leading, spacing: 0) {
                // Formation labels are dropped (TASK-032) — they were hardcoded
                // "4-3-3"/"4-4-2" regardless of the real squad. The "+" adds a
                // player to that side (TASK-029 / TASK-030).
                RosterHeader(swatch: .homeJersey, title: "HOME", count: home.count,
                             onAdd: { addPlayer(side: "home") }).padding(.bottom, 11)
                rosterSection(home, emptyText: "No home players yet — tap +")
                RosterHeader(swatch: nil, title: "AWAY", count: away.count,
                             onAdd: { addPlayer(side: "away") })
                    .padding(.top, 18).padding(.bottom, 11)
                rosterSection(away, emptyText: "No away players yet — tap +")
            }
        } footer: {
            PanelFooter {
                Button(action: { addPlayer(side: "home") }) { FooterButton(symbol: "plus", label: "Add player") }
                    .buttonStyle(.plain)
            }
        }
        .sheet(item: $editTarget) { t in
            RosterPlayerEditor(playerId: t.id).environmentObject(BEO)
        }
    }

    // Per-side rows, or a muted empty state (TASK-030) instead of a bare
    // count-0 header. Row tap toggles placement; the pencil opens the editor.
    @ViewBuilder private func rosterSection(_ players: [RosterPlayer], emptyText: String) -> some View {
        if players.isEmpty {
            Text(emptyText)
                .font(AppFont.ui(12, .medium)).foregroundStyle(Brand.textMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)
        } else {
            VStack(spacing: 3) {
                ForEach(players) { p in
                    RosterRow(player: squad(p), placed: isPlaced(p),
                              onEdit: { editTarget = RosterEditTarget(id: p.id) })
                        .contentShape(Rectangle())
                        .onTapGesture { place(p) }
                }
            }
        }
    }

    // Create a roster player on the given side (TASK-029): per-side add so AWAY
    // can be populated too, not just HOME. `orderIndex = max+1` so a mid-list
    // delete can't collide on the next insert.
    private func addPlayer(side: String) {
        let sideRoster = roster(side)
        let nextNumber = (sideRoster.map(\.number).max() ?? 0) + 1
        let nextOrder = (sideRoster.map(\.orderIndex).max() ?? -1) + 1
        BEO.realmInstance.safeWrite { r in
            let p = RosterPlayer()
            p.boardId = BEO.currentActivityId
            p.teamSide = side
            p.number = nextNumber
            p.name = "Player \(nextNumber)"
            p.position = "—"
            p.orderIndex = nextOrder
            r.create(RosterPlayer.self, value: p, update: .all)
        }
        // No refreshBoard(): the @ObservedResults roster redraws on the write.
    }

    // A placed player = a non-deleted jersey disc on THIS board linked by id.
    private func placedDisc(_ p: RosterPlayer) -> ManagedView? {
        BEO.realmInstance.objects(ManagedView.self)
            .filter("boardId == %@ AND playerId == %@ AND isDeleted == false", BEO.currentActivityId, p.id)
            .first
    }
    private func isPlaced(_ p: RosterPlayer) -> Bool { placedDisc(p) != nil }

    // Tap a row to toggle the player on/off the board (TASK-031): if a disc
    // already exists, soft-delete it; otherwise spawn a linked jersey — no more
    // unbounded duplicate discs for one player. `refreshBoard()` stays: the
    // canvas and the row's placed indicator observe BEO, not RosterPlayer.
    private func place(_ p: RosterPlayer) {
        if let existing = placedDisc(p) {
            BEO.realmInstance.safeWrite { _ in existing.isDeleted = true }
            BEO.refreshBoard()
            return
        }
        BEO.realmInstance.safeWrite { r in
            let mv = ManagedView()
            mv.boardId = BEO.currentActivityId
            mv.sport = "tool"; mv.toolType = "soccer"; mv.subToolType = "tools_soccer_jersey"
            mv.x = 2200 + Double((p.number * 137) % 700)
            mv.y = 2600 + Double((p.number * 71) % 700)
            mv.width = 200; mv.height = 200
            mv.jerseyNumber = p.number; mv.teamSide = p.teamSide; mv.playerId = p.id
            mv.dateUpdated = Int(Date().timeIntervalSince1970)
            r.create(ManagedView.self, value: mv, update: .all)
        }
        BEO.refreshBoard()
    }
}

/// Sheet target for the roster editor (`String` id wrapped to be Identifiable).
private struct RosterEditTarget: Identifiable { let id: String }

/// Lightweight roster-player editor (TASK-029): edit name / number / position
/// or delete. Takes the player **id** and re-fetches inside the write — never
/// mutates a managed object across the sheet boundary. Editing the number
/// cascades to placed discs' denormalised `jerseyNumber` so the board can't go
/// stale (closes the write-back gap TASK-019 left latent). Side-switching is
/// out of scope for this batch.
private struct RosterPlayerEditor: View {
    @EnvironmentObject var BEO: BoardEngineObject
    @Environment(\.dismiss) private var dismiss
    let playerId: String

    @State private var name = ""
    @State private var numberText = ""
    @State private var position = ""
    @State private var loaded = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Player") {
                    TextField("Name", text: $name)
                    TextField("Number", text: $numberText)
                        .keyboardType(.numberPad)
                    TextField("Position", text: $position)
                }
                Section {
                    Button(role: .destructive, action: deletePlayer) {
                        Label("Delete player", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Edit Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save", action: save) }
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard !loaded,
              let p = BEO.realmInstance.object(ofType: RosterPlayer.self, forPrimaryKey: playerId) else { return }
        name = p.name; numberText = "\(p.number)"; position = p.position
        loaded = true
    }

    private func save() {
        let newNumber = Int(numberText)
        BEO.realmInstance.safeWrite { r in
            guard let p = r.object(ofType: RosterPlayer.self, forPrimaryKey: playerId) else { return }
            p.name = name
            if let n = newNumber { p.number = n }
            p.position = position
            // Keep placed discs in sync with the edited number (TASK-029).
            if let n = newNumber {
                let discs = r.objects(ManagedView.self)
                    .filter("playerId == %@ AND isDeleted == false", playerId)
                for d in discs { d.jerseyNumber = n }
            }
        }
        BEO.refreshBoard()   // placed discs re-render with the new number
        dismiss()
    }

    private func deletePlayer() {
        BEO.realmInstance.safeWrite { r in
            // Soft-delete the player's placed discs (matches the canvas's
            // isDeleted convention), then hard-delete the roster entry —
            // RosterPlayer has no isDeleted field of its own.
            let discs = r.objects(ManagedView.self).filter("playerId == %@", playerId)
            for d in discs { d.isDeleted = true }
            if let p = r.object(ofType: RosterPlayer.self, forPrimaryKey: playerId) { r.delete(p) }
        }
        BEO.refreshBoard()
        dismiss()
    }
}

private struct RosterHeader: View {
    var swatch: LinearGradient?
    var title: String
    var count: Int
    var onAdd: (() -> Void)? = nil
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 3)
                .fill(swatch ?? LinearGradient(colors: [Color(brandHex: "ECEFF1")], startPoint: .top, endPoint: .bottom))
                .frame(width: 9, height: 9)
            Text(title).font(AppFont.ui(12, .semibold)).tracking(0.5).foregroundStyle(Brand.textMuted)
            Spacer()
            Text("\(count)").font(AppFont.mono(11)).foregroundStyle(Brand.textFaint)
            if let onAdd {
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Brand.textMuted)
                        .frame(width: 20, height: 20)
                        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct RosterRow: View {
    var player: SquadPlayer
    var highlighted: Bool = false
    var placed: Bool = false                 // a disc for this player is on the board (TASK-031)
    var onEdit: (() -> Void)? = nil          // pencil → open the roster editor (TASK-029)
    var body: some View {
        HStack(spacing: 11) {
            Text("\(player.number)")
                .font(AppFont.display(12, .bold)).foregroundStyle(player.kind.ink)
                .frame(width: 26, height: 26)
                .background(player.kind.fill, in: Circle())
                .overlay(Circle().strokeBorder(player.kind.ring, lineWidth: 1.5))
            Text(player.name)
                .font(AppFont.ui(13, .semibold))
                .foregroundStyle(highlighted ? Color(brandHex: "E6EBE9") : Brand.textMid)
            Spacer()
            if placed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Brand.lime)
            }
            Text(player.position).font(AppFont.ui(11, .medium)).foregroundStyle(Brand.textDim)
            if let onEdit {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Brand.textMuted)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 9).padding(.vertical, 8)
        .background {
            if highlighted {
                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Brand.lime.opacity(0.08))
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Brand.lime.opacity(0.16)))
            }
        }
    }
}

// MARK: - 1b. Layers panel (every tool on the board — TASK-047)

/// Photoshop-style layer list of every tool on the current board. Tapping a row
/// selects that tool and opens Properties (which carries a back button here).
struct EngineLayersPanel: View {
    @EnvironmentObject var BEO: BoardEngineObject
    @ObservedObject var state: BoardScreenState
    @ObservedResults(ManagedView.self) private var allManagedViews

    private var tools: [ManagedView] {
        allManagedViews
            .filter { $0.boardId == BEO.currentActivityId && !$0.isDeleted }
            .sorted { $0.dateUpdated > $1.dateUpdated }   // most-recent first (no creation ts on the model)
    }

    var body: some View {
        let tools = self.tools
        PanelShell {
            HStack {
                Text("Layers").font(AppFont.display(15, .bold)).foregroundStyle(Brand.textHi)
                Spacer()
                Text("\(tools.count)").font(AppFont.mono(11)).foregroundStyle(Brand.textFaint)
                Button(action: state.closeLayers) {
                    Image(systemName: "xmark").font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Brand.textMuted)
                        .frame(width: 26, height: 26)
                        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                }.buttonStyle(.plain)
            }
        } content: {
            VStack(spacing: 3) {
                if tools.isEmpty {
                    Text("No tools on this board yet — add one from the Library.")
                        .font(AppFont.ui(12, .medium)).foregroundStyle(Brand.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 6)
                } else {
                    ForEach(tools) { mv in
                        LayerRow(icon: icon(mv), label: label(mv), type: badge(mv),
                                 selected: state.selectedToolId == mv.id)
                            .contentShape(Rectangle())
                            .onTapGesture { state.select(mv.id) }
                    }
                }
            }
        } footer: { EmptyView() }
    }

    private func icon(_ mv: ManagedView) -> String {
        switch mv.toolType {
        case "soccer":  return mv.subToolType.contains("jersey") ? "tshirt.fill" : "circle.grid.cross.fill"
        case "shape":   return "line.diagonal"
        case "tactic":  return "scope"
        default:        return "square.on.square"
        }
    }
    private func label(_ mv: ManagedView) -> String {
        if !mv.playerId.isEmpty,
           let p = BEO.realmInstance.object(ofType: RosterPlayer.self, forPrimaryKey: mv.playerId) {
            return p.name.isEmpty ? "Player \(p.number)" : p.name
        }
        if mv.jerseyNumber > 0 { return "Player \(mv.jerseyNumber)" }
        return prettifySubType(mv.subToolType)
    }
    private func badge(_ mv: ManagedView) -> String { mv.toolType.capitalized }

    private func prettifySubType(_ s: String) -> String {
        var t = s
        for p in ["tools_soccer_", "tactic_", "line_", "tools_"] where t.hasPrefix(p) { t = String(t.dropFirst(p.count)) }
        t = t.replacingOccurrences(of: "_", with: " ")
        return t.isEmpty ? "Tool" : t.capitalized
    }
}

private struct LayerRow: View {
    var icon: String
    var label: String
    var type: String
    var selected: Bool
    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: icon).font(.system(size: 14, weight: .medium))
                .foregroundStyle(selected ? Brand.lime : Brand.textMuted)
                .frame(width: 26, height: 26)
                .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            Text(label).font(AppFont.ui(13, .semibold)).foregroundStyle(selected ? Color(brandHex: "E6EBE9") : Brand.textMid)
                .lineLimit(1)
            Spacer()
            Text(type).font(AppFont.ui(10, .medium)).tracking(0.4).foregroundStyle(Brand.textDim)
        }
        .padding(.horizontal, 9).padding(.vertical, 8)
        .background {
            if selected {
                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Brand.lime.opacity(0.08))
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Brand.lime.opacity(0.16)))
            }
        }
    }
}

// MARK: - 1c. Animate panel (recordings list — TASK-052)

/// Recordings list shown in Animate mode. Lists the board's `Recording`s; tap
/// to select one for playback (the transport pill plays `playbackRecordingId`).
struct EngineAnimatePanel: View {
    @EnvironmentObject var BEO: BoardEngineObject
    @ObservedObject var state: BoardScreenState
    @ObservedResults(Recording.self) private var allRecordings

    private var recordings: [Recording] {
        allRecordings
            .filter { $0.boardId == BEO.currentActivityId }
            .sorted { $0.dateCreated > $1.dateCreated }
    }
    private func actionCount(_ rec: Recording) -> Int {
        BEO.realmInstance.objects(RecordingAction.self).filter("recordingId == %@", rec.id).count
    }

    var body: some View {
        let recs = recordings
        PanelShell {
            HStack {
                Text("Recordings").font(AppFont.display(15, .bold)).foregroundStyle(Brand.textHi)
                Spacer()
                Text("\(recs.count)").font(AppFont.mono(11)).foregroundStyle(Brand.textFaint)
            }
        } content: {
            VStack(spacing: 3) {
                if recs.isEmpty {
                    Text("No recordings yet — tap Record below, move your tools, then Stop.")
                        .font(AppFont.ui(12, .medium)).foregroundStyle(Brand.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 6)
                } else {
                    ForEach(recs) { rec in
                        RecordingRow(name: rec.name,
                                     meta: "\(actionCount(rec)) actions · \(String(format: "%.1fs", rec.duration))",
                                     selected: BEO.playbackRecordingId == rec.id,
                                     playing: BEO.playbackRecordingId == rec.id && BEO.isPlayingAnimation)
                            .contentShape(Rectangle())
                            .onTapGesture { if !BEO.isPlayingAnimation && !BEO.isRecording { BEO.selectRecordingForPlayback(rec.id) } }
                    }
                }
            }
        } footer: { EmptyView() }
    }
}

private struct RecordingRow: View {
    var name: String
    var meta: String
    var selected: Bool
    var playing: Bool
    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: playing ? "waveform" : "film")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(selected ? Brand.lime : Brand.textMuted)
                .frame(width: 26, height: 26)
                .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            VStack(alignment: .leading, spacing: 1) {
                Text(name).font(AppFont.ui(13, .semibold)).lineLimit(1)
                    .foregroundStyle(selected ? Color(brandHex: "E6EBE9") : Brand.textMid)
                Text(meta).font(AppFont.ui(11, .medium)).foregroundStyle(Brand.textDim)
            }
            Spacer()
            if selected {
                Image(systemName: "checkmark.circle.fill").font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Brand.lime)
            }
        }
        .padding(.horizontal, 9).padding(.vertical, 8)
        .background {
            if selected {
                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Brand.lime.opacity(0.08))
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Brand.lime.opacity(0.16)))
            }
        }
    }
}

// MARK: - 1d. Boards panel (board switcher in a drawer — req 4)

/// Lists the activity boards; tap to load, or create a new one. Mirrors the
/// top-bar dropdown's data, surfaced as a dedicated drawer.
struct EngineBoardsPanel: View {
    @EnvironmentObject var BEO: BoardEngineObject
    @ObservedObject var state: BoardScreenState
    @ObservedResults(ActivityPlan.self) private var allPlans
    @State private var sport = 0
    @State private var selectedField = "Soccer Redesign Full View"

    private var boards: [ActivityPlan] { allPlans.sorted { $0.orderIndex < $1.orderIndex } }
    private func label(_ p: ActivityPlan) -> String {
        let parts = [p.title, p.subTitle].filter { !$0.isEmpty }
        return parts.isEmpty ? "Untitled" : parts.joined(separator: " · ")
    }

    var body: some View {
        let boards = self.boards
        PanelShell(width: 288) {
            HStack {
                Text("Boards").font(AppFont.display(15, .bold)).foregroundStyle(Brand.textHi)
                Spacer()
                Text("\(boards.count)").font(AppFont.mono(11)).foregroundStyle(Brand.textFaint)
            }
        } content: {
            VStack(alignment: .leading, spacing: 18) {
                // SPORT + FIELD picker (moved out of the Tools drawer per request).
                VStack(alignment: .leading, spacing: 11) {
                    SectionLabel(text: "SPORT")
                    FlowChips(items: Sample.sports.indices.map { $0 }, selected: sport) { i in
                        SportPill(sport: Sample.sports[i], selected: i == sport).onTapGesture { sport = i }
                    }
                }
                let sportName = Sample.sports[sport].name
                let sportFields = Sample.boards.filter { $0.sport == sportName }
                VStack(alignment: .leading, spacing: 11) {
                    SectionLabel(text: "FIELD")
                    if sportFields.isEmpty {
                        Text("No fields for \(sportName) yet.")
                            .font(AppFont.ui(12, .medium)).foregroundStyle(Brand.textMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible())], spacing: 10) {
                            ForEach(sportFields) { b in
                                BoardThumb(preset: b, selected: b.registryName == selectedField)
                                    .onTapGesture { selectedField = b.registryName; pickField(b.registryName) }
                            }
                        }
                    }
                }
                // The activity boards (switch / create).
                VStack(alignment: .leading, spacing: 8) {
                    SectionLabel(text: "MY BOARDS")
                    if boards.isEmpty {
                        Text("No boards yet — tap New board.")
                            .font(AppFont.ui(12, .medium)).foregroundStyle(Brand.textMuted)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 6)
                    } else {
                        VStack(spacing: 3) {
                            ForEach(boards) { plan in
                                BoardRow(title: label(plan), current: plan.id == BEO.currentActivityId)
                                    .contentShape(Rectangle())
                                    .onTapGesture { BEO.changeActivity(activityId: plan.id) }
                            }
                        }
                    }
                }
            }
        } footer: {
            PanelFooter {
                Button(action: createBoard) { FooterButton(symbol: "plus", label: "New board") }
                    .buttonStyle(.plain)
            }
        }
    }

    private func pickField(_ name: String) {
        BEO.boardBgOverride = name
        BEO.boardBgName = name
    }

    private func createBoard() {
        let count = BEO.realmInstance.objects(ActivityPlan.self).count
        let newId = UUID().uuidString
        BEO.realmInstance.safeWrite { r in
            let plan = ActivityPlan()
            plan.id = newId; plan.title = "New Board"; plan.subTitle = ""; plan.orderIndex = count
            r.create(ActivityPlan.self, value: plan, update: .all)
        }
        BEO.changeActivity(activityId: newId)
    }
}

private struct BoardRow: View {
    var title: String
    var current: Bool
    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: "square.grid.2x2").font(.system(size: 14, weight: .medium))
                .foregroundStyle(current ? Brand.lime : Brand.textMuted)
                .frame(width: 26, height: 26)
                .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            Text(title).font(AppFont.ui(13, .semibold)).lineLimit(1)
                .foregroundStyle(current ? Color(brandHex: "E6EBE9") : Brand.textMid)
            Spacer()
            if current {
                Image(systemName: "checkmark.circle.fill").font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Brand.lime)
            }
        }
        .padding(.horizontal, 9).padding(.vertical, 8)
        .background {
            if current {
                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Brand.lime.opacity(0.08))
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Brand.lime.opacity(0.16)))
            }
        }
    }
}

// MARK: - 2. Properties panel (node selected)

struct PropertiesPanel: View {
    // Identity + readouts (engine values flow in via `EnginePropertiesPanel`).
    var number: String = "9"
    var name: String = "Marcus Reed"
    var subtitle: String = "#9 · Striker · Home"
    var sizeReadout: String = "34 px"
    var rotationReadout: String = "0°"
    var sizeLabel: String = "SIZE"
    var showRotation: Bool = true     // hidden for tools that ignore rotation (TASK-016)
    var teamColor: Int = 0
    var showLinkedPlayer: Bool = true
    var onPickColor: (Int) -> Void = { _ in }
    var onDuplicate: () -> Void = {}
    var onDelete: () -> Void = {}
    var onClose: () -> Void = {}
    var onBack: (() -> Void)? = nil       // TASK-047: return to the layer list
    var onEditPlayer: (() -> Void)? = nil // req 2: edit the player's number + name

    @Binding var size: Double
    @Binding var rotation: Double

    // Static / preview convenience (self-managed sliders).
    init() { _size = .constant(0.52); _rotation = .constant(0.5) }
    init(number: String, name: String, subtitle: String, sizeReadout: String,
         rotationReadout: String, sizeLabel: String = "SIZE", showRotation: Bool = true,
         teamColor: Int, showLinkedPlayer: Bool,
         size: Binding<Double>, rotation: Binding<Double>,
         onPickColor: @escaping (Int) -> Void, onDuplicate: @escaping () -> Void,
         onDelete: @escaping () -> Void, onClose: @escaping () -> Void,
         onBack: (() -> Void)? = nil, onEditPlayer: (() -> Void)? = nil) {
        self.number = number; self.name = name; self.subtitle = subtitle
        self.sizeReadout = sizeReadout; self.rotationReadout = rotationReadout
        self.sizeLabel = sizeLabel; self.showRotation = showRotation
        self.teamColor = teamColor; self.showLinkedPlayer = showLinkedPlayer
        self.onPickColor = onPickColor; self.onDuplicate = onDuplicate
        self.onDelete = onDelete; self.onClose = onClose; self.onBack = onBack
        self.onEditPlayer = onEditPlayer
        _size = size; _rotation = rotation
    }

    private var initials: String {
        let chars = name.split(separator: " ").prefix(2).compactMap { $0.first }
        return String(chars).uppercased()
    }

    private let swatches: [LinearGradient] = [
        .homeJersey,
        LinearGradient(colors: [Color(brandHex: "ECEFF1")], startPoint: .top, endPoint: .bottom),
        LinearGradient(colors: [Color(brandHex: "2C3648")], startPoint: .top, endPoint: .bottom),
        LinearGradient(colors: [Brand.lime], startPoint: .top, endPoint: .bottom),
        LinearGradient(colors: [Brand.danger], startPoint: .top, endPoint: .bottom),
    ]

    var body: some View {
        PanelShell {
            HStack {
                if let onBack {     // TASK-047: back to the layer list
                    Button(action: onBack) {
                        Image(systemName: "chevron.left").font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Brand.textMuted)
                            .frame(width: 26, height: 26)
                            .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                    }.buttonStyle(.plain)
                }
                Text("Properties").font(AppFont.display(15, .bold)).foregroundStyle(Brand.textHi)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark").font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Brand.textMuted)
                        .frame(width: 26, height: 26)
                        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                }.buttonStyle(.plain)
            }
        } content: {
            VStack(alignment: .leading, spacing: 18) {
                // Identity
                HStack(spacing: 13) {
                    Text(number).font(AppFont.display(19, .bold)).foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(.homeJersey, in: Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.3), lineWidth: 1.5))
                        .overlay(Circle().stroke(Brand.lime, lineWidth: 2).padding(-2))
                        .overlay(Circle().stroke(Brand.lime.opacity(0.18), lineWidth: 3).padding(-5))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name).font(AppFont.ui(16, .bold)).foregroundStyle(Brand.textHi)
                        Text(subtitle).font(AppFont.ui(12, .medium)).foregroundStyle(Brand.textMuted)
                    }
                }

                // Team colour swatches
                VStack(alignment: .leading, spacing: 10) {
                    SectionLabel(text: "TEAM COLOUR")
                    HStack(spacing: 11) {
                        ForEach(Array(swatches.enumerated()), id: \.offset) { i, g in
                            ColourSwatch(g, selected: teamColor == i).onTapGesture { onPickColor(i) }
                        }
                    }
                }

                SliderRow(label: sizeLabel, value: $size, readout: sizeReadout)
                if showRotation {
                    SliderRow(label: "ROTATION", value: $rotation, readout: rotationReadout, centered: true)
                }

                // Linked player (real roster lands in RD-5)
                if showLinkedPlayer {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(text: "LINKED PLAYER")
                        HStack(spacing: 11) {
                            Text(initials).font(AppFont.display(13, .bold)).foregroundStyle(.white)
                                .frame(width: 34, height: 34).background(.homeJersey, in: Circle())
                            VStack(alignment: .leading, spacing: 1) {
                                Text(name).font(AppFont.ui(13, .semibold)).foregroundStyle(Color(brandHex: "E6EBE9"))
                                Text("Tap to edit number / name").font(AppFont.ui(11, .medium)).foregroundStyle(Color(brandHex: "7FC4B3"))
                            }
                            Spacer()
                            Image(systemName: "pencil").font(.system(size: 13, weight: .semibold)).foregroundStyle(Brand.textFaint)
                        }
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Brand.panelLine))
                        .contentShape(Rectangle())
                        .onTapGesture { onEditPlayer?() }   // req 2
                    }
                }
            }
        } footer: {
            PanelFooter {
                HStack(spacing: 9) {
                    Button(action: onDuplicate) { FooterButton(symbol: "square.on.square", label: "Duplicate") }.buttonStyle(.plain)
                    Button(action: onDelete) { FooterButton(symbol: "trash", label: "Delete", destructive: true) }.buttonStyle(.plain)
                }
            }
        }
    }
}

/// Engine-wired Properties panel: reads/writes the selected `ManagedView`.
/// Size + rotation update live (the tool's MVObject observes Realm); colour is
/// written + a board refresh re-renders the disc. Identity name / linked-player
/// need the roster model (RD-5).
struct EnginePropertiesPanel: View {
    @EnvironmentObject var BEO: BoardEngineObject
    @ObservedObject var state: BoardScreenState

    @State private var size: Double = 0.5
    @State private var rotation: Double = 0.0
    @State private var teamColor: Int = 0
    @State private var number: String = "0"
    @State private var name: String = "Player"
    @State private var subtitle: String = "Soccer"
    @State private var linked: Bool = false
    @State private var isLine: Bool = false   // line/smart family: width = stroke, no rotation
    @State private var isPlayer: Bool = false // req 2: jersey/disc → show editable player section
    @State private var editTarget: RosterEditTarget?

    // Engine selection key — the on-canvas lime ring renders while this equals a
    // tool id (ManagedToolView). Closing Properties must clear it directly so the
    // ring drops in the same frame as the panel, not via an async bridge (TASK-038).
    @AppStorage("selectedManagedViewId") private var engineSelectedId: String = ""

    // Token = soccer disc / equipment (size 80–500); line/smart = stroke 10–140.
    private var minW: Double { isLine ? 10 : 80 }
    private var maxW: Double { isLine ? 140 : 500 }
    private static let colorNames = ["Teal", "Silver", "Black", "Lime", "Red"]
    // RGB (0–1) for each swatch so line/smart tools (which render from RGBA) update.
    private static let colorRGB: [(Double, Double, Double)] = [
        (0.243, 0.443, 0.404), // Teal  #3E7167
        (0.925, 0.937, 0.945), // Silver #ECEFF1
        (0.173, 0.212, 0.282), // Black  #2C3648
        (0.796, 0.859, 0.165), // Lime   #CBDB2A
        (0.941, 0.447, 0.420), // Red    #F0726B
    ]

    var body: some View {
        PropertiesPanel(
            number: number,
            name: name,
            subtitle: subtitle,
            sizeReadout: "\(Int(currentWidth)) px",
            rotationReadout: "\(Int((rotation * 360).rounded()))°",
            sizeLabel: isLine ? "STROKE" : "SIZE",
            showRotation: !isLine,
            teamColor: teamColor,
            showLinkedPlayer: isPlayer,              // req 2: jersey tools show the editable player section
            size: Binding(get: { size }, set: { size = $0; writeSize($0) }),
            rotation: Binding(get: { rotation }, set: { rotation = $0; writeRotation($0) }),
            onPickColor: pickColor,
            onDuplicate: duplicate,
            onDelete: delete,
            onClose: { engineSelectedId = ""; state.clearSelection() },   // TASK-038: clear ring + panel together
            onBack: { engineSelectedId = ""; state.openLayers() },        // TASK-047: back to the layer list
            onEditPlayer: editPlayer                                      // req 2
        )
        .onAppear(perform: loadFromTool)
        .onChange(of: state.selectedToolId) { _, _ in loadFromTool() }
        .sheet(item: $editTarget, onDismiss: loadFromTool) { t in
            RosterPlayerEditor(playerId: t.id).environmentObject(BEO)
        }
    }

    /// req 2: edit the selected player tool's number + name. Ensures the disc is
    /// linked to a RosterPlayer (creating one if needed), then opens the editor;
    /// number edits cascade back to the disc (RosterPlayerEditor handles that).
    private func editPlayer() {
        guard let mv = tool() else { return }
        var playerId = mv.playerId
        if playerId.isEmpty {
            let newId = UUID().uuidString
            let n = Int(number) ?? mv.jerseyNumber
            BEO.realmInstance.safeWrite { r in
                let p = RosterPlayer()
                p.id = newId
                p.boardId = BEO.currentActivityId
                p.teamSide = mv.teamSide.isEmpty ? "home" : mv.teamSide
                p.number = n
                p.name = "Player \(n)"
                p.position = "—"
                p.orderIndex = BEO.realmInstance.objects(RosterPlayer.self)
                    .filter("boardId == %@", BEO.currentActivityId).count
                r.create(RosterPlayer.self, value: p, update: .all)
                if let live = r.object(ofType: ManagedView.self, forPrimaryKey: mv.id) {
                    live.playerId = newId
                    if live.jerseyNumber <= 0 { live.jerseyNumber = n }
                }
            }
            playerId = newId
        }
        editTarget = RosterEditTarget(id: playerId)
    }

    private var currentWidth: Double { minW + size * (maxW - minW) }

    private func tool() -> ManagedView? {
        guard let id = state.selectedToolId else { return nil }
        return BEO.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: id)
    }

    private func loadFromTool() {
        guard let mv = tool() else { return }
        isLine = (mv.toolType == "shape" || mv.toolType == "tactic")
        // req 2: a jersey/disc player tool — show the editable player section.
        isPlayer = mv.toolType == "soccer" &&
            (mv.subToolType.contains("jersey") || mv.jerseyNumber > 0 || !mv.playerId.isEmpty)
        size = max(0, min(1, (Double(mv.width) - minW) / (maxW - minW)))
        let f = (mv.rotation / 360).truncatingRemainder(dividingBy: 1)
        rotation = f < 0 ? f + 1 : f   // normalise negative angles (TASK-016)
        teamColor = Self.colorNames.firstIndex(of: mv.toolColor) ?? 0
        number = mv.jerseyNumber > 0 ? "\(mv.jerseyNumber)" : "\(SoccerPlayerToolView.placeholderNumber(mv.id))"
        // Real identity when the tool is linked to a roster player (RD-5).
        if !mv.playerId.isEmpty,
           let p = BEO.realmInstance.object(ofType: RosterPlayer.self, forPrimaryKey: mv.playerId) {
            name = p.name
            subtitle = "#\(p.number) · \(p.position) · \(p.teamSide.capitalized)"
            linked = true
        } else {
            name = "Player \(number)"
            subtitle = "#\(number) · Soccer"
            linked = false
        }
    }

    private func writeSize(_ v: Double) {
        guard let mv = tool() else { return }
        let w = Int((minW + v * (maxW - minW)).rounded())
        BEO.realmInstance.safeWrite { _ in
            mv.width = w
            if !isLine { mv.height = w }   // line/smart: width is the stroke, no height
        }
    }
    private func writeRotation(_ v: Double) {
        guard let mv = tool() else { return }
        BEO.realmInstance.safeWrite { _ in mv.rotation = v * 360 }
    }
    private func pickColor(_ i: Int) {
        teamColor = i
        guard let mv = tool() else { return }
        let rgb = Self.colorRGB[i]
        BEO.realmInstance.safeWrite { _ in
            mv.toolColor = Self.colorNames[i]          // token discs read this
            mv.colorRed = rgb.0; mv.colorGreen = rgb.1 // line/smart render from RGBA
            mv.colorBlue = rgb.2; mv.colorAlpha = 1
        }
        // Views observe Realm now (TASK-017), so the change shows without refreshBoard.
    }
    private func delete() {
        guard let mv = tool() else { return }
        BEO.realmInstance.safeWrite { _ in mv.isDeleted = true }
        state.clearSelection()
        BEO.refreshBoard()
    }
    private func duplicate() {
        guard let mv = tool() else { return }
        BEO.realmInstance.safeWrite { r in
            let copy = ManagedView(value: mv)
            copy.id = UUID().uuidString
            copy.x = mv.x + 300; copy.y = mv.y + 300
            r.create(ManagedView.self, value: copy, update: .all)
        }
        BEO.refreshBoard()
    }
}

private struct ColourSwatch: View {
    var fill: LinearGradient
    var selected: Bool
    init(_ fill: LinearGradient, selected: Bool) { self.fill = fill; self.selected = selected }
    var body: some View {
        RoundedRectangle(cornerRadius: 9, style: .continuous)
            .fill(fill)
            .frame(width: 30, height: 30)
            .overlay(RoundedRectangle(cornerRadius: 9).strokeBorder(.white.opacity(0.12)))
            .overlay {
                if selected {
                    RoundedRectangle(cornerRadius: 9).stroke(Brand.lime, lineWidth: 2).padding(-2)
                }
            }
    }
}

private struct SliderRow: View {
    var label: String
    @Binding var value: Double
    var readout: String
    var centered: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                SectionLabel(text: label)
                Spacer()
                Text(readout).font(AppFont.mono(12)).foregroundStyle(Brand.textMid)
            }
            GeometryReader { geo in
                let w = geo.size.width
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.1)).frame(height: 6)
                    if !centered {
                        Capsule().fill(Brand.lime).frame(width: w * value, height: 6)
                    }
                    Circle().fill(.white).frame(width: 16, height: 16)
                        .shadow(color: .black.opacity(0.5), radius: 3, y: 2)
                        .offset(x: w * value - 8)
                }
                .contentShape(Rectangle())
                // TASK-036: the knob was cosmetic — no gesture was attached, so the
                // slider read as "locked". A zero-distance drag gives both tap-to-jump
                // and smooth drag; the bound setter (writeSize/writeRotation) persists.
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { g in
                            guard w > 0 else { return }
                            value = min(1, max(0, g.location.x / w))
                        }
                )
            }
            .frame(height: 16)
        }
    }
}

// MARK: - 3. Library panel

struct LibraryPanel: View {
    var onAddTool: (String) -> Void = { _ in }    // equipment item name → engine tool
    var onAddSmart: (String) -> Void = { _ in }   // smart-tool subToolType → engine tool
    var onAddGeneral: (String) -> Void = { _ in } // TASK-059: general marker (SF symbol) → engine tool
    var onAddPool: (String) -> Void = { _ in }    // TASK-059: pool ball → engine tool
    var onPickBoard: (String) -> Void = { _ in }   // registry board name → background
    @State private var sport = 0
    @State private var tab: LibraryTab = {
        #if DEBUG
        if let t = ProcessInfo.processInfo.environment["REDESIGN_LIBTAB"],
           let tab = LibraryTab(rawValue: t.capitalized) { return tab }   // e.g. REDESIGN_LIBTAB=pool
        #endif
        return .equipment
    }()
    @State private var selectedBoard = "Soccer Redesign Full View"

    var body: some View {
        PanelShell(width: 288) {
            HStack {
                Text("Tools").font(AppFont.display(15, .bold)).foregroundStyle(Brand.textHi)
                Spacer()
                HStack(spacing: 7) {
                    Image(systemName: "magnifyingglass").font(.system(size: 12, weight: .semibold))
                    Text("Search").font(AppFont.ui(12, .medium))
                }
                .foregroundStyle(Brand.textMuted)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        } content: {
            VStack(alignment: .leading, spacing: 18) {
                // Sport + board-preset picking moved to the Boards drawer — this
                // drawer is TOOLS ONLY now (per request).
                // Tools
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        ForEach(LibraryTab.allCases) { t in
                            Text(t.rawValue)
                                .font(AppFont.ui(12, .semibold))
                                .foregroundStyle(t == tab ? Brand.lime : Brand.textDim)
                                .padding(.bottom, 6)
                                .overlay(alignment: .bottom) {
                                    if t == tab { Rectangle().fill(Brand.lime).frame(height: 2) }
                                }
                                .onTapGesture { tab = t }
                        }
                    }
                    // TASK-040: every grid is driven straight off the engine
                    // enums (allCases), so the full catalog shows and any future
                    // tool auto-appears. Icons/labels come from RedesignToolCatalog
                    // with a fallback, so a new enum case never renders blank.
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 9), count: 3), spacing: 9) {
                        switch tab {
                        case .tactics:
                            ForEach(ViewEngine.Tool.SmartTool.allCases, id: \.self) { st in
                                ToolCell(symbol: st.icon, label: st.displayName)
                                    .onTapGesture { onAddSmart(st.name) }
                                    .draggable(st.name)   // subtype payload; drop delegate resolves it
                            }
                        case .shapes:
                            ForEach(ViewEngine.Tool.ShapeTool.allCases, id: \.self) { sh in
                                ToolCell(symbol: RedesignToolCatalog.toolIcon(sh.name),
                                         label: RedesignToolCatalog.toolLabel(sh.name))
                                    .onTapGesture { onAddTool(sh.name) }
                                    .draggable(sh.name)
                            }
                        case .equipment:
                            ForEach(ViewEngine.Tool.SoccerTool.allCases, id: \.self) { tool in
                                ToolCell(symbol: RedesignToolCatalog.toolIcon(tool.name),
                                         label: RedesignToolCatalog.toolLabel(tool.name))
                                    .onTapGesture { onAddTool(tool.name) }
                                    .draggable(tool.name)
                            }
                        case .markers:
                            // TASK-059: GeneralTool — the subtype rawValue IS an SF symbol name.
                            ForEach(ViewEngine.Tool.GeneralTool.allCases, id: \.self) { g in
                                ToolCell(symbol: g.name, label: g.displayName)
                                    .onTapGesture { onAddGeneral(g.name) }
                                    .draggable(g.name)
                            }
                        case .pool:
                            // TASK-059/060: pool balls (drawn via PoolBallIcon on the board).
                            // NB: ball.displayName is broken for short rawValues — use a safe label.
                            ForEach(ViewEngine.Tool.PoolBallTool.allCases, id: \.self) { ball in
                                ToolCell(symbol: "circle.fill", label: ball.name == "0" ? "Cue" : ball.name)
                                    .onTapGesture { onAddPool(ball.name) }
                                    .draggable(ball.name)
                            }
                        }
                    }
                }
            }
        } footer: { EmptyView() }
    }
}

/// Maps redesign library items to engine identities.
enum RedesignToolCatalog {
    static let equipmentSubtype: [String: String] = [
        "Cone":   "tools_soccer_tall_cone",
        "Goal":   "tools_soccer_goal",
        "Ball":   "tools_soccer_soccer_ball",
        "Flag":   "tools_soccer_flag",
        "Ladder": "tools_soccer_ladder",
        "Dummy":  "tools_soccer_dummy",
    ]

    // TASK-040: SF Symbols for every catalog tool, keyed by engine subToolType.
    // A subtype with no entry falls back to a generic glyph (toolIcon), so a
    // newly-added engine tool still renders in the Library.
    static let toolIcons: [String: String] = [
        // SoccerTool
        "tools_soccer_jersey":      "tshirt.fill",
        "tools_soccer_dummy":       "figure.stand",
        "tools_soccer_steps":       "figure.stairs",
        "tools_soccer_walking":     "figure.walk",
        "tools_soccer_running":     "figure.run",
        "tools_soccer_goal":        "rectangle.portrait.fill",
        "tools_soccer_flag":        "flag.fill",
        "tools_soccer_tall_cone":   "triangle.fill",
        "tools_soccer_mat":         "rectangle.fill",
        "tools_soccer_ladder":      "ladder",
        "tools_soccer_soccer_ball": "soccerball",
        "tools_soccer_curved_line": "scribble.variable",
        "tools_soccer_dotted_line": "line.diagonal",
        // ShapeTool
        "line_straight": "line.diagonal",
        "line_dotted":   "ellipsis",
        "line_curved":   "scribble.variable",
        "circle":        "circle",
        "square":        "square",
        "triangle":      "triangle",
    ]
    static func toolIcon(_ subType: String) -> String { toolIcons[subType] ?? "square.on.square" }

    /// Human label from an engine subtype (strip the family prefix, prettify).
    static func toolLabel(_ subType: String) -> String {
        var t = subType
        for p in ["tools_soccer_", "tactic_"] where t.hasPrefix(p) { t = String(t.dropFirst(p.count)); break }
        if t.hasPrefix("line_") { t = String(t.dropFirst(5)) }
        t = t.replacingOccurrences(of: "_", with: " ")
        return t.isEmpty ? subType.capitalized : t.capitalized
    }

    /// Subtypes that are drawn (rail draw-mode) rather than placed at center.
    static let drawnShapeSubtypes: Set<String> = ["line_straight", "line_dotted", "line_curved"]
    /// Shape subtypes placed as a centered shape (toolType "shape").
    static let placedShapeSubtypes: Set<String> = ["circle", "square", "triangle"]
    /// Registry board minis, cached for picker thumbnails (built once). The
    /// catalogue board names live in `Sample.boards[*].registryName`.
    static let boardMinis: [String: () -> AnyView] = Sports().getAllMinis()
    static func boardMini(_ name: String) -> AnyView? { boardMinis[name].map { $0() } }

    /// Single source of default geometry/colour for a placed smart (tactic) tool
    /// (TASK-018) — used by tap-add, drag-drop and the DEBUG seed so they can't
    /// drift. `center` is the board-space point the tool spans around.
    static func makeSmartTool(_ subType: String, boardId: String, center: CGPoint) -> ManagedView {
        let mv = ManagedView()
        mv.boardId = boardId
        mv.sport = "tool"; mv.toolType = "tactic"; mv.subToolType = subType
        configureSmartTool(mv, center: center)
        return mv
    }

    /// Apply the shared default geometry/colour to a tactic tool (used by both
    /// `makeSmartTool` and the drag-drop path, which already has the row).
    static func configureSmartTool(_ mv: ManagedView, center: CGPoint) {
        mv.startX = center.x - 420; mv.startY = center.y
        mv.endX = center.x + 420; mv.endY = center.y
        mv.centerX = center.x; mv.centerY = center.y - 240
        mv.x = center.x; mv.y = center.y
        mv.width = 34; mv.jerseyNumber = 7
        mv.toolColor = "Lime"
        mv.colorRed = 0.796; mv.colorGreen = 0.859; mv.colorBlue = 0.165; mv.colorAlpha = 1
        mv.dateUpdated = Int(Date().timeIntervalSince1970)
    }

    /// Default equipment tool size, shared by tap-add and drag-drop (TASK-018)
    /// so the same item isn't 200 via tap but 100 via drop.
    static let equipmentSize = 200

    /// Shared shape (circle/square/triangle) defaults for tap-add AND drag-drop
    /// (TASK-058). For shapes, `width` is the STROKE — the redesign was setting
    /// it to 200 (a grotesque stroke); shapes are ~12. Square/triangle corner
    /// geometry is synthesized by MVObject.loadFromRealm's geometryIsUnset
    /// fallback at x/y; circle needs an explicit radius (its field defaults to 0).
    static func configureShapeTool(_ mv: ManagedView, subType: String, center: CGPoint) {
        mv.sport = "tool"; mv.toolType = "shape"; mv.subToolType = subType
        mv.x = center.x; mv.y = center.y
        mv.width = 12; mv.height = 12               // stroke, not size
        if subType == "circle" { mv.radius = 400 }  // diameter the circle view frames to
        mv.toolColor = "Lime"
        mv.colorRed = 0.796; mv.colorGreen = 0.859; mv.colorBlue = 0.165; mv.colorAlpha = 1
        mv.dateUpdated = Int(Date().timeIntervalSince1970)
    }
}

/// Engine-wired Library: equipment tap adds the tool at board centre (and is
/// draggable onto the board); board thumbs switch the registry background.
struct EngineLibraryPanel: View {
    @EnvironmentObject var BEO: BoardEngineObject

    var body: some View {
        LibraryPanel(onAddTool: addTool, onAddSmart: addSmartTool,
                     onAddGeneral: addGeneral, onAddPool: addPool, onPickBoard: pickBoard)
    }

    private func addSmartTool(_ subType: String) {
        let mv = RedesignToolCatalog.makeSmartTool(subType, boardId: BEO.currentActivityId,
                                                   center: CGPoint(x: 2500, y: 3000))
        BEO.realmInstance.safeWrite { r in r.create(ManagedView.self, value: mv, update: .all) }
        BEO.refreshBoard()
    }

    // TASK-059: place a general marker (SF symbol) or a pool ball at board centre.
    private func addGeneral(_ subType: String) { addSimpleTool(subType, toolType: "general") }
    private func addPool(_ subType: String)    { addSimpleTool(subType, toolType: "pool") }
    private func addSimpleTool(_ subType: String, toolType: String) {
        BEO.realmInstance.safeWrite { r in
            let mv = ManagedView()
            mv.boardId = BEO.currentActivityId
            mv.sport = "tool"; mv.toolType = toolType; mv.subToolType = subType
            mv.x = 2500; mv.y = 3000
            mv.width = 150; mv.height = 150
            if toolType == "general" {
                // req 3: visible white default; the colour picker (0–1 RGBA) overrides.
                mv.colorRed = 1; mv.colorGreen = 1; mv.colorBlue = 1; mv.colorAlpha = 1
            }
            mv.dateUpdated = Int(Date().timeIntervalSince1970)
            r.create(ManagedView.self, value: mv, update: .all)
        }
        BEO.refreshBoard()
    }

    // TASK-040: `subType` is now the engine subToolType directly (from the enum),
    // not a display name. Lines are *drawn* (enter draw mode); circle/square/
    // triangle are placed as "shape" tools; everything else is a "soccer" tool.
    private func addTool(_ subType: String) {
        if RedesignToolCatalog.drawnShapeSubtypes.contains(subType) {
            // TASK-062: pass the real line subtype (was collapsing line_dotted →
            // line_straight, silently losing the dotted variant).
            BEO.enableDrawing(subType: subType)
            return
        }
        let isShape = RedesignToolCatalog.placedShapeSubtypes.contains(subType)
        BEO.realmInstance.safeWrite { r in
            let mv = ManagedView()
            mv.boardId = BEO.currentActivityId
            if isShape {
                // TASK-058: shapes use a stroke width + (circle) radius, not the
                // equipment size, so they don't render as a 200pt-stroke blob.
                RedesignToolCatalog.configureShapeTool(mv, subType: subType, center: CGPoint(x: 2500, y: 3000))
            } else {
                mv.sport = "tool"
                mv.toolType = "soccer"
                mv.subToolType = subType
                mv.x = 2500; mv.y = 3000
                mv.width = RedesignToolCatalog.equipmentSize; mv.height = RedesignToolCatalog.equipmentSize
                mv.dateUpdated = Int(Date().timeIntervalSince1970)
            }
            r.create(ManagedView.self, value: mv, update: .all)
        }
        BEO.refreshBoard()
    }

    private func pickBoard(_ name: String) {
        BEO.boardBgOverride = name
        BEO.boardBgName = name
    }
}

private struct SportPill: View {
    var sport: Sport
    var selected: Bool
    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: sport.symbol).font(.system(size: 13))
            Text(sport.name).font(AppFont.ui(12, .semibold))
        }
        .foregroundStyle(selected ? Color(brandHex: "9FE0CF") : Brand.textMuted)
        .padding(.horizontal, 13).padding(.vertical, 8)
        .background((selected ? Brand.teal.opacity(0.2) : .white.opacity(0.04)),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 10)
            .strokeBorder(selected ? Color(brandHex: "7FC4B3").opacity(0.4) : Brand.panelLine))
    }
}

private struct BoardThumb: View {
    var preset: BoardPreset
    var selected: Bool
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Brand.pitch
                // Real registry mini (100×100) scaled into the 56pt thumbnail —
                // distinct turf colours make boards recognisable. Falls back to a
                // generic pitch outline if the board has no mini.
                if let mini = RedesignToolCatalog.boardMini(preset.registryName) {
                    mini
                        .frame(width: 100, height: 100)
                        .scaleEffect(56.0 / 100.0)
                        .frame(width: 56, height: 56)
                } else {
                    RoundedRectangle(cornerRadius: 3).strokeBorder(Brand.pitchLine.opacity(0.55))
                        .padding(6)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .clipped()
            Text(preset.name)
                .font(AppFont.ui(11, .semibold))
                .foregroundStyle(selected ? Color(brandHex: "E6EBE9") : Brand.textMid)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 9).padding(.vertical, 7)
                .background(.black.opacity(0.25))
        }
        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 11)
                .strokeBorder(selected ? Brand.lime : .white.opacity(0.08), lineWidth: selected ? 2 : 1)
        }
    }
}

/// Library cell for any tool (equipment or smart) — icon + label.
private struct ToolCell: View {
    var symbol: String
    var label: String
    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: symbol).font(.system(size: 22, weight: .light)).foregroundStyle(Brand.textMid)
            Text(label).font(AppFont.ui(10, .medium)).foregroundStyle(Brand.textMuted)
                .lineLimit(1).minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 13).frame(height: 64)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 11).strokeBorder(Brand.panelLine))
    }
}

/// Simple wrap layout for chips.
private struct FlowChips<Content: View>: View {
    var items: [Int]
    var selected: Int
    @ViewBuilder var content: (Int) -> Content
    var body: some View {
        // Two-per-row is enough for the four sports; use a grid for predictability.
        LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading),
                            GridItem(.flexible(), alignment: .leading)], spacing: 8) {
            ForEach(items, id: \.self) { content($0) }
        }
    }
}

// MARK: - Footer helpers

private struct PanelFooter<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack {
            content
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) { Rectangle().fill(Brand.hairline).frame(height: 1) }
    }
}

struct FooterButton: View {
    var symbol: String
    var label: String
    var destructive: Bool = false
    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: symbol).font(.system(size: 13, weight: .semibold))
            Text(label).font(AppFont.ui(12, .semibold))
        }
        .foregroundStyle(destructive ? Brand.danger : Brand.textMid)
        .frame(maxWidth: .infinity).padding(.vertical, 10)
        .background((destructive ? Brand.danger.opacity(0.12) : .white.opacity(0.05)),
                    in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 11)
            .strokeBorder(destructive ? Brand.danger.opacity(0.25) : Brand.panelLine))
    }
}
