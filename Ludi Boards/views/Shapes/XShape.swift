//
//  XShape.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/26/24.
//

import Foundation
import SwiftUI

struct XShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Drawing the first line of the X
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))

        // Drawing the second line of the X
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        return path
    }
}

struct StylishXShape: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                // Drawing the X
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                path.move(to: CGPoint(x: geometry.size.width, y: 0))
                path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
            }
            .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
            .foregroundColor(.clear)
            .overlay(
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .shadow(color: .gray, radius: 10, x: 5, y: 5)
            .rotationEffect(.degrees(10))
        }
    }
}

#Preview {
    StylishXShape()
}
