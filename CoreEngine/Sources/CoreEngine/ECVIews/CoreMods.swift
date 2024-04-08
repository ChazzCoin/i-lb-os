//
//  CoreMods.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/13/23.
//

import Foundation
import SwiftUI

public extension View {
    
    func solEnabled(isEnabled: Bool) -> some View {
        self.modifier(SolButtonModifier(isEnabled: isEnabled))
    }
    
    func onTap(perform action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            hapticFeedback()
            // Perform the custom action
            action()
        }
    }
    func onTapAnimation(enabled: Bool = true, perform action: @escaping () -> Void) -> some View {
        self.modifier(TapAnimationModifier(action: action, isEnabled: enabled))
    }
    
    func onDoubleTap(scale: CGFloat = 2.0, duration: Double = 0.5, completion: @escaping () -> Void = {}) -> some View {
        modifier(DoubleTapExplodeModifier(scale: scale, duration: duration, completion: completion))
    }
    
    func onLongPress(minimumDuration: Double = 0.5, perform action: @escaping () -> Void) -> some View {
        modifier(LongPressModifier(minimumDuration: minimumDuration, onLongPress: action))
    }
    
    // Method to set the position of the view based on a specified ScreenArea
    func position(using gps: GlobalPositioningSystem, at area: ScreenArea, offsetX: CGFloat = 0, offsetY: CGFloat = 0) -> some View {
        self.position(gps.getCoordinate(for: area, offsetX: offsetX, offsetY: offsetY))
    }

    // Method to set the offset of the view based on a specified ScreenArea
    func offset(using gps: GlobalPositioningSystem, for area: ScreenArea) -> some View {
        let offsetSize = gps.getOffset(for: area)
        return self.offset(x: offsetSize.width, y: offsetSize.height)
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

public struct SolButtonModifier: ViewModifier {
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

public struct TapAnimationModifier: ViewModifier {
    let action: () -> Void
    let isEnabled: Bool
    @State private var isPressed = false

    public func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.90 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .onTapGesture {
                if !isEnabled {return}
                hapticFeedback()
                self.isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.isPressed = false
                    self.action()
                }
            }
    }
}
public struct DoubleTapExplodeModifier: ViewModifier {
    let scale: CGFloat
    let duration: Double
    let completion: () -> Void

    @State private var isAnimating = false

    public func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? scale : 1.0)
            .animation(.easeInOut(duration: duration), value: isAnimating)
            .onTapGesture(count: 2) {
                isAnimating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    isAnimating = false
                    completion()
                }
            }
    }
}

// 1. Define the LongPressModifier
public struct LongPressModifier: ViewModifier {
    var minimumDuration: Double
    var onLongPress: () -> Void

    public func body(content: Content) -> some View {
        content
            // 2. Add the gesture to the modifier
            .onLongPressGesture(minimumDuration: minimumDuration, pressing: { isPressing in
                if isPressing {
                    // Handle the gesture start (optional)
                } else {
                    // Handle the gesture end (optional)
                }
            }, perform: onLongPress)
    }
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
