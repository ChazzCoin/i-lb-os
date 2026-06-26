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
            ScrollView { content.padding(16) }
            footer
        }
        .frame(width: width)
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
                RosterHeader(swatch: .homeJersey, title: "HOME · 4-3-3", count: 11)
                    .padding(.bottom, 11)
                VStack(spacing: 3) {
                    RosterRow(player: Sample.homeRoster[0], highlighted: true)
                    ForEach(Sample.homeRoster.dropFirst()) { RosterRow(player: $0) }
                }
                RosterHeader(swatch: nil, title: "AWAY · 4-4-2", count: 5)
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

    private func roster(_ side: String) -> [RosterPlayer] {
        Array(BEO.realmInstance.objects(RosterPlayer.self)
            .filter("boardId == %@ AND teamSide == %@", BEO.currentActivityId, side)
            .sorted(byKeyPath: "orderIndex"))
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
                RosterHeader(swatch: .homeJersey, title: "HOME · 4-3-3", count: home.count).padding(.bottom, 11)
                VStack(spacing: 3) {
                    ForEach(home) { p in RosterRow(player: squad(p)).onTapGesture { place(p) } }
                }
                RosterHeader(swatch: nil, title: "AWAY · 4-4-2", count: away.count)
                    .padding(.top, 18).padding(.bottom, 11)
                VStack(spacing: 3) {
                    ForEach(away) { p in RosterRow(player: squad(p)).onTapGesture { place(p) } }
                }
            }
        } footer: {
            PanelFooter { FooterButton(symbol: "plus", label: "Add player") }
        }
    }

    private func place(_ p: RosterPlayer) {
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

private struct RosterHeader: View {
    var swatch: LinearGradient?
    var title: String
    var count: Int
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 3)
                .fill(swatch ?? LinearGradient(colors: [Color(brandHex: "ECEFF1")], startPoint: .top, endPoint: .bottom))
                .frame(width: 9, height: 9)
            Text(title).font(AppFont.ui(12, .semibold)).tracking(0.5).foregroundStyle(Brand.textMuted)
            Spacer()
            Text("\(count)").font(AppFont.mono(11)).foregroundStyle(Brand.textFaint)
        }
    }
}

private struct RosterRow: View {
    var player: SquadPlayer
    var highlighted: Bool = false
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
            Text(player.position).font(AppFont.ui(11, .medium)).foregroundStyle(Brand.textDim)
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

// MARK: - 2. Properties panel (node selected)

struct PropertiesPanel: View {
    // Identity + readouts (engine values flow in via `EnginePropertiesPanel`).
    var number: String = "9"
    var name: String = "Marcus Reed"
    var subtitle: String = "#9 · Striker · Home"
    var sizeReadout: String = "34 px"
    var rotationReadout: String = "0°"
    var teamColor: Int = 0
    var showLinkedPlayer: Bool = true
    var onPickColor: (Int) -> Void = { _ in }
    var onDuplicate: () -> Void = {}
    var onDelete: () -> Void = {}
    var onClose: () -> Void = {}

    @Binding var size: Double
    @Binding var rotation: Double

    // Static / preview convenience (self-managed sliders).
    init() { _size = .constant(0.52); _rotation = .constant(0.5) }
    init(number: String, name: String, subtitle: String, sizeReadout: String,
         rotationReadout: String, teamColor: Int, showLinkedPlayer: Bool,
         size: Binding<Double>, rotation: Binding<Double>,
         onPickColor: @escaping (Int) -> Void, onDuplicate: @escaping () -> Void,
         onDelete: @escaping () -> Void, onClose: @escaping () -> Void) {
        self.number = number; self.name = name; self.subtitle = subtitle
        self.sizeReadout = sizeReadout; self.rotationReadout = rotationReadout
        self.teamColor = teamColor; self.showLinkedPlayer = showLinkedPlayer
        self.onPickColor = onPickColor; self.onDuplicate = onDuplicate
        self.onDelete = onDelete; self.onClose = onClose
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

                SliderRow(label: "SIZE", value: $size, readout: sizeReadout)
                SliderRow(label: "ROTATION", value: $rotation, readout: rotationReadout, centered: true)

                // Linked player (real roster lands in RD-5)
                if showLinkedPlayer {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(text: "LINKED PLAYER")
                        HStack(spacing: 11) {
                            Text(initials).font(AppFont.display(13, .bold)).foregroundStyle(.white)
                                .frame(width: 34, height: 34).background(.homeJersey, in: Circle())
                            VStack(alignment: .leading, spacing: 1) {
                                Text(name).font(AppFont.ui(13, .semibold)).foregroundStyle(Color(brandHex: "E6EBE9"))
                                Text("Stats synced").font(AppFont.ui(11, .medium)).foregroundStyle(Color(brandHex: "7FC4B3"))
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(Brand.textFaint)
                        }
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Brand.panelLine))
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

    private static let minW = 80.0, maxW = 500.0
    private static let colorNames = ["Teal", "Silver", "Black", "Lime", "Red"]

    var body: some View {
        PropertiesPanel(
            number: number,
            name: name,
            subtitle: subtitle,
            sizeReadout: "\(Int(currentWidth)) px",
            rotationReadout: "\(Int((rotation * 360).rounded()))°",
            teamColor: teamColor,
            showLinkedPlayer: linked,                // real when the tool is roster-linked
            size: Binding(get: { size }, set: { size = $0; writeSize($0) }),
            rotation: Binding(get: { rotation }, set: { rotation = $0; writeRotation($0) }),
            onPickColor: pickColor,
            onDuplicate: duplicate,
            onDelete: delete,
            onClose: { state.clearSelection() }
        )
        .onAppear(perform: loadFromTool)
        .onChange(of: state.selectedToolId) { _, _ in loadFromTool() }
    }

    private var currentWidth: Double { Self.minW + size * (Self.maxW - Self.minW) }

    private func tool() -> ManagedView? {
        guard let id = state.selectedToolId else { return nil }
        return BEO.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: id)
    }

