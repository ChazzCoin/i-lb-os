//
//  SolIconButton.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/21/24.
//

import SwiftUI

struct SolIconButton: View {
    var systemName: String
    var onTap: () -> Void
    
    @State var fontColor: Color? = nil
    @State var width = 60.0
    @State var height = 60.0
    @State private var sheetIsShowing = false
    
    @Environment(\.colorScheme) var colorScheme
    
    init(systemName: String, onTap: @escaping () -> Void) {
        self.systemName = systemName
        self.onTap = onTap
    }
    
    init(systemName: String, width: Double, height: Double, onTap: @escaping () -> Void) {
        self.systemName = systemName
        self.onTap = onTap
        self.width = width
        self.height = height
    }
    
    init(systemName: String, width: Double, height: Double, fontColor: Color, onTap: @escaping () -> Void) {
        self.systemName = systemName
        self.onTap = onTap
        self.fontColor = fontColor
        self.width = width
        self.height = height
    }
    
    var body: some View {
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


struct SolIconConfirmButton: View {
    var systemName: String
    let title: String
    let message: String
    var onTap: () -> Void
    var isEnabled: Bool = true
    @State private var sheetIsShowing = false
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var width = 60.0
    @State var height = 60.0
    
    init(systemName: String, title: String, message: String, onTap: @escaping () -> Void) {
        self.systemName = systemName
        self.title = title
        self.message = message
        self.onTap = onTap
    }
    
    init(systemName: String, title: String, message: String, width: Double, height: Double, onTap: @escaping () -> Void) {
        self.systemName = systemName
        self.title = title
        self.message = message
        self.onTap = onTap
        self.width = width
        self.height = height
    }
    
    var body: some View {
        VStack {
            Image(systemName: systemName)
                .resizable()
                .frame(width: width/2, height: height/2)
                .foregroundColor(getForegroundColor(colorScheme))
        }
        .frame(width: width, height: height)
        .solBackgroundPrimaryGradient()
        .solEnabled(isEnabled: isEnabled)
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

#Preview {
    SolIconButton(systemName: MenuBarProvider.trash.tool.image) {
        
    }
}
