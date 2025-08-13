//
//  GridLines.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/10/23.
//

import Foundation
import SwiftUI



struct DrawGridLinesDyna: View {
    // 🔗 External pan/zoom/rotate state
    @Binding var offset: CGPoint     // world-space pan (x,y)
    @Binding var scale: CGFloat      // zoom factor
    @Binding var rotation: Angle     // rotation of grid/canvas

    // Tunables
    var spacing: CGFloat = 100               // world units between lines
    var baseLineWidth: CGFloat = 20           // visual 1pt at scale == 1
    var color: Color = .blue
    var showLabels: Bool = true
    var minScale: CGFloat = 0.001
    var maxScale: CGFloat = 8.0
    private let maxDimension: CGFloat = 20_000

    // Gesture bookkeeping
    @State private var lastOffset: CGPoint = .zero
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geo in
            let drag = DragGesture()
                .onChanged { g in
                    // Translate in world space (divide by scale to avoid “accelerating” pan while zoomed in)
                    let dx = g.translation.width  / max(scale, 0.0001)
                    let dy = g.translation.height / max(scale, 0.0001)
                    offset = CGPoint(x: lastOffset.x + dx, y: lastOffset.y + dy)
                }
                .onEnded { _ in
                    lastOffset = offset
                }

            let pinch = MagnificationGesture()
                .onChanged { v in
                    // Relative zoom around the current focus (simple version)
                    let delta = v / lastScale
                    scale = (scale * delta)
                    lastScale = v
                }
                .onEnded { _ in
                    lastScale = 1.0
                }

            Canvas { ctx, size in
                // Clamp drawing extent (world space)
                let worldW = min(size.width,  maxDimension)
                let worldH = min(size.height, maxDimension)

                // Keep strokes visually constant by counter-scaling line width
                let lineWidth = max(0.5, baseLineWidth / max(scale, 0.0001))
                let majorEvery = 5

                // Apply world transform (pan → rotate → scale)
                ctx.translateBy(x: offset.x, y: offset.y)
//                ctx.rotate(by: rotation)
                ctx.scaleBy(x: scale, y: scale)

                // === Grid lines (drawn in world space) ===
                func strokeLine(from: CGPoint, to: CGPoint, major: Bool) {
                    var p = Path()
                    p.move(to: from)
                    p.addLine(to: to)
                    ctx.stroke(
                        p,
                        with: .color(major ? color.opacity(0.7) : color),
                        lineWidth: major ? lineWidth * 1.25 : lineWidth
                    )
                }

                // Vertical lines
                var x: CGFloat = 0
                while x <= worldW {
                    let idx = Int(round(x / spacing))
                    let isMajor = idx % majorEvery == 0
                    strokeLine(from: CGPoint(x: x, y: 0), to: CGPoint(x: x, y: worldH), major: isMajor)
                    x += spacing
                }

                // Horizontal lines
                var y: CGFloat = 0
                while y <= worldH {
                    let idy = Int(round(y / spacing))
                    let isMajor = idy % majorEvery == 0
                    strokeLine(from: CGPoint(x: 0, y: y), to: CGPoint(x: worldW, y: y), major: isMajor)
                    y += spacing
                }

                // === Labels (keep ~constant on screen by inversely scaling font size) ===
                if showLabels {
                    let font = Font.system(size: 10 / max(scale, 0.0001))
                    var lx: CGFloat = 0
                    while lx <= worldW {
                        let idx = Int(round(lx / spacing))
                        if idx % majorEvery == 0 {
                            ctx.draw(Text("\(Int(lx))").font(font).foregroundColor(.secondary),
                                     at: CGPoint(x: lx + 4, y: 12))
                        }
                        lx += spacing
                    }
                    var ly: CGFloat = 0
                    while ly <= worldH {
                        let idy = Int(round(ly / spacing))
                        if idy % majorEvery == 0 {
                            ctx.draw(Text("\(Int(ly))").font(font).foregroundColor(.secondary),
                                     at: CGPoint(x: 18, y: ly + 4))
                        }
                        ly += spacing
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .contentShape(Rectangle()) // bigger hit area for gestures
            .gesture(drag.simultaneously(with: pinch))
            .allowsHitTesting(true)
            .drawingGroup() // smoother rendering
            .accessibilityHidden(true)
            .onAppear {
                // Initialize lastOffset so the first drag is relative to current binding
                lastOffset = offset
            }
        }
    }
}

// Small helper
private extension Comparable {
    func clamped(_ limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}


struct DrawGridLines: View {

    private let maxDimension: CGFloat = 20000
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                
                // Clamp the canvas width and height to the maximum allowed dimension
                let clampedCanvasWidth = min(maxDimension, CGFloat(20000))
                let clampedCanvasHeight = min(maxDimension, CGFloat(20000))
                
                // Use the clamped dimensions for drawing
                let maxWidth = min(size.width, clampedCanvasWidth)
                let maxHeight = min(size.height, clampedCanvasHeight)
                
                let lineSpacing: CGFloat = 100
                let labelSpacing: CGFloat = 100
                let gridColor = Color.blue
                let gridStrokeWidth: CGFloat = 1
                var label: String
                
                // Draw grid lines
                for i in stride(from: 0, through: maxWidth, by: lineSpacing) {
                    context.stroke(
                        Path { path in
                            path.move(to: CGPoint(x: i, y: 0))
                            path.addLine(to: CGPoint(x: i, y: maxHeight))
                        },
                        with: .color(gridColor),
                        lineWidth: gridStrokeWidth
                    )
                }
                
                for i in stride(from: 0, through: maxHeight, by: lineSpacing) {
                    context.stroke(
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: i))
                            path.addLine(to: CGPoint(x: maxWidth, y: i))
                        },
                        with: .color(gridColor),
                        lineWidth: gridStrokeWidth
                    )
                }
                
                // Draw pixel labels on top
                for i in stride(from: 0, through: maxWidth, by: labelSpacing) {
                    label = "\(i)"
                    context.draw(Text(label), at: CGPoint(x: i, y: 20))
                }
                
                // Draw pixel labels on the left
                for i in stride(from: 0, through: maxHeight, by: labelSpacing) {
                    label = "\(i)"
                    context.draw(Text(label), at: CGPoint(x: 20, y: i))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
