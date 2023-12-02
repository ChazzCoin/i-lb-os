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
    @State var isDrawing: Bool = false
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
    
    @State private var offsetTwo = CGSize.zero
    @State private var isDragging = false
    @State private var toolBarIsEnabled = true
    @State private var position = CGPoint(x: 50, y: 50) // Initial position
    @GestureState private var dragOffset = CGSize.zero
    
    // Initial size of your drawing canvas
    let initialWidth: CGFloat = 6000
    let initialHeight: CGFloat = 6000
    
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
                let scaledAngle = (value - self.lastAngle) * 0.5
                self.angle = self.lastAngle + scaledAngle
            }
            .onEnded { value in
                self.lastAngle += value // Update the last angle on gesture end
            }
    }
    
    var body: some View {
        
        GlobalPositioningZStack { geo, gps in
            
            ForEach(Array(managedWindowsObject.managedViewGenerics.values)) { managedViewWindow in
                managedViewWindow.viewBuilder()
            }.zIndex(5.0)
            
            // Global MenuBar
            MenuBarWindow(items: [
                {MenuButtonIcon(icon: MenuBarProvider.toolbox)},
                {MenuButtonIcon(icon: MenuBarProvider.lock)},
                {MenuButtonIcon(icon: MenuBarProvider.profile)},
                {MenuButtonIcon(icon: MenuBarProvider.buddyList)},
                {MenuButtonIcon(icon: MenuBarProvider.chat)},
                {MenuButtonIcon(icon: MenuBarProvider.boardCreate)},
                {MenuButtonIcon(icon: MenuBarProvider.boardDetails)},
                {MenuButtonIcon(icon: MenuBarProvider.share)}
            ])
            
            if toolBarIsEnabled {
                ToolBarPicker {
                    LineIconView()
                        .frame(width: 50, height: 50)
                        .onTapAnimation {
                            self.isDrawing = !self.isDrawing
                        }
                    DottedLineIconView()
                        .frame(width: 50, height: 50)
                        .onTapAnimation {
                            self.isDrawing = !self.isDrawing
                        }
                    CurvedLineIconView()
                        .frame(width: 50, height: 50)
                        .onTapAnimation {
                            self.isDrawing = !self.isDrawing
                        }
                }
                .zIndex(2.0)
                .position(using: gps, at: .bottomCenter, offsetY: 50)
            }
            
            if self.isDrawing {
                FlashingLightView(isEnabled: $isDrawing)
                    .position(using: gps, at: .topRight, offsetY: 25)
                TipViewLocked(tip: "Tap & Drag to Create a Line", isVisible: $isDrawing)
                    .position(using: gps, at: .topRight, offsetX: 500, offsetY: -50)
            }
            
//            FloatingEmojiView()
//                .position(using: gps, at: .topLeft, offsetX: 200, offsetY: 0)
        }.zIndex(3.0)
        
        ZStack() {
            
            // Board/Canvas Level
            ZStack() {
                DrawGridLines().zIndex(1.0)
                BoardEngine(isDraw: $isDrawing).zIndex(2.0)
            }
            .frame(width: 20000, height: 20000)
            .background(Color.clear)
            .offset(x: self.offset.x, y: self.offset.y)
            .scaleEffect(totalScale * gestureScale)
            .rotationEffect(angle)
            .zIndex(1.0)
            
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .gesture(dragAngleGestures.simultaneously(with: scaleGestures))
        .background(Color.clear)
        .zIndex(0.0)
        .onAppear() {
            menuBarButtonListener()
            handleChat()
//            handleBuddyProfile()
            handleSessionPlan()
//            handleShare()
//            handleBuddyList()
            handleMVSettings()
            handleSessionPlans()
        }
        
    }
    
    func menuBarButtonListener() {
        
        CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { controller in
            print("Received on MENU_TOGGLER channel: \(controller)")
            let temp = controller as! WindowController
            let buttonType = temp.windowId
            
            switch MenuBarProvider.parseByTitle(title: buttonType) {
                case .toolbox: return if temp.stateAction != "open" {
                    self.toolBarIsEnabled = true
                }else {
                    self.toolBarIsEnabled = false
                }
                case .lock: return self.handleGestureLock()
                case .canvasGrid: return
                case .navHome: return
                case .buddyList: return
                case .boardList: return
                case .boardCreate: return
                case .boardDetails: return
                case .reset: return
                case .trash: return
                case .boardBackground: return
                case .profile: return
                case .share: return
                case .router: return
                case .note: return
                case .chat: return
                
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
        let caller = MenuBarProvider.chat.tool.title
        let temp = ManagedViewWindow(id: caller, viewBuilder: {NavStackWindow(id: caller, viewBuilder: {ChatView(chatId: "default-1")})})
        temp.title = "Real-Time Chat"
        temp.windowId = caller
        managedWindowsObject.safelyAddItem(key: caller, item: temp)
    }
        
//    func handleBuddyList() {
//        let caller = MenuBarProvider.buddyList.tool.title
//        let buddies = ManagedViewWindow(id: caller, viewBuilder: AnyView(BuddyListView()))
//        buddies.title = "Buddy List"
//        buddies.windowId = caller
//        managedWindowsObject.toggleItem(key: caller, item: AnyView(NavStackWindow(managedViewWindow: buddies)))
//    }
//    
//    func handleBuddyProfile() {
//        let caller = MenuBarProvider.profile.tool.title
//        let buddies = ManagedViewWindow(id: caller, viewBuilder: AnyView(BuddyProfileView()))
//        buddies.title = "Buddy Profile"
//        buddies.windowId = caller
//        managedWindowsObject.toggleItem(key: caller, item: AnyView(NavStackWindow(managedViewWindow: buddies)))
//    }
//    
    func handleSessionPlan() {
        let caller = MenuBarProvider.boardDetails.tool.title
        let buddies = ManagedViewWindow(id: caller, viewBuilder: {NavStackWindow(id: caller, viewBuilder: {SessionPlanView(sessionId: "SOL")})})
        buddies.title = "Session Planner"
        buddies.windowId = caller
        managedWindowsObject.toggleItem(key: caller, item: buddies)
    }
//    
    func handleSessionPlans() {
        let caller = MenuBarProvider.boardCreate.tool.title
        let buddies = ManagedViewWindow(id: caller, viewBuilder: {NavStackWindow(id: caller, viewBuilder: {SessionPlanListView()})})
        buddies.title = "SOL Sessions"
        buddies.windowId = caller
        managedWindowsObject.toggleItem(key: caller, item: buddies)
    }
//    
//    func handleShare() {
//        let caller = MenuBarProvider.share.tool.title
//        let buddies = ManagedViewWindow(id: caller, viewBuilder: AnyView(SignUpView()))
//        buddies.title = "Sign Up"
//        buddies.windowId = caller
//        managedWindowsObject.toggleItem(key: caller, item: AnyView(NavStackWindow(managedViewWindow: buddies)))
//    }
    func handleMVSettings() {
        let caller = "mv_settings"
        let buddies = ManagedViewWindow(id: caller, viewBuilder: {NavStackWindow(id: caller, viewBuilder: {SettingsView(onDelete: {})})})
        buddies.title = "Tool View Settings"
        buddies.windowId = caller
        managedWindowsObject.safelyAddItem(key: caller, item: buddies)
    }
}

struct LargeCanvasView2_Previews: PreviewProvider {
    static var previews: some View {
        CanvasEngine()
    }
}


