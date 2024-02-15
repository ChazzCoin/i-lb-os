//
//  Backgrounds.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/4/24.
//

import Foundation
import SwiftUI


extension View {
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


struct SOLBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
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
struct SOLBackgroundDarkModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(getBackgroundDarkGradient())
//                    .shadow(radius: 5)
            )
    }
}
struct SOLBackgroundPrimaryModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(getPrimaryGradient())
                    .shadow(radius: 5)
            )
    }
}
