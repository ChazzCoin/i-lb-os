//
//  StandardButton.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/2/23.
//

import Foundation
import SwiftUI

public struct CoreButton: View {
    public let title: String
    public let action: () -> Void
    public var isEnabled: Bool = true
    @State public var isButtonPressed = false
    
    public init(title: String, action: @escaping () -> Void, isEnabled: Bool, isButtonPressed: Bool = false) {
        self.title = title
        self.action = action
        self.isEnabled = isEnabled
        self.isButtonPressed = isButtonPressed
    }

    public var body: some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isEnabled ? Color.blue : Color.gray) // Background color changes when disabled
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(isButtonPressed ? 0.95 : 1.0)
            .animation(.spring(), value: isButtonPressed)
            .padding(/*@START_MENU_TOKEN@*/EdgeInsets()/*@END_MENU_TOKEN@*/)
            .isEnabled(isEnabled: isEnabled)
            .onTapAnimation {
                if isEnabled {
                    action()
                }
            }
    }
}

public struct CoreConfirmButton: View {
    public let title: String
    public let message: String
    public let action: () -> Void
    public var isEnabled: Bool = true
    @State public var isButtonPressed = false
    @State public var sheetIsShowing = false
    
    public init(title: String, message: String, action: @escaping () -> Void, isEnabled: Bool, isButtonPressed: Bool = false, sheetIsShowing: Bool = false) {
        self.title = title
        self.message = message
        self.action = action
        self.isEnabled = isEnabled
        self.isButtonPressed = isButtonPressed
        self.sheetIsShowing = sheetIsShowing
    }

    public var body: some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isEnabled ? Color.blue : Color.gray) // Background color changes when disabled
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(isButtonPressed ? 0.95 : 1.0)
            .animation(.spring(), value: isButtonPressed)
            .isEnabled(isEnabled: isEnabled)
            .onTapAnimation(enabled: isEnabled) {
                if isEnabled {
                    sheetIsShowing = true
                }
            }
            .alert(title, isPresented: $sheetIsShowing) {
                Button("Cancel", role: .cancel) {
                    sheetIsShowing = false
                }
                Button("OK", role: .none) {
                    sheetIsShowing = false
                    action()
                }
            } message: {
                Text(message)
            }
    }
}


public struct CoreIconButton: View {
    public var systemName: String
    public var onTap: () -> Void
    
    @State public var fontColor: Color? = nil
    @State public var width = 40.0
    @State public var height = 40.0
    @State public var sheetIsShowing = false
    
    @Environment(\.colorScheme) public var colorScheme
    
    public init(systemName: String, onTap: @escaping () -> Void) {
        self.systemName = systemName
        self.onTap = onTap
    }
    
    public init(systemName: String, width: Double, height: Double, onTap: @escaping () -> Void) {
        self.systemName = systemName
        self.onTap = onTap
        self.width = width
        self.height = height
    }
    
    public init(systemName: String, width: Double, height: Double, fontColor: Color, onTap: @escaping () -> Void) {
        self.systemName = systemName
        self.onTap = onTap
        self.fontColor = fontColor
        self.width = width
        self.height = height
    }
    
    public var body: some View {
        VStack {
            Image(systemName: systemName)
                .resizable()
                .frame(width: width/2, height: height/2)
                .foregroundColor(fontColor != nil ? fontColor : getForegroundColor(colorScheme))
        }
        .frame(width: width, height: height)
        .solBackgroundPrimaryGradient()
        .onTapAnimation {
           onTap()
        }
    }
}


public struct CoreIconConfirmButton: View {
    public var systemName: String
    let title: String
    let message: String
    public var onTap: () -> Void
    public var isEnabled: Bool = true
    @State public var sheetIsShowing = false
    
    @Environment(\.colorScheme) public var colorScheme
    
    @State public var width = 40.0
    @State public var height = 40.0
    
    public init(systemName: String, title: String, message: String, onTap: @escaping () -> Void) {
        self.systemName = systemName
        self.title = title
        self.message = message
        self.onTap = onTap
    }
    
    public init(systemName: String, title: String, message: String, width: Double, height: Double, onTap: @escaping () -> Void) {
        self.systemName = systemName
        self.title = title
        self.message = message
        self.onTap = onTap
        self.width = width
        self.height = height
    }
    
    public var body: some View {
        VStack {
            Image(systemName: systemName)
                .resizable()
                .frame(width: width/2, height: height/2)
                .foregroundColor(getForegroundColor(colorScheme))
        }
        .frame(width: width, height: height)
        .solBackgroundPrimaryGradient()
//        .isEnabled(isEnabled: isEnabled)
        .onTapAnimation(enabled: isEnabled) {
            if isEnabled {
                sheetIsShowing = true
            }
        }
        .alert(title, isPresented: $sheetIsShowing) {
            Button("Cancel", role: .cancel) {
                sheetIsShowing = false
            }
            Button("OK", role: .none) {
                sheetIsShowing = false
                onTap()
            }
        } message: {
            Text(message)
        }
    }
}

//#Preview {
//    SolIconButton(systemName: MenuBarProvider.trash.tool.image) {
//
//    }
//}
