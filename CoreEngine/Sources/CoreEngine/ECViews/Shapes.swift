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

public struct ThoughtBubble: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addRoundedRect(in: CGRect(x: 0, y: 0, width: rect.width, height: rect.height), cornerSize: CGSize(width: 30, height: 30))
        path.addRoundedRect(in: CGRect(x: rect.width * 0.6, y: rect.height, width: 20, height: 20), cornerSize: CGSize(width: 10, height: 10))
        
        return path
    }
}
