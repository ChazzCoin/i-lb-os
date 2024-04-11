//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/9/24.
//

import Foundation
import SwiftUI


public extension View {
    
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
    
}

public struct TapAnimationModifier: ViewModifier {
    public let action: () -> Void
    public let isEnabled: Bool
    @State public var isPressed = false
    
    public init(action: @escaping () -> Void, isEnabled: Bool, isPressed: Bool = false) {
        self.action = action
        self.isEnabled = isEnabled
        self.isPressed = isPressed
    }

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
    public let scale: CGFloat
    public let duration: Double
    public let completion: () -> Void

    @State public var isAnimating = false

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
    public var minimumDuration: Double
    public var onLongPress: () -> Void
    
    public init(minimumDuration: Double, onLongPress: @escaping () -> Void) {
        self.minimumDuration = minimumDuration
        self.onLongPress = onLongPress
    }

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
