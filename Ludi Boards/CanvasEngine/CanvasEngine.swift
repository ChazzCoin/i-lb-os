//
//  CanvasViewV2.swift
//  iosLudiSports
//
//  Created by Charles Romeo on 11/8/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct CanvasEngine: View {
    
    @State var cancellables = Set<AnyCancellable>()
    
    @State var popupIsVisible: Bool = true
    @State var gesturesAreLocked: Bool = false
    var maxScaleFactor: CGFloat = 1.0
    @State private var totalScale: CGFloat = 0.15
    @GestureState private var gestureScale: CGFloat = 1.0
    
    @State private var angle: Angle = .zero
    @State private var lastAngle: Angle = .zero
    
    @State private var translation: CGPoint = .zero
    @State private var offset = CGPoint.zero
    @State private var lastOffset = CGPoint.zero
    
    @State private var pointers = CGPoint.zero // Initial position
    @State private var position = CGPoint(x: 50, y: 50) // Initial position
    @GestureState private var dragOffset = CGSize.zero
    
    // Initial size of your drawing canvas
    let initialWidth: CGFloat = 6000
    let initialHeight: CGFloat = 6000

    var temp = ManagedViewWindow(id: "", content: AnyView(ChatView()))
    
    @ObservedObject var managedWindowsObject = ManagedViewWindows.shared
    
    var dragAngleGestures: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if gesturesAreLocked { return }

                // Simplify calculations and potentially invert them
                let translation = gesture.translation
                let cosAngle = cos(self.angle.radians)
                let sinAngle = sin(self.angle.radians)

                // Invert the translation adjustments
                let adjustedX = cosAngle * translation.width + sinAngle * translation.height
                let adjustedY = -sinAngle * translation.width + cosAngle * translation.height
                let rotationAdjustedTranslation = CGPoint(x: adjustedX, y: adjustedY)

                let offsetX = self.lastOffset.x + (rotationAdjustedTranslation.x / self.totalScale)
                let offsetY = self.lastOffset.y + (rotationAdjustedTranslation.y / self.totalScale)
                self.offset = CGPoint(x: offsetX, y: offsetY)

                print("CanvasEngine -> Offset: X = [ \(self.offset.x) ] Y = [ \(self.offset.y) ]")
            }
            .onEnded { _ in
                if gesturesAreLocked { return }
                self.lastOffset = self.offset
            }
            .updating($dragOffset) { value, state, _ in
                if gesturesAreLocked { return }
                state = value.translation
            }
    }
    
    var scaleGestures: some Gesture {
        MagnificationGesture()
            .updating($gestureScale) { value, gestureScale, _ in
                if gesturesAreLocked { return }
                gestureScale = value
            }
            .onEnded { value in
                if gesturesAreLocked { return }
                totalScale *= value
            }
    }
    
    var rotationGestures: some Gesture {
        RotationGesture()
            .onChanged { value in
                self.angle = lastAngle + value
            }
            .onEnded { value in
                self.lastAngle += value // Update the last angle on gesture end
            }
    }
    
    struct FullScreenGestureView: View {
        var body: some View {
            GeometryReader { geometry in
                Color.clear
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .contentShape(Rectangle())
                    .gesture(TapGesture().onEnded { _ in
                        print("Tapped anywhere on the screen")
                    })
            }
        }
    }
    
    var body: some View {
        
        ZStack() {
            // Global MenuBar
            MenuBarWindow(items: [
                {MenuButtonIcon(icon: MenuBarProvider.toolbox)},
                {MenuButtonIcon(icon: MenuBarProvider.lock)},
                {MenuButtonIcon(icon: MenuBarProvider.buddyList)},
                {MenuButtonIcon(icon: MenuBarProvider.chat)}
            ]).zIndex(5.0)
            
            // Global Windows
            ForEach(Array(managedWindowsObject.managedViewGenerics.values)) { managedViewWindow in
                managedViewWindow.view()
            }
            .zIndex(5.0)
            
            FullScreenGestureView().zIndex(1.0)

//            PopupMenu(viewId: "", isVisible: $popupIsVisible)
//            SlideOutMenu().zIndex(6.0)
            // Board/Canvas Level
            ZStack() {
                DrawGridLines().zIndex(1.0)
                BoardEngine().zIndex(2.0)
                
            }
            .frame(width: initialWidth, height: initialHeight)
            .background(Color.clear)
            .zIndex(1.0)
            .offset(x: self.offset.x, y: self.offset.y)
            .scaleEffect(totalScale * gestureScale)
            .rotationEffect(angle)
            
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .gesture(dragAngleGestures.simultaneously(with: scaleGestures).simultaneously(with: rotationGestures))
        .zIndex(0.0)
        .background(Color.clear)
        .onAppear() {
            menuBarButtonListener()
            handleBuddyProfile()
        }
        
    }
    
    func menuBarButtonListener() {
        
        CodiChannel.general.receive(on: RunLoop.main) { buttonType in
            print("Received on MENU_TOGGLER channel: \(buttonType)")
            
            switch MenuBarProvider.parseByTitle(title: buttonType as? String ?? "") {
                case .toolbox: return self.handleTools()
                case .lock: return self.handleGestureLock()
                case .canvasGrid: return
                case .navHome: return
                case .buddyList: return self.handleBuddyList()
                case .boardList: return
                case .boardCreate: return
                case .boardDetails: return
                case .reset: return
                case .trash: return
                case .boardBackground: return
                case .profile: return self.handleBuddyProfile()
                case .share: return
                case .router: return
                case .note: return
                case .chat: return self.handleChat()
                
                case .none:
                    return
                case .some(.paint):
                    return
                case .some(.image):
                    return
                case .some(.webBrowser):
                    return
            }
            
        }.store(in: &cancellables)
        
    }
    func handleGestureLock() {
        if gesturesAreLocked {
            gesturesAreLocked = false
        } else {
            gesturesAreLocked = true
        }
    }
    func handleChat() {
        let temp = ManagedViewWindow(id: "chat", content: AnyView(ChatView()))
        temp.title = "Real-Time Chat"
        temp.windowId = "chat"
        managedWindowsObject.toggleItem(key: "chat", item: ViewWrapper {AnyView(GenericWindow(managedViewWindow: temp))})
    }
    
    func handleTools() {
        let temp = ManagedViewWindow(id: "soccer_tools", content: AnyView(SoccerToolsView()))
        temp.title = "Tools"
        temp.windowId = "soccer_tools"
        managedWindowsObject.toggleItem(key: "soccer_tools", item: ViewWrapper {AnyView(GenericWindow(managedViewWindow: temp))})
    }
    
    func handleBuddyList() {
        let buddies = ManagedViewWindow(id: "buddies", content: AnyView(BuddyListView()))
        buddies.title = "Buddy List"
        buddies.windowId = "buddies"
        managedWindowsObject.toggleItem(key: "buddies", item: ViewWrapper {AnyView(GenericWindow(managedViewWindow: buddies))})
    }
    
    func handleBuddyProfile() {
        let buddies = ManagedViewWindow(id: "buddyProfile", content: AnyView(BuddyProfileView()))
        buddies.title = "Buddy Profile"
        buddies.windowId = "buddyProfile"
        managedWindowsObject.toggleItem(key: "buddyProfile", item: ViewWrapper {AnyView(GenericWindow(managedViewWindow: buddies))})
    }
}

struct LargeCanvasView2_Previews: PreviewProvider {
    static var previews: some View {
        CanvasEngine()
    }
}


