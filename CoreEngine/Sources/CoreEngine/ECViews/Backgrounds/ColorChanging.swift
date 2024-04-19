//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/18/24.
//

import Foundation
import SwiftUI

public struct DynamicGradientBackground: View {
    public init() {}
    // Define the initial gradient colors
    @State public var startColor = Color.blue
    @State public var endColor = Color.purple

    // Define the animation duration
    public let animationDuration: TimeInterval = 10

    // This function changes the gradient colors
    public func changeGradientColors() {
        withAnimation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
            // Change to new gradient colors
            startColor = Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1))
            endColor = Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1))
        }
    }

    public var body: some View {
        LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                changeGradientColors()
            }
    }
}
