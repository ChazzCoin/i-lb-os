//
//  RedesignPitchBackground.swift
//  Ludi Boards — tactical board redesign (RD-2 / TASK-003)
//
//  Bridges the redesign's vector pitch into the live engine as a Sports
//  registry board background. Unlike the scaffold's `PitchView` (which also
//  draws tokens/ball/arrows), this is JUST the field surface — the engine
//  renders tools over it via `MVEngine.Display`. Mirrors the framing
//  convention of `SoccerFieldFullView` (`width: boardHeight, height:
//  boardWidth`) so spawned tools share the field's coordinate space.
//
//  Registered under Soccer in `Providers/Sports.swift`. Field rotation is
//  applied by `BoardEngineView` (the overlay is rotated uniformly), so this
//  view does not rotate itself.
//

import SwiftUI

// MARK: - Markings (normalized 724×464, full or attacking-half)

struct RedesignPitchMarkings: Shape {
    var half: Bool = false

    func path(in rect: CGRect) -> Path {
        let W: CGFloat = 724, H: CGFloat = 464
        let sx = rect.width / W, sy = rect.height / H
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }
        var path = Path()

        // Outer touchline
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: 14 * sx, height: 14 * sy))

        if half {
            // Attacking half: halfway arc on the left edge + the right boxes.
            path.addArc(center: p(0, H / 2), radius: 60 * sx,
                        startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: false)
            path.addRect(CGRect(x: p(628, 132).x, y: p(628, 132).y, width: 96 * sx, height: 200 * sy))
            path.addRect(CGRect(x: p(684, 177).x, y: p(684, 177).y, width: 40 * sx, height: 110 * sy))
            path.move(to: p(628, 177)); path.addQuadCurve(to: p(628, 287), control: p(574, 232))
        } else {
            // Halfway line
            path.move(to: p(W / 2, 0)); path.addLine(to: p(W / 2, H))
            // Center circle
            path.addEllipse(in: CGRect(x: p(W / 2 - 60, H / 2 - 60).x,
                                       y: p(W / 2 - 60, H / 2 - 60).y,
                                       width: 120 * sx, height: 120 * sy))
            // Penalty + goal boxes (both ends)
            path.addRect(CGRect(x: p(0, 132).x, y: p(0, 132).y, width: 96 * sx, height: 200 * sy))
            path.addRect(CGRect(x: p(0, 177).x, y: p(0, 177).y, width: 40 * sx, height: 110 * sy))
            path.addRect(CGRect(x: p(628, 132).x, y: p(628, 132).y, width: 96 * sx, height: 200 * sy))
            path.addRect(CGRect(x: p(684, 177).x, y: p(684, 177).y, width: 40 * sx, height: 110 * sy))
            // Penalty arcs (both ends)
            path.move(to: p(96, 177)); path.addQuadCurve(to: p(96, 287), control: p(150, 232))
            path.move(to: p(628, 177)); path.addQuadCurve(to: p(628, 287), control: p(574, 232))
        }
        return path
    }
}

// MARK: - Field surface (striped turf + sheen + vignette + markings)

struct RedesignPitchSurface: View {
    var half: Bool = false
    var lineWidth: CGFloat = 2

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack {
                Brand.pitch
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { i in
                        (i % 2 == 0 ? Brand.pitch : Brand.pitchStripe).frame(width: w / 8)
                    }
                }
                LinearGradient(colors: [.white.opacity(0.07), .clear, .black.opacity(0.16)],
                               startPoint: .top, endPoint: .bottom)
                RadialGradient(colors: [.clear, .black.opacity(0.30)],
                               center: UnitPoint(x: 0.5, y: 0.44),
                               startRadius: geo.size.height * 0.3,
                               endRadius: geo.size.height * 0.72)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RedesignPitchMarkings(half: half)
                .stroke(Brand.pitchLine.opacity(0.82), lineWidth: lineWidth)
        )
    }
}

// MARK: - Registry-compatible board background

/// The redesign soccer pitch as an engine board background. `isMini` renders
/// the 100×100 thumbnail used in board pickers; otherwise it fills the live
/// board frame using the same `boardHeight × boardWidth` convention as the
/// legacy `SoccerFieldFullView`, so tools land on the field identically.
struct RedesignSoccerBoardView: View {
    @EnvironmentObject var BEO: BoardEngineObject
    let isMini: Bool
    var half: Bool = false

    var body: some View {
        RedesignPitchSurface(half: half, lineWidth: isMini ? 1.5 : 14)
            .frame(width: isMini ? 100.0 : BEO.boardHeight,
                   height: isMini ? 100.0 : BEO.boardWidth)
    }
}
