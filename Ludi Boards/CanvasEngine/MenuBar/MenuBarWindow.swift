//
//  MenuBarWindow.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI

struct MenuBarStatic: View {
    var onClick: () -> Void
    @State private var showIcons = false
    @State private var iconStates = Array(repeating: false, count: 9)
    @Environment(\.colorScheme) var colorScheme
    @State private var isLocked = false
    @State private var lifeColor = Color.black
    
    func setColorScheme() { lifeColor = foregroundColorForScheme(colorScheme) }

    let icons = [
        MenuBarProvider.info,
        MenuBarProvider.lock,
        MenuBarProvider.toolbox,
        MenuBarProvider.navHome,
        MenuBarProvider.boardDetails,
        MenuBarProvider.boardCreate,
        MenuBarProvider.chat,
        MenuBarProvider.profile
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            // Toggle Button
            VStack {
                Image(systemName: MenuBarProvider.menuBar.tool.image)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(lifeColor)
                    .onAppear() {
                        setColorScheme()
                    }
            }
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(backgroundColorForScheme(colorScheme))
                    .shadow(radius: 5)
            )
            .onTapAnimation {
                showIcons.toggle()
                animateIcons()
                
                if !showIcons {
                    delayThenMain(1) {
                        onClick()
                    }
                } else {
                    onClick()
                }
                
            }
            // Icons
            ForEach(0..<icons.count, id: \.self) { index in
                if iconStates[index] {
                    MenuButtonIcon(icon: icons[index])
                        .transition(.opacity)
                }
            }
        }.background(Color.clear)
    }
    
    private func animateIcons() {
        if showIcons {
            // Show icons one by one
            for index in 0..<icons.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                    withAnimation {
                        iconStates[index] = true
                    }
                }
            }
        } else {
            // Hide icons one by one, in reverse order
            for index in (0..<icons.count).reversed() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(icons.count - index) * 0.1) {
                    withAnimation {
                        iconStates[index] = false
                    }
                }
            }
        }
    }
}
