//
//  Triangle.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/22/24.
//

import Foundation
import SwiftUI

//struct Triangle: Shape {
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        // Start at the bottom-left corner
//        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
//        // Draw line to the top-center
//        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
//        // Draw line to the bottom-right
//        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
//        // Draw line to close the path (back to bottom-left)
//        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
//        return path
//    }
//}

struct ResizableTriangle: View {
    @State private var point1 = CGPoint(x: 150, y: 100)
    @State private var point2 = CGPoint(x: 100, y: 200)
    @State private var point3 = CGPoint(x: 200, y: 200)

    var body: some View {
        ZStack {
            CustomTriangleShape(point1: point1, point2: point2, point3: point3)
                .stroke(lineWidth: 2)
                .fill(Color.green.opacity(0.3))
            
            draggableCorner(at: $point1)
            draggableCorner(at: $point2)
            draggableCorner(at: $point3)
        }
    }

    private func draggableCorner(at position: Binding<CGPoint>) -> some View {
        Circle()
            .frame(width: 30, height: 30)
            .foregroundColor(.green)
            .position(position.wrappedValue)
            .gesture(DragGesture().onChanged { value in
                position.wrappedValue = value.location
            })
    }
}

struct CustomTriangleShape: Shape {
    var point1: CGPoint
    var point2: CGPoint
    var point3: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.closeSubpath()

        return path
    }
}

struct ResizableTriangle_Previews: PreviewProvider {
    static var previews: some View {
        ResizableTriangle()
    }
}
