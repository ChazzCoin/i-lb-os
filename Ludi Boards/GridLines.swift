//
//  GridLines.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/10/23.
//

import Foundation
import SwiftUI

struct DrawGridLines: View {
    // Access the shared CanvasEngineGlobal instance
//    @ObservedObject var canvasGlobals = CanvasEngineGlobal.shared
    // Define the maximum allowed dimensions
    private let maxDimension: CGFloat = 5000
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                
                // Clamp the canvas width and height to the maximum allowed dimension
                let clampedCanvasWidth = min(maxDimension, CGFloat(5000))
                let clampedCanvasHeight = min(maxDimension, CGFloat(5000))
                
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
