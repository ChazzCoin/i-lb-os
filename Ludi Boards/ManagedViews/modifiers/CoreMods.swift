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
    
    func onDoubleTap(scale: CGFloat = 2.0, duration: Double = 0.5, completion: @escaping () -> Void = {}) -> some View {
        modifier(DoubleTapExplodeModifier(scale: scale, duration: duration, completion: completion))
    }
    
//    func doubleTapExplode(scale: CGFloat = 2.0, duration: Double = 0.5, completion: @escaping () -> Void = {}) -> some View {
//       self.modifier(DoubleTapExplodeAnimationModifier(scale: scale, duration: duration, completion: completion))
//   }
    
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

//struct DoubleTapExplodeGesture: Gesture {
//    let scale: CGFloat
//    let duration: Double
//    let completion: () -> Void
//    
//    @GestureState private var isAnimating = false
//
//    var body: some Gesture {
//        TapGesture(count: 2)
//            .updating($isAnimating) { currentState, gestureState, transaction in
//                gestureState = true
//                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
//                    gestureState = false
//                    completion()
//                }
//            }
//    }
//}

//struct DoubleTapExplodeModifier: ViewModifier {
//    let scale: CGFloat
//    let duration: Double
//    let completion: () -> Void
//
//    @GestureState private var isAnimating = false
//
//    func body(content: Content) -> some View {
//        content
//            .scaleEffect(isAnimating ? scale : 1.0)
//            .animation(.easeInOut(duration: duration), value: isAnimating)
//            .gesture(
//                TapGesture(count: 2)
//                    .updating($isAnimating) { _, gestureState, _ in
//                        gestureState = true
//                        DispatchQueue.main.asyncAfter(deadline: .now() + self.duration) {
//                            gestureState = false
//                            self.completion()
//                        }
//                    }
//            )
//    }
//}

struct DoubleTapExplodeModifier: ViewModifier {
    let scale: CGFloat
    let duration: Double
    let completion: () -> Void

    @State private var isAnimating = false

    func body(content: Content) -> some View {
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
