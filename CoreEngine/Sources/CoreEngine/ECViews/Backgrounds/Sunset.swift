//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/18/24.
//

import Foundation
import SwiftUI

public struct SunsetGradientView: View {
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background gradient for the sunset
            LinearGradient(gradient: Gradient(colors: [Color.orange, Color.yellow, Color.pink]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            // Sun
            Circle()
                .fill(Color.yellow)
                .frame(width: 100, height: 100)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 3)

            // Clouds
            CloudShaper()
                .fill(Color.white.opacity(0.3))
                .frame(width: 200, height: 100)
                .position(x: UIScreen.main.bounds.width * 0.8, y: UIScreen.main.bounds.height * 0.2)

            CloudShaper()
                .fill(Color.white.opacity(0.3))
                .frame(width: 150, height: 80)
                .position(x: UIScreen.main.bounds.width * 0.3, y: UIScreen.main.bounds.height * 0.25)

        }
    }
}

public struct CloudShaper: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                      control1: CGPoint(x: rect.minX + rect.width * 0.3, y: rect.minY),
                      control2: CGPoint(x: rect.minX + rect.width * 0.7, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
