//
//  Triangle.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/22/24.
//

import Foundation
import SwiftUI
import CoreEngine


struct ResizableTriangle: View {
    @State private var point1 = CGPoint(x: 150, y: 100)
    @State private var point2 = CGPoint(x: 100, y: 200)
    @State private var point3 = CGPoint(x: 200, y: 200)

    var body: some View {
        ZStack {
            CustomTriangleShape(point1: point1, point2: point2, point3: point3)
                .stroke(lineWidth: 50)
                .fill(Color.green.opacity(0.3))
            
            DragAnchor(at: $point1)
            DragAnchor(at: $point2)
            DragAnchor(at: $point3)

        }
    }

    private func draggableCorner(at position: Binding<CGPoint>) -> some View {
        Circle()
            .frame(width: 200, height: 200)
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
