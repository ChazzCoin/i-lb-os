//
//  Triangle.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/22/24.
//

import Foundation
import SwiftUI

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
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



struct TriangleView_Previews: PreviewProvider {
    static var previews: some View {
        Triangle()
    }
}
