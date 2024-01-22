//
//  MenuBarIcon.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI
import Combine

struct MenuButtonIcon: View {
    var icon: IconProvider // Assuming IconProvider conforms to SwiftUI's View
    @Environment(\.colorScheme) var colorScheme
    @State private var isLocked = false
    @State private var lifeColor = Color.black
    
    func setColorScheme() { lifeColor = foregroundColorForScheme(colorScheme) }
    
    func handleTap() {
        if icon.tool.title == MenuBarProvider.lock.tool.title {
            isLocked = !isLocked
            lifeColor = isLocked ? Color.red : foregroundColorForScheme(colorScheme)
        }
    }

    var body: some View {
        
        VStack {
            Image(systemName: icon.tool.image)
                .resizable()
                .frame(width: 35, height: 35)
                .foregroundColor(Color.white)
                .onAppear() {
                    setColorScheme()
                }
        }
        .frame(width: 60, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(Color.secondaryBackground)
                .shadow(radius: 5)
        )
        .onTapAnimation {
            print("CodiChannel SendTopic: \(icon.tool.title)")
            handleTap()
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
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(backgroundColorForScheme(colorScheme))
                .shadow(radius: 5)
        ).onAppear() {
            
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
