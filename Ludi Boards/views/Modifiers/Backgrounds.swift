//
//  Backgrounds.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/4/24.
//

import Foundation
import SwiftUI


// 3. Create the Modifier Extension
extension View {
    func solBackground() -> some View {
        self.modifier(SOLBackgroundModifier())
    }
}


// 1. Define the ViewModifier
struct SOLBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(getBackgroundGradient(colorScheme))
                    .shadow(radius: 5)
            )
    }

    
}
