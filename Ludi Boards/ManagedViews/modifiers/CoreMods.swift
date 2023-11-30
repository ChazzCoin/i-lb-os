//
//  CoreMods.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/13/23.
//

import Foundation
import SwiftUI

extension View {
    func dragger() -> some View {
        self.modifier(lbDragger())
    }
    
    func enableMVT(viewId: String="") -> some View {
        self.modifier(enableManagedViewTool(viewId: viewId, boardId: "boardEngine-1"))
    }
    
    func onTap(perform action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            hapticFeedback()
            // Perform the custom action
            action()
        }
    }
    func onTapAnimation(perform action: @escaping () -> Void) -> some View {
        self.modifier(TapAnimationModifier(action: action))
    }
}

func backgroundColorForScheme(_ scheme: ColorScheme) -> Color {
    switch scheme {
        case .light:
            // Use a color suitable for light mode
            return Color.black.opacity(0.8)
        case .dark:
            // Use a color suitable for dark mode
            return Color.white.opacity(0.8)
        @unknown default:
            // Fallback for future color schemes
            return Color.gray.opacity(0.8)
        }
}

func foregroundColorForScheme(_ scheme: ColorScheme) -> Color {
    switch scheme {
        case .dark:
            // Use a color suitable for light mode
            return Color.black.opacity(0.8)
        case .light:
            // Use a color suitable for dark mode
            return Color.white.opacity(0.8)
        @unknown default:
            // Fallback for future color schemes
            return Color.gray.opacity(0.8)
        }
}

func simpleSuccessHaptic() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
}

func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .heavy) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}

struct TapAnimationModifier: ViewModifier {
    let action: () -> Void
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.75 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
            .onTapGesture {
                hapticFeedback()
                self.isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.isPressed = false
                    self.action()
                }
            }
    }
}
// Helper view to simulate Box from Compose
struct BoxView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            content
        }
        // Add your custom modifiers here
    }
}
