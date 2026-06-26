//
//  Panels.swift
//  Ludi Boards
//
//  The three right-hand side panels: Squad roster, Properties (node
//  selected), and the Add-to-board Library.
//

import SwiftUI

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

private struct RosterHeader: View {
    var swatch: LinearGradient?
    var title: String
    var count: Int
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 3)
                .fill(swatch ?? LinearGradient(colors: [Color(hex: "ECEFF1")], startPoint: .top, endPoint: .bottom))
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
                .foregroundStyle(highlighted ? Color(hex: "E6EBE9") : Brand.textMid)
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
    @State private var size: Double = 0.52
    @State private var rotation: Double = 0.5
    @State private var teamColor = 0

    var body: some View {
        PanelShell {
            HStack {
                Text("Properties").font(AppFont.display(15, .bold)).foregroundStyle(Brand.textHi)
                Spacer()
                Image(systemName: "xmark").font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Brand.textMuted)
                    .frame(width: 26, height: 26)
                    .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            }
        } content: {
            VStack(alignment: .leading, spacing: 18) {
                // Identity
                HStack(spacing: 13) {
                    Text("9").font(AppFont.display(19, .bold)).foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(.homeJersey, in: Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.3), lineWidth: 1.5))
                        .overlay(Circle().stroke(Brand.lime, lineWidth: 2).padding(-2))
                        .overlay(Circle().stroke(Brand.lime.opacity(0.18), lineWidth: 3).padding(-5))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Marcus Reed").font(AppFont.ui(16, .bold)).foregroundStyle(Brand.textHi)
                        Text("#9 · Striker · Home").font(AppFont.ui(12, .medium)).foregroundStyle(Brand.textMuted)
                    }
                }

                // Team colour swatches
                VStack(alignment: .leading, spacing: 10) {
                    SectionLabel(text: "TEAM COLOUR")
                    HStack(spacing: 11) {
                        ColourSwatch(.homeJersey, selected: teamColor == 0).onTapGesture { teamColor = 0 }
                        ColourSwatch(LinearGradient(colors: [Color(hex: "ECEFF1")], startPoint: .top, endPoint: .bottom), selected: teamColor == 1).onTapGesture { teamColor = 1 }
                        ColourSwatch(LinearGradient(colors: [Color(hex: "2C3648")], startPoint: .top, endPoint: .bottom), selected: teamColor == 2).onTapGesture { teamColor = 2 }
                        ColourSwatch(LinearGradient(colors: [Brand.lime], startPoint: .top, endPoint: .bottom), selected: teamColor == 3).onTapGesture { teamColor = 3 }
                        ColourSwatch(LinearGradient(colors: [Brand.danger], startPoint: .top, endPoint: .bottom), selected: teamColor == 4).onTapGesture { teamColor = 4 }
                    }
                }

                SliderRow(label: "SIZE", value: $size, readout: "34 px")
                SliderRow(label: "ROTATION", value: $rotation, readout: "0°", centered: true)

                // Linked player
                VStack(alignment: .leading, spacing: 10) {
                    SectionLabel(text: "LINKED PLAYER")
                    HStack(spacing: 11) {
                        Text("MR").font(AppFont.display(13, .bold)).foregroundStyle(.white)
                            .frame(width: 34, height: 34).background(.homeJersey, in: Circle())
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Marcus Reed").font(AppFont.ui(13, .semibold)).foregroundStyle(Color(hex: "E6EBE9"))
                            Text("Stats synced").font(AppFont.ui(11, .medium)).foregroundStyle(Color(hex: "7FC4B3"))
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(Brand.textFaint)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 10)
                    .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Brand.panelLine))
                }
            }
        } footer: {
            PanelFooter {
                HStack(spacing: 9) {
                    FooterButton(symbol: "square.on.square", label: "Duplicate")
                    FooterButton(symbol: "trash", label: "Delete", destructive: true)
                }
            }
        }
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
                            BoardThumb(preset: b, selected: i == board).onTapGesture { board = i }
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
                        ForEach(Sample.equipment) { EquipmentCell(item: $0) }
                    }
                }
            }
        } footer: { EmptyView() }
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
        .foregroundStyle(selected ? Color(hex: "9FE0CF") : Brand.textMuted)
        .padding(.horizontal, 13).padding(.vertical, 8)
        .background((selected ? Brand.teal.opacity(0.2) : .white.opacity(0.04)),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 10)
            .strokeBorder(selected ? Color(hex: "7FC4B3").opacity(0.4) : Brand.panelLine))
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
                .foregroundStyle(selected ? Color(hex: "E6EBE9") : Brand.textMid)
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
