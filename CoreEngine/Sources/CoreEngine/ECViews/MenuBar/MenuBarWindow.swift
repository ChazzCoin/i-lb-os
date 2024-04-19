//
//  MenuBarWindow.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI
import Combine

// MARK: MASTER Menu Bar
public struct MenuBarStatic: View {
    @Binding public var showIcons: Bool
    @State public var gps: GlobalPositioningSystem
    public var onClick: () -> Void
    
    public init(showIcons: Binding<Bool>, gps: GlobalPositioningSystem, onClick: @escaping () -> Void) {
        self._showIcons = showIcons
        self._gps = State(initialValue: gps)
        self.onClick = onClick
    }

    @AppStorage("isLoggedIn") public var isLoggedIn: Bool = false
    @AppStorage("guideModeIsEnabled") public var guideModeIsEnabled: Bool = false
    @State public var iconStates = Array(repeating: false, count: 11)
    @Environment(\.colorScheme) public var colorScheme
    @State public var isLocked = false
    @State public var lifeColor = Color.black
    @State public var isAnimating = false
    
    public func setColorScheme() { lifeColor = getForegroundColor(colorScheme) }

    public let iconsLoggedOut = [
        MenuBarProvider.info,
        MenuBarProvider.lock,
        MenuBarProvider.toolbox,
        MenuBarProvider.boardSettings,
//        MenuBarProvider.navHome,
        MenuBarProvider.boardDetails,
        MenuBarProvider.boardCreate,
        MenuBarProvider.profile
    ]
    
    public let iconsLoggedIn = [
        MenuBarProvider.info,
        MenuBarProvider.lock,
        MenuBarProvider.toolbox,
        MenuBarProvider.boardSettings,
//        MenuBarProvider.navHome,
        MenuBarProvider.boardDetails,
        MenuBarProvider.boardCreate,
        MenuBarProvider.chat,
        MenuBarProvider.profile
    ]
    public let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()

    @State public var icons: [CoreIcon] = []

    public var body: some View {
        VStack {
            // Toggle Button
            VStack {
                Image(systemName: MenuBarProvider.menuBar.tool.image)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(Color.white)
                    .onAppear() {
                        setColorScheme()
                    }
            }
            .frame(width: 60, height: 60)
            .solBackgroundPrimaryGradient()
            .onTapAnimation {
                if isAnimating { return }
                showIcons.toggle()
                animateIcons()
                onClick()
            }
            
            ScrollView(.vertical, showsIndicators: false) {
               
                // Icons
                ForEach(0..<icons.count, id: \.self) { index in
                    if iconStates[index] {
                        MenuButtonIcon(icon: icons[index])
                            .transition(.opacity)
                    }
                }
            }
            
            
        }
        .frame(width: self.guideModeIsEnabled ? 100 : 60, height: showIcons ? (gps.screenSize.height - 100) : 60)
        .background(Color.clear)
        .position(using: gps, at: .topLeft, offsetX: 50, offsetY: showIcons ? ((gps.screenSize.height - 60) / 2) : 50)
        .onChange(of: isLoggedIn, perform: { value in
            if value {
                icons = iconsLoggedIn
            } else {
                icons = iconsLoggedOut
            }
            iconStates = Array(repeating: false, count: icons.count)
            showIcons = true
            animateIcons()
        })
        .onAppear() {
            if UserTools.isLoggedIn {
                icons = iconsLoggedIn
            } else {
                icons = iconsLoggedOut
            }
            iconStates = Array(repeating: false, count: icons.count)
        }
    }
    
    public func animateIcons() {
        if showIcons {
            isAnimating = true
            // Show icons one by one
            for index in 0..<icons.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                    withAnimation {
                        iconStates[index] = true
                    }
                }
            }
            delayThenMain(1, mainBlock: {
                isAnimating = false
            })
        } else {
            isAnimating = true
            // Hide icons one by one, in reverse order
            for index in (0..<icons.count).reversed() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(icons.count - index) * 0.1) {
                    withAnimation {
                        iconStates[index] = false
                    }
                }
            }
            delayThenMain(0.75, mainBlock: {
                isAnimating = false
            })
        }
    }
}
