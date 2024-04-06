//
//  SolIconTextButton.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/7/24.
//

import Foundation
import SwiftUI
import CoreEngine

struct SolIconTextButton: View {
    var title: String
    var systemName: String
    var onTap: () -> Void
    
    @State var fontColor: Color? = nil
    @State var width = 50.0
    @State var height = 50.0
    @Environment(\.colorScheme) var colorScheme
    
    init(title: String, systemName: String, onTap: @escaping () -> Void) {
        self.title = title
        self.systemName = systemName
        self.onTap = onTap
    }
    
    init(title: String, systemName: String, width: Double, height: Double, onTap: @escaping () -> Void) {
        self.title = title
        self.systemName = systemName
        self.onTap = onTap
        self.width = width
        self.height = height
    }
    
    init(title: String, systemName: String, width: Double, height: Double, fontColor: Color, onTap: @escaping () -> Void) {
        self.title = title
        self.systemName = systemName
        self.onTap = onTap
        self.fontColor = fontColor
        self.width = width
        self.height = height
    }
    
    var body: some View {
        VStack {
            VStack {
                Image(systemName: systemName)
                    .resizable()
                    .frame(width: width * 0.4, height: height * 0.4)
                    .foregroundColor(fontColor != nil ? fontColor : getForegroundColor(colorScheme))
            }
            .frame(width: width * 0.8, height: height * 0.8)
            .solBackgroundPrimaryGradient()
            .onTapAnimation {
               onTap()
            }
            MenuBarText(title, color: getTextColorOnBackground(colorScheme))
        }
    }
}


struct SOLCON: View {
    var title: String
    var systemName: String
    var alertTitle: String
    var alertMessage: String
    var isConfirmEnabled: Bool
    var onTap: () -> Void
    
    @State var icon: SolIcon = SolIcon.save
    @State var fontColor: Color? = nil
    @State var width = 50.0
    @State var height = 50.0
    @State private var alertIsShowing = false
    @Environment(\.colorScheme) var colorScheme
    
    init(icon: SolIcon, isConfirmEnabled: Bool = true, onTap: @escaping () -> Void) {
        self.title = icon.title
        self.systemName = icon.icon
        self.alertTitle = icon.title
        self.alertMessage = icon.confirmMessage
        self.isConfirmEnabled = isConfirmEnabled
        self.onTap = onTap
    }
    
    init(icon: SolIcon, title: String, isConfirmEnabled: Bool = true, onTap: @escaping () -> Void) {
        self.title = title
        self.systemName = icon.icon
        self.alertTitle = icon.title
        self.alertMessage = icon.confirmMessage
        self.isConfirmEnabled = isConfirmEnabled
        self.onTap = onTap
    }
    
    var body: some View {
        VStack {
            VStack {
                Image(systemName: systemName)
                    .resizable()
                    .frame(width: width * 0.4, height: height * 0.4)
                    .foregroundColor(fontColor != nil ? fontColor : getForegroundColor(colorScheme))
            }
            .frame(width: width * 0.8, height: height * 0.8)
            .solBackgroundPrimaryGradient()
            .onTapAnimation {
                if self.isConfirmEnabled {
                    alertIsShowing = true
                } else {
                    onTap()
                }
            }
            MenuBarText(title, color: getTextColorOnBackground(colorScheme))
        }
        .alert(self.alertTitle, isPresented: $alertIsShowing) {
            Button("Cancel", role: .cancel) {
                alertIsShowing = false
            }
            Button("OK", role: .none) {
                onTap()
                alertIsShowing = false
            }
        } message: {
            Text(self.alertMessage)
        }
    }
}
