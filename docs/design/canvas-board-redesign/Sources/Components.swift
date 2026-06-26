//
//  Components.swift
//  Ludi Boards
//
//  Reusable chrome: top bar, left tool rail, bottom control pill,
//  presence avatars and small building blocks. Icons use SF Symbols
//  (the redesign's custom line icons map cleanly onto these).
//

import SwiftUI

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

struct TopBar: View {
    @Binding var mode: EditorMode
    var title: String = "Activity 3 · Build-up"
    var squad: String = "U-12 Squad"

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
                    Text(title).foregroundStyle(Brand.textMid)
                }
                .font(AppFont.ui(14, .semibold))

                SportChip()
            }

            Spacer()
            ModeSwitch(mode: $mode)
            Spacer()

            // Presence + share
            HStack(spacing: 14) {
                HStack(spacing: -9) {
                    PresenceAvatar(initials: "CR", fill: .homeJersey, live: true)
                    PresenceAvatar(initials: "JM",
                                   fill: LinearGradient(colors: [Color(hex: "5B7491"), Color(hex: "3F5670")], startPoint: .top, endPoint: .bottom))
                    PresenceAvatar(initials: "+3",
                                   fill: LinearGradient(colors: [Color(hex: "8A6F4A"), Color(hex: "6A533A")], startPoint: .top, endPoint: .bottom))
                }
                ShareButton()
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
}

private struct SportChip: View {
    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "flag.fill").font(.system(size: 12))
            Text("Soccer · Full").font(AppFont.ui(12, .semibold))
            Image(systemName: "chevron.down").font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(Color(hex: "7FC4B3"))
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

struct ToolRail: View {
    @State private var active = 0
    /// (symbol, isDivider-after)
    private let tools: [(String, Bool)] = [
        ("cursorarrow", false), ("hand.draw", true),
        ("pencil.tip", false), ("scribble.variable", false), ("photo", true),
        ("person", false), ("triangle", false), ("flag", true),
        ("paintbrush.pointed", false),
    ]

    var body: some View {
        VStack(spacing: 5) {
            ForEach(Array(tools.enumerated()), id: \.offset) { i, t in
                RailButton(symbol: t.0, active: i == active) { active = i }
                if t.1 { Divider().overlay(Brand.hairline).frame(width: 28) }
            }
        }
        .padding(8)
        .glassPanel(fill: 0.78)
        .frame(width: 56)
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
    @State private var zoom = 100

    var body: some View {
        HStack(spacing: 3) {
            PillIcon("lock")
            PillIcon("arrow.uturn.backward")
            PillIcon("arrow.uturn.forward")
            divider
            PillIcon("minus.magnifyingglass")
            Text("\(zoom)%")
                .font(AppFont.mono(13))
                .foregroundStyle(Brand.textMid)
                .frame(minWidth: 46)
            PillIcon("plus.magnifyingglass")
            PillIcon("scope")
            divider
            HStack(spacing: 7) {
                Image(systemName: "circle.fill").font(.system(size: 13))
                Text("Record").font(AppFont.ui(12, .semibold))
            }
            .foregroundStyle(Brand.danger)
            .padding(.leading, 9).padding(.trailing, 12)
            .frame(height: 34)
            .background(Brand.danger.opacity(0.14), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        }
        .padding(.horizontal, 9).padding(.vertical, 7)
        .glassPanel(radius: 14, fill: 0.86)
    }

    private var divider: some View {
        Rectangle().fill(.white.opacity(0.1)).frame(width: 1, height: 22).padding(.horizontal, 5)
    }
}

private struct PillIcon: View {
    var symbol: String
    init(_ s: String) { symbol = s }
    @State private var hover = false
    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(hover ? Brand.text : Brand.textMuted)
            .frame(width: 34, height: 34)
            .background {
                if hover { RoundedRectangle(cornerRadius: 9, style: .continuous).fill(.white.opacity(0.06)) }
            }
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