    private func loadFromTool() {
        guard let mv = tool() else { return }
        size = max(0, min(1, (Double(mv.width) - Self.minW) / (Self.maxW - Self.minW)))
        rotation = (mv.rotation / 360).truncatingRemainder(dividingBy: 1)
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
        let w = Int((Self.minW + v * (Self.maxW - Self.minW)).rounded())
        BEO.realmInstance.safeWrite { _ in mv.width = w; mv.height = w }
    }
    private func writeRotation(_ v: Double) {
        guard let mv = tool() else { return }
        BEO.realmInstance.safeWrite { _ in mv.rotation = v * 360 }
    }
    private func pickColor(_ i: Int) {
        teamColor = i
        guard let mv = tool() else { return }
        BEO.realmInstance.safeWrite { _ in mv.toolColor = Self.colorNames[i] }
        BEO.refreshBoard()    // re-render so the disc picks up the new colour
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
            }
            .frame(height: 16)
        }
    }
}

// MARK: - 3. Library panel

struct LibraryPanel: View {
    var onAddTool: (String) -> Void = { _ in }   // equipment item name → engine tool
    var onPickBoard: (Int) -> Void = { _ in }     // board preset index → background
    @State private var sport = 0
    @State private var tab: LibraryTab = .equipment
    @State private var board = 0

    var body: some View {
        PanelShell(width: 288) {
            HStack {
                Text("Add to board").font(AppFont.display(15, .bold)).foregroundStyle(Brand.textHi)
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
                // Sport
                VStack(alignment: .leading, spacing: 11) {
                    SectionLabel(text: "SPORT")
                    FlowChips(items: Sample.sports.indices.map { $0 }, selected: sport) { i in
                        SportPill(sport: Sample.sports[i], selected: i == sport)
                            .onTapGesture { sport = i }
                    }
                }
                // Boards
                VStack(alignment: .leading, spacing: 11) {
                    SectionLabel(text: "BOARDS")
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible())], spacing: 10) {
                        ForEach(Array(Sample.boards.enumerated()), id: \.offset) { i, b in
                            BoardThumb(preset: b, selected: i == board)
                                .onTapGesture { board = i; onPickBoard(i) }
                        }
                    }
                }
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
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 9), count: 3), spacing: 9) {
                        ForEach(Sample.equipment) { item in
                            EquipmentCell(item: item)
                                .onTapGesture { onAddTool(item.name) }
                                // Drag payload must be the catalog subtype so the
                                // board's drop delegate resolves it correctly.
                                .draggable(RedesignToolCatalog.equipmentSubtype[item.name] ?? item.name)
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
    static let boardName: [Int: String] = [
        0: "Soccer Redesign Full View",
        1: "Soccer Redesign Half View",
        2: "Soccer Field Full View",
        3: "Pool Table 1",
    ]
}

/// Engine-wired Library: equipment tap adds the tool at board centre (and is
/// draggable onto the board); board thumbs switch the registry background.
struct EngineLibraryPanel: View {
    @EnvironmentObject var BEO: BoardEngineObject

    var body: some View {
        LibraryPanel(onAddTool: addTool, onPickBoard: pickBoard)
    }

    private func addTool(_ name: String) {
        guard let sub = RedesignToolCatalog.equipmentSubtype[name] else { return }
        BEO.realmInstance.safeWrite { r in
            let mv = ManagedView()
            mv.boardId = BEO.currentActivityId
            mv.sport = "tool"; mv.toolType = "soccer"; mv.subToolType = sub
            mv.x = 2500; mv.y = 3000; mv.width = 200; mv.height = 200
            mv.dateUpdated = Int(Date().timeIntervalSince1970)
            r.create(ManagedView.self, value: mv, update: .all)
        }
        BEO.refreshBoard()
    }

    private func pickBoard(_ i: Int) {
        guard let name = RedesignToolCatalog.boardName[i] else { return }
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
                RoundedRectangle(cornerRadius: 3).strokeBorder(Brand.pitchLine.opacity(0.55))
                    .padding(6)
            }
            .frame(height: 56)
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

private struct EquipmentCell: View {
    var item: EquipmentItem
    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: item.symbol).font(.system(size: 22, weight: .light)).foregroundStyle(Brand.textMid)
            Text(item.name).font(AppFont.ui(10, .medium)).foregroundStyle(Brand.textMuted)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 13)
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
