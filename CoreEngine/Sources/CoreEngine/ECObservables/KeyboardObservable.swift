//
//  KeyboardListener.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/5/23.
//

import Foundation
import SwiftUI
import Combine


public extension View {
    func keyboardListener(onAppear: @escaping (CGFloat) -> Void, onDisappear: @escaping (CGFloat) -> Void) -> some View {
        self.modifier(KeyboardListenerModifier(onKeyboardAppear: onAppear, onKeyboardDisappear: onDisappear))
    }
}

public class KeyboardResponder: ObservableObject {
    @Published public var isKeyboardVisible: Bool = false
    public var cancellables: Set<AnyCancellable> = []

    public init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { _ in self.isKeyboardVisible = true }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { _ in self.isKeyboardVisible = false }
            .store(in: &cancellables)
    }
    
    public func safeHideKeyboard() {
        if self.isKeyboardVisible {
            hideKeyboard()
        }
    }
}



public struct KeyboardListenerModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    @State var onKeyboardAppear: (CGFloat) -> Void
    @State var onKeyboardDisappear: (CGFloat) -> Void

    @State private var keyboardAppear: AnyCancellable?
    @State private var keyboardDisappear: AnyCancellable?

    public func body(content: Content) -> some View {
        content
//            .padding(.bottom, keyboardHeight)
//            .offset(y: -keyboardHeight/2)
            .onAppear {
                self.registerForKeyboardNotifications()
            }
            .onDisappear {
                self.unregisterFromKeyboardNotifications()
            }
    }

    public func registerForKeyboardNotifications() {
        self.keyboardAppear = NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)
            .compactMap { notification in
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            }
            .map { $0.height }
            .sink { height in
                self.keyboardHeight = height
                self.onKeyboardAppear(height)
            }

        self.keyboardDisappear = NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)
            .compactMap { notification in
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            }
            .map { $0.height }
            .sink { height in
                self.onKeyboardDisappear(height)
            }
    }

    public func unregisterFromKeyboardNotifications() {
        keyboardAppear?.cancel()
        keyboardDisappear?.cancel()
    }
}
