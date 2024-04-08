//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/8/24.
//

import Foundation
import SwiftUI


public struct Triangle: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        // Start at the bottom-left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        // Draw line to the top-center
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        // Draw line to the bottom-right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        // Draw line to close the path (back to bottom-left)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}
