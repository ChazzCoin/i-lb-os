//
//  CoreMods.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/13/23.
//

import Foundation
import SwiftUI

public extension View {
    
    func isEnabled(isEnabled: Bool) -> some View {
        self.modifier(CoreButtonModifier(isEnabled: isEnabled))
    }
    
  
}

public func getBackgroundColor(_ scheme: ColorScheme) -> Color {
    switch scheme {
        case .light:
            // Use a color suitable for light mode
            return Color.white.opacity(0.8)
        case .dark:
            // Use a color suitable for dark mode
            return Color.black.opacity(0.8)
        @unknown default:
            // Fallback for future color schemes
            return Color.gray.opacity(0.8)
        }
}

public func getTextColor(_ scheme: ColorScheme) -> Color {
    switch scheme {
        case .dark:
            // Use a color suitable for light mode
            return .black
        case .light:
            // Use a color suitable for dark mode
            return .white
        @unknown default:
            // Fallback for future color schemes
            return Color.black
    }
}

public func getTextColorOnBackground(_ scheme: ColorScheme) -> Color {
    switch scheme {
        case .light:
            // Use a color suitable for light mode
            return .black
        case .dark:
            // Use a color suitable for dark mode
            return .white
        @unknown default:
            // Fallback for future color schemes
            return Color.black
    }
}

public func getForegroundGradient(_ scheme: ColorScheme) -> LinearGradient {
    switch scheme {
        case .dark:
            // Use a color suitable for light mode
        return getBackgroundLightGradient()
        case .light:
            // Use a color suitable for dark mode
            return getBackgroundDarkGradient()
        @unknown default:
            // Fallback for future color schemes
            return LinearGradient(gradient: Gradient(colors: [Color(hex: "#D7E8FA"), Color(hex: "#EAD1DC")]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }
}

public func getBackgroundGradient(_ scheme: ColorScheme) -> LinearGradient {
    switch scheme {
        case .light:
            // Use a color suitable for light mode
        return getBackgroundLightGradient()
        case .dark:
            // Use a color suitable for dark mode
            return getBackgroundDarkGradient()
        @unknown default:
            // Fallback for future color schemes
            return LinearGradient(gradient: Gradient(colors: [Color(hex: "#D7E8FA"), Color(hex: "#EAD1DC")]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }
}

public func getPrimaryGradient() -> LinearGradient {
    return LinearGradient(gradient: Gradient(colors: [Color(hex: "#3E7167"), Color(hex: "#5A8D80"), Color(hex: "#48756E")]), startPoint: .topLeading, endPoint: .bottomTrailing)
}

public func getBackgroundLightGradient() -> LinearGradient {
    return LinearGradient(gradient: Gradient(colors: [Color(hex: "#FFFFFF"), Color(hex: "#F0F0F0"), Color(hex: "#E0E0E0")]), startPoint: .topLeading, endPoint: .bottomTrailing)
}

public func getBackgroundDarkGradient() -> LinearGradient {
    return LinearGradient(gradient: Gradient(colors: [Color(hex: "#3E7167"), Color(hex: "#5A8D80"), Color(hex: "#48756E")]), startPoint: .topLeading, endPoint: .bottomTrailing)
}

public func getForegroundColor(_ scheme: ColorScheme) -> Color {
    switch scheme {
        case .dark:
            // Use a color suitable for light mode
            return Color.white.opacity(0.8)
        case .light:
            // Use a color suitable for dark mode
            return Color.black.opacity(0.8)
        @unknown default:
            // Fallback for future color schemes
            return Color.gray.opacity(0.8)
        }
}

public func getFontColor(_ scheme: ColorScheme) -> Color {
    switch scheme {
        case .dark:
            // Use a color suitable for light mode
            return Color.white
        case .light:
            // Use a color suitable for dark mode
            return Color.black
        @unknown default:
            // Fallback for future color schemes
            return Color.gray
        }
}

public struct CoreButtonModifier: ViewModifier {
    var isEnabled: Bool

    public func body(content: Content) -> some View {
        content
            .opacity(isEnabled ? 1 : 0.5) // Change opacity when disabled
            .disabled(!isEnabled) // Disable button interaction
    }
}

public func simpleSuccessHaptic() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
}

public func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .heavy) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}



// Helper view to simulate Box from Compose
public struct BoxView<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack {
            content
        }
        // Add your custom modifiers here
    }
}
