//
//  MenuBarIcon.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI
import Combine


public struct MenuButtonIcon: View {
    public var icon: CoreIcon // Assuming IconProvider conforms to SwiftUI's View
    @Environment(\.colorScheme) public var colorScheme
    @State public var lifeColor = Color.white
    @AppStorage("gesturesAreLocked") public var gesturesAreLocked: Bool = false
    
    public func setupButton() {
        
        lifeColor = getForegroundColor(colorScheme)
        
        if icon.tool.title == MenuBarProvider.lock.tool.title {
            lifeColor = gesturesAreLocked ? Color.red : getForegroundColor(colorScheme)
        }
    }

    public var body: some View {
        
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
        .onChange(of: gesturesAreLocked, perform: { value in
            setupButton()
        })
        .onTapAnimation {
            print("CodiChannel SendTopic: \(icon.tool.title)")
            
            BroadcastTools.send(.NavStackMessage, value: NavStackMessage(navAction: .toggle, viewName: icon.tool.title, viewAction: .toggle))
//            CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: icon.tool.title, stateAction: .toggle))
        }
    }
}


public struct TrashCanButtonIcon: View {
    @Environment(\.colorScheme) public var colorScheme
    @State public var cancellables = Set<AnyCancellable>()
    @State public var isHovering = false
    @State public var lifeColor = Color.black
    @State public var frame: CGRect = .zero
    
    public func setColorScheme() {
        lifeColor = foregroundColorForScheme(colorScheme)
    }

    public var body: some View {
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
    
    public func foregroundColorForScheme(_ scheme: ColorScheme) -> Color {
        // Replace with your color logic
        return scheme == .dark ? .white : .black
    }
    
    public func backgroundColorForScheme(_ scheme: ColorScheme) -> Color {
        // Replace with your color logic
        return scheme == .dark ? .black : .white
    }
}
