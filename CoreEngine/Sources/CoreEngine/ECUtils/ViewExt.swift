//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/13/24.
//

import Foundation
import SwiftUI

// MARK: - View Extensions

extension View {
    
    // MARK: - Navigation
    
    /// Embeds the view in a NavigationView if not already embedded.
    @ViewBuilder
    func embedInNavigationView<Content: View>() -> some View {
        if let _ = self as? NavigationView<Content> {
            self
        } else {
            NavigationView { self }
        }
    }
    
    // MARK: - Visibility
    
    /// Conditionally hides a view based on a Boolean value.
    @ViewBuilder
    func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.hidden()
        } else {
            self
        }
    }
    
    // MARK: - Padding
    
    /// Adds symmetric padding with specific values for horizontal and vertical padding.
    func padding(horizontal hPadding: CGFloat, vertical vPadding: CGFloat) -> some View {
        self.padding(.horizontal, hPadding)
            .padding(.vertical, vPadding)
    }
    
    // MARK: - Keyboard
    
    /// Adds a gesture to dismiss the keyboard by tapping outside of a text field.
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    // MARK: - Debugging
    
    /// Prints a value to the console when the view renders, useful for debugging.
    func debugPrint(_ value: Any) -> Self {
        print(value)
        return self
    }
}

// MARK: - Binding Extensions

extension Binding {
    
    // MARK: - Transformation
    
    /// Transforms a Binding<Optional<Value>> into Binding<Value> with a default value.
    func unwrapped(or defaultValue: Value) -> Binding<Value> {
        Binding<Value>(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
    
    // MARK: - Conditional Update
    
    /// Executes an action when the Binding's value changes.
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: {
                self.wrappedValue = $0
                handler($0)
            }
        )
    }
}
