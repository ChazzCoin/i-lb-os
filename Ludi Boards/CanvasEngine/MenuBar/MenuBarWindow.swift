//
//  MenuBarWindow.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI

struct MenuBarStatic: View {
    @Binding var showIcons: Bool
    @State var gps: GlobalPositioningSystem
    var onClick: () -> Void
    @EnvironmentObject var BEO: BoardEngineObject
    @StateObject private var rcl = RealmObserver<CurrentSolUser>()
//    @State private var showIcons = false
    @State private var iconStates = Array(repeating: false, count: 11)
    @Environment(\.colorScheme) var colorScheme
    @State private var isLocked = false
    @State private var lifeColor = Color.black
    
    func setColorScheme() { lifeColor = getForegroundColor(colorScheme) }

    let iconsLoggedOut = [
        MenuBarProvider.info,
        MenuBarProvider.lock,
        MenuBarProvider.toolbox,
        MenuBarProvider.boardSettings,
//        MenuBarProvider.navHome,
        MenuBarProvider.boardDetails,
        MenuBarProvider.boardCreate,
        MenuBarProvider.profile
    ]
    
    let iconsLoggedIn = [
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
    let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()

    @State var icons: [IconProvider] = []

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
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
                        .environmentObject(self.BEO)
                }
            }
        }
        .frame(width: self.BEO.guideModeIsEnabled ? 100 : 60, height: showIcons ? (gps.screenSize.height - 100) : 60)
        .background(Color.clear)
        .position(using: gps, at: .topLeft, offsetX: 50, offsetY: showIcons ? ((gps.screenSize.height - 60) / 2) : 50)
        .onAppear() {
            if userIsVerifiedToProceed() {
                icons = iconsLoggedIn
            } else {
                icons = iconsLoggedOut
            }
            iconStates = Array(repeating: false, count: icons.count)
            
            rcl.observeId(id: "SOL") { _ in
                if userIsVerifiedToProceed() {
                    icons = iconsLoggedIn
                } else {
                    icons = iconsLoggedOut
                }
                iconStates = Array(repeating: false, count: icons.count)
                showIcons = true
                animateIcons()
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
