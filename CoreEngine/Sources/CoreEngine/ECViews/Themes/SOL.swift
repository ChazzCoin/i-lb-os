//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/7/24.
//

import Foundation
import SwiftUI


public extension View {
    func solBackground() -> some View {
        self.modifier(SOLBackgroundModifier())
    }
    func solBackgroundDark() -> some View {
        self.modifier(SOLBackgroundDarkModifier())
    }
    func solBackgroundPrimaryGradient() -> some View {
        self.modifier(SOLBackgroundPrimaryModifier())
    }
}


public struct SOLBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(getBackgroundGradient(colorScheme))
            )
            .overlay(
               RoundedRectangle(cornerRadius: 15)
                   .stroke(getForegroundGradient(colorScheme), lineWidth: 1) // Adjust lineWidth as needed
           )
    }
}
public struct SOLBackgroundDarkModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(getBackgroundDarkGradient())
//                    .shadow(radius: 5)
            )
    }
}
public struct SOLBackgroundPrimaryModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(getPrimaryGradient())
                    .shadow(radius: 5)
            )
    }
}
