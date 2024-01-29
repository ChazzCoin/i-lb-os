//
//  Square.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/26/24.
//

import Foundation
import SwiftUI


struct ResizableBox: View {
    @State private var topLeft = CGPoint(x: 100, y: 100)
    @State private var topRight = CGPoint(x: 200, y: 100)
    @State private var bottomLeft = CGPoint(x: 100, y: 200)
    @State private var bottomRight = CGPoint(x: 200, y: 200)
    @State private var lineWidth = 2.0

    var body: some View {
        ZStack {
            SquareShape(
                topLeft: topLeft,
                topRight: topRight,
                bottomLeft: bottomLeft,
                bottomRight: bottomRight
            )
            .stroke(lineWidth: lineWidth)
            .fill(Color.blue.opacity(0.3))
            
            draggableCorner(at: $topLeft)
            draggableCorner(at: $topRight)
            draggableCorner(at: $bottomLeft)
            draggableCorner(at: $bottomRight)
        }
    }

    private func draggableCorner(at position: Binding<CGPoint>) -> some View {
        Circle()
            .frame(width: 30, height: 30)
            .foregroundColor(.blue)
            .position(position.wrappedValue)
            .gesture(DragGesture().onChanged { value in
                position.wrappedValue = value.location
            })
    }
}


struct SquareShape: Shape {
    var topLeft: CGPoint
    var topRight: CGPoint
    var bottomLeft: CGPoint
    var bottomRight: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.closeSubpath()

        return path
    }
}


#Preview {
    ResizableBox()
}
