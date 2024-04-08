//
//  MenuBarIcon.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI
import Combine
import CoreEngine

struct MenuButtonIcon: View {
    var icon: CoreIcon // Assuming IconProvider conforms to SwiftUI's View
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var BEO: BoardEngineObject
    @State private var lifeColor = Color.white
        
    func setupButton() {
        
        lifeColor = getForegroundColor(colorScheme)
        
        if icon.tool.title == MenuBarProvider.lock.tool.title {
            lifeColor = self.BEO.gesturesAreLocked ? Color.red : getForegroundColor(colorScheme)
        }
    }

    var body: some View {
        
        VStack {
            Image(systemName: icon.tool.image)
                .resizable()
                .frame(width: 35, height: 35)
                .foregroundColor(lifeColor)
                .onAppear() {
                    setupButton()
                }
        }
        .frame(width: 60, height: 60)
        .solBackgroundDark()
        .onChange(of: self.BEO.gesturesAreLocked, perform: { value in
            setupButton()
        })
        .onTapAnimation {
            print("CodiChannel SendTopic: \(icon.tool.title)")
            CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: icon.tool.title, stateAction: "toggle"))
        }
    }
}


struct TrashCanButtonIcon: View {
    @Environment(\.colorScheme) var colorScheme
    @State var cancellables = Set<AnyCancellable>()
    @State private var isHovering = false
    @State private var lifeColor = Color.black
    @State private var frame: CGRect = .zero
    
    func setColorScheme() {
        lifeColor = foregroundColorForScheme(colorScheme)
    }

    var body: some View {
        GeometryReader { geo in
            Image(systemName: isHovering ? "trash.fill" : "trash")
                .resizable()
                .frame(width: 35, height: 35)
                .foregroundColor(lifeColor)
                .onTapGesture {
                    print("icon.tool.title")
                }
                .onAppear {
                    frame = geo.frame(in: .global)
                    print("Frame: X: \(frame.minX), Y: \(frame.minY)")
                    setColorScheme()
                }
                .onDrop(of: [.text], isTargeted: $isHovering) { providers in
                    // Handle the drop, return true if the item is accepted
                    // Implement logic to delete the view that is dropped
                    return true
                }
        }
        .zIndex(2.0)
        .frame(width: 60, height: 60)
        .solBackgroundPrimaryGradient()
        .onAppear() {
            
            CodiChannel.TOOL_ON_FOLLOW.receive(on: RunLoop.main) { viewFollow in
                let vf = viewFollow as! ViewFollowing
                print("Monitoring View: X: \(vf.x) Y: \(vf.y) ")
                if frame.contains(CGPoint(x: vf.x, y: vf.y)) {
                    print("IS HOVERING")
                    isHovering = true
                } else {
                    print("IS NOT HOVERING")
                    isHovering = false
                }
            }.store(in: &cancellables)
        }
    }
    
    func foregroundColorForScheme(_ scheme: ColorScheme) -> Color {
        // Replace with your color logic
        return scheme == .dark ? .white : .black
    }
    
    func backgroundColorForScheme(_ scheme: ColorScheme) -> Color {
        // Replace with your color logic
        return scheme == .dark ? .black : .white
    }
}
