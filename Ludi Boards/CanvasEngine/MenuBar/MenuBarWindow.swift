//
//  MenuBarWindow.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI

struct MenuBarWindow<Content>: View where Content: View {
    let items: [() -> Content]
    @Environment(\.colorScheme) var colorScheme
    @State private var isEnabled = true // Replace with your actual condition
    @State private var overrideColor = false // Replace with your actual condition
    @State private var color: Color = .blue // Replace with your actual color
    
    @ObservedObject private var gps = GlobalPositioningSystem()
    @State private var position = CGPoint(x: 100, y: 300)
    @State private var screen = UIScreen.main
    
    @State private var offset = CGSize.zero // Initial offset
    @GestureState private var dragState = CGSize.zero // Temporary state during a drag


    var body: some View {
        
        VStack(spacing: 8) {
            Spacer().frame(height: 24)
            ForEach(0..<items.count, id: \.self) { index in
                self.items[index]()
                    .padding(3)
            }
            Spacer().frame(height: 16)
        }
        .frame(maxWidth: 55, maxHeight: 75 * Double(items.count))
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(backgroundColorForScheme(colorScheme))
                .shadow(radius: 5)
        )
        .offset(x: offset.width + dragState.width, y: offset.height + dragState.height)
        .position(position)
        .gesture(
            DragGesture()
                .updating($dragState) { value, state, _ in
                    state = CGSize(width: value.translation.width, height: value.translation.height)
                }
                .onEnded { value in
                    self.offset.width += value.translation.width
                    self.offset.height += value.translation.height
                }
        ).onAppear() {
            // Starting Position
            self.position = gps.getCoordinate(for: .bottomLeft, offsetX: 50, offsetY: ((75 * Double(items.count)) / 2))
        }
    }
    
}

struct MenuBarStatic: View {
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
        VStack {
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
            }
            // Icons
            ForEach(0..<icons.count, id: \.self) { index in
                if iconStates[index] {
                    MenuButtonIcon(icon: icons[index])
                        .transition(.opacity)
                }
            }
        }
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
