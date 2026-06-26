//
//  PitchView.swift
//  Ludi Boards
//
//  Soccer pitch: striped turf, line markings drawn with a Shape,
//  passing arrows, the ball, and player tokens positioned by fraction.
//

import SwiftUI

// MARK: - Pitch line markings

/// All standard markings, drawn in a normalized 724×464 space and scaled to fit.
struct PitchMarkings: Shape {
    func path(in rect: CGRect) -> Path {
        // Normalized design space (the field rect from the mockup).
        let W: CGFloat = 724, H: CGFloat = 464
        let sx = rect.width / W, sy = rect.height / H
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }
        var path = Path()

        // Outer touchline
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: 14 * sx, height: 14 * sy))

        // Halfway line
        path.move(to: p(W / 2, 0)); path.addLine(to: p(W / 2, H))

        // Center circle
        path.addEllipse(in: CGRect(x: p(W / 2 - 60, H / 2 - 60).x,
                                   y: p(W / 2 - 60, H / 2 - 60).y,
                                   width: 120 * sx, height: 120 * sy))

        // Penalty boxes
        path.addRect(CGRect(x: p(0, 132).x, y: p(0, 132).y, width: 96 * sx, height: 200 * sy))
        path.addRect(CGRect(x: p(0, 177).x, y: p(0, 177).y, width: 40 * sx, height: 110 * sy))
        path.addRect(CGRect(x: p(628, 132).x, y: p(628, 132).y, width: 96 * sx, height: 200 * sy))
        path.addRect(CGRect(x: p(684, 177).x, y: p(684, 177).y, width: 40 * sx, height: 110 * sy))

        // Penalty arcs
        path.move(to: p(96, 177))
        path.addQuadCurve(to: p(96, 287), control: p(150, 232))
        path.move(to: p(628, 177))
        path.addQuadCurve(to: p(628, 287), control: p(574, 232))

        return path
    }
}

// MARK: - The turf (stripes + sheen + vignette), clipped to a rounded rect

struct PitchTurf: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack {
                Brand.pitch
                // Mowing stripes
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { i in
                        (i % 2 == 0 ? Brand.pitch : Brand.pitchStripe)
                            .frame(width: w / 8)
                    }
                }
                // Sheen
                LinearGradient(
                    colors: [.white.opacity(0.07), .clear, .black.opacity(0.16)],
                    startPoint: .top, endPoint: .bottom
                )
                // Vignette
                RadialGradient(
                    colors: [.clear, .black.opacity(0.30)],
                    center: UnitPoint(x: 0.5, y: 0.44),
                    startRadius: geo.size.height * 0.3,
                    endRadius: geo.size.height * 0.72
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            PitchMarkings()
                .stroke(Brand.pitchLine.opacity(0.82), lineWidth: 2)
        )
    }
}

// MARK: - A single player token

struct PlayerDisc: View {
    let token: BoardToken
    var selected: Bool = false

    var body: some View {
        Text("\(token.number)")
            .font(AppFont.display(token.diameter * 0.44, .bold))
            .foregroundStyle(token.kind.ink)
            .frame(width: token.diameter, height: token.diameter)
            .background(token.kind.fill, in: Circle())
            .overlay(Circle().strokeBorder(token.kind.ring, lineWidth: 1.5))
            .overlay(
                Circle()
                    .stroke(Brand.lime, lineWidth: selected ? 2 : 0)
                    .padding(-3)
            )
            .overlay(
                Circle()
                    .stroke(Brand.lime.opacity(selected ? 0.2 : 0), lineWidth: selected ? 4 : 0)
                    .padding(-6)
            )
            .shadow(color: .black.opacity(0.42), radius: 3.5, x: 0, y: 3)
    }
}

// MARK: - Passing arrows overlay (decorative, normalized to 724×464 field)

private struct ArrowsOverlay: Shape {
    func path(in rect: CGRect) -> Path {
        let W: CGFloat = 724, H: CGFloat = 464
        let sx = rect.width / W, sy = rect.height / H
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }
        var path = Path()
        // dashed build-up pass
        path.move(to: p(277, 234)); path.addQuadCurve(to: p(472, 234), control: p(372, 205))
        return path
    }
}

private struct LimeRunShape: Shape {
    func path(in rect: CGRect) -> Path {
        let W: CGFloat = 724, H: CGFloat = 464
        let sx = rect.width / W, sy = rect.height / H
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }
        var path = Path()
        path.move(to: p(492, 230)); path.addLine(to: p(716, 228))
        return path
    }
}

// MARK: - Full pitch stage

struct PitchView: View {
    var homeTokens: [BoardToken] = Sample.homeTokens
    var awayTokens: [BoardToken] = Sample.awayTokens
    var selectedNumber: Int? = nil
    /// Show the dashed build-up + lime run arrows.
    var showArrows: Bool = true

    var body: some View {
        GeometryReader { geo in
            let r = geo.frame(in: .local)
            ZStack {
                PitchTurf()

                if showArrows {
                    ArrowsOverlay()
                        .stroke(Brand.pitchLine.opacity(0.9),
                                style: StrokeStyle(lineWidth: 2.6, dash: [7, 7]))
                    LimeRunShape()
                        .stroke(Brand.lime,
                                style: StrokeStyle(lineWidth: 3.4, lineCap: .round))
                        .shadow(color: Brand.lime.opacity(0.45), radius: 5)
                }

                // Ball
                Circle()
                    .fill(RadialGradient(colors: [.white, Color(brandHex: "CDD4D8")],
                                         center: UnitPoint(x: 0.34, y: 0.28),
                                         startRadius: 0, endRadius: 9))
                    .frame(width: 13, height: 13)
                    .shadow(color: .black.opacity(0.5), radius: 2.5, y: 2)
                    .position(x: r.width * 0.39, y: r.height * 0.504)

                // Tokens
                ForEach(awayTokens) { t in
                    PlayerDisc(token: t)
                        .position(x: r.width * t.x, y: r.height * t.y)
                }
                ForEach(homeTokens) { t in
                    PlayerDisc(token: t, selected: t.number == selectedNumber)
                        .position(x: r.width * t.x, y: r.height * t.y)
                }
            }
        }
        .aspectRatio(724.0 / 464.0, contentMode: .fit)
    }
}
