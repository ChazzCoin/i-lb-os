//
//  CanvasGridLines.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 8/13/25.
//
import SwiftUI
import Foundation

struct InfiniteGrid: View {
    let spacing: CGFloat
    let color: Color
    let baseLineWidth: CGFloat
    let showLabels: Bool

    // World transform inputs
    @Binding var offset: CGPoint
    @Binding var scale: CGFloat

    var body: some View {
        GeometryReader { geo in
            let viewW = geo.size.width
            let viewH = geo.size.height

            // Screen-space step (grid spacing in world * scale)
            let step = max(8, spacing * max(scale, 0.0001))

            // Convert world offset to screen offset
            let screenOffsetX = offset.x * max(scale, 0.0001)
            let screenOffsetY = offset.y * max(scale, 0.0001)

            // Phase so lines “slide” with panning
            let phaseX = ((screenOffsetX).truncatingRemainder(dividingBy: step) + step).truncatingRemainder(dividingBy: step)
            let phaseY = ((screenOffsetY).truncatingRemainder(dividingBy: step) + step).truncatingRemainder(dividingBy: step)

            Canvas { ctx, _ in
                let lineWidth = max(0.5, baseLineWidth / max(scale, 0.0001))
                let majorEvery: CGFloat = 5
                let majorStep = step * majorEvery

                func strokeLine(from: CGPoint, to: CGPoint, major: Bool) {
                    var p = Path()
                    p.move(to: from)
                    p.addLine(to: to)
                    ctx.stroke(p, with: .color(major ? color.opacity(0.7) : color), lineWidth: major ? lineWidth * 1.25 : lineWidth)
                }

                // Vertical
                var x = -phaseX
                while x <= viewW {
                    let major = ((x + phaseX) / step).truncatingRemainder(dividingBy: majorEvery) == 0
                    strokeLine(from: CGPoint(x: x, y: 0), to: CGPoint(x: x, y: viewH), major: major)
                    x += step
                }

                // Horizontal
                var y = -phaseY
                while y <= viewH {
                    let major = ((y + phaseY) / step).truncatingRemainder(dividingBy: majorEvery) == 0
                    strokeLine(from: CGPoint(x: 0, y: y), to: CGPoint(x: viewW, y: y), major: major)
                    y += step
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

struct GridLayer: View {
    let size: CGSize
    let spacing: CGFloat
    let color: Color
    let baseLineWidth: CGFloat
    let showLabels: Bool
    let scale: CGFloat

    var body: some View {
        Canvas { context, canvasSize in
            let w = size.width
            let h = size.height

            // Keep lines ~1pt on screen regardless of zoom
            let lineWidth = max(0.5, baseLineWidth / max(scale, 0.0001))

            // Major/minor grid (optional: every 5th line stronger)
            let majorStep = spacing * 5

            func strokeLine(from: CGPoint, to: CGPoint, isMajor: Bool) {
                var path = Path()
                path.move(to: from)
                path.addLine(to: to)
                context.stroke(path, with: .color(isMajor ? color.opacity(0.7) : color), lineWidth: isMajor ? lineWidth * 1.25 : lineWidth)
            }

            // Vertical lines
            var x: CGFloat = 0
            while x <= w {
                let isMajor = (Int((x / spacing).rounded(.toNearestOrAwayFromZero)) % 5 == 0)
                strokeLine(from: CGPoint(x: x, y: 0),
                           to: CGPoint(x: x, y: h),
                           isMajor: isMajor)
                x += spacing
            }

            // Horizontal lines
            var y: CGFloat = 0
            while y <= h {
                let isMajor = (Int((y / spacing).rounded(.toNearestOrAwayFromZero)) % 5 == 0)
                strokeLine(from: CGPoint(x: 0, y: y),
                           to: CGPoint(x: w, y: y),
                           isMajor: isMajor)
                y += spacing
            }

            if showLabels {
                // Light coordinate labels at majors
                let labelFont = Font.system(size: 10 / max(scale, 0.0001)).weight(.regular)
                var xi: CGFloat = 0
                while xi <= w {
                    if Int((xi / spacing).rounded(.toNearestOrAwayFromZero)) % 5 == 0 {
                        context.draw(Text("\(Int(xi))").font(labelFont).foregroundColor(.secondary),
                                     at: CGPoint(x: xi + 4, y: 12))
                    }
                    xi += spacing
                }
                var yi: CGFloat = 0
                while yi <= h {
                    if Int((yi / spacing).rounded(.toNearestOrAwayFromZero)) % 5 == 0 {
                        context.draw(Text("\(Int(yi))").font(labelFont).foregroundColor(.secondary),
                                     at: CGPoint(x: 18, y: yi + 4))
                    }
                    yi += spacing
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .drawingGroup() // offscreen render for smoothness
    }
}
