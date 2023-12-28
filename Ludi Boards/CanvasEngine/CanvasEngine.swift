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
    
    @StateObject var BEO = BoardEngineObject()

    @State var cancellables = Set<AnyCancellable>()
    @State var showMenuBar: Bool = true
    @State var popupIsVisible: Bool = true
    var maxScaleFactor: CGFloat = 1.0
    
    @State private var angle: Angle = .zero
    @State private var lastAngle: Angle = .zero
    
    @State private var translation: CGPoint = .zero
    @State private var lastOffset = CGPoint.zero
    
    @State private var offsetTwo = CGSize.zero
    @State private var isDragging = false
    @State private var toolBarIsEnabled = true
    @State private var position = CGPoint(x: 0, y: 0) // Initial position
    @GestureState private var dragOffset = CGSize.zero
    
    // Initial size of your drawing canvas
    let initialWidth: CGFloat = 6000
    let initialHeight: CGFloat = 6000
    
    @ObservedObject var managedWindowsObject = ManagedViewWindows.shared
    
    var dragAngleGestures: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if self.BEO.gesturesAreLocked { return }

                // Simplify calculations and potentially invert them
                let translation = gesture.translation
                let cosAngle = cos(Angle(degrees: self.BEO.canvasRotation).radians)
                let sinAngle = sin(Angle(degrees: self.BEO.canvasRotation).radians)

                // Invert the translation adjustments
                let adjustedX = cosAngle * translation.width + sinAngle * translation.height
                let adjustedY = -sinAngle * translation.width + cosAngle * translation.height
                let rotationAdjustedTranslation = CGPoint(x: adjustedX, y: adjustedY)

                let offsetX = self.lastOffset.x + (rotationAdjustedTranslation.x / self.BEO.canvasScale)
                let offsetY = self.lastOffset.y + (rotationAdjustedTranslation.y / self.BEO.canvasScale)
                self.BEO.canvasOffset = CGPoint(x: offsetX, y: offsetY)
            }
            .onEnded { _ in
                if self.BEO.gesturesAreLocked { return }
                self.lastOffset = self.BEO.canvasOffset
            }
            .updating($dragOffset) { value, state, _ in
                if self.BEO.gesturesAreLocked { return }
                state = value.translation
            }
    }
    
    var scaleGestures: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if self.BEO.gesturesAreLocked { return }
                let delta = value / self.BEO.lastScaleValue
                self.BEO.canvasScale *= delta
                self.BEO.lastScaleValue = value
            }
            .onEnded { value in
                if self.BEO.gesturesAreLocked { return }
                self.BEO.lastScaleValue = 1.0
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
    
    func toggleDrawingMode(drawingType:String="LINE") {
        if self.BEO.isDraw {
            disableDrawing()
        } else {
            enableDrawing(drawingType: drawingType)
        }
    }
    
    func enableDrawing(drawingType:String="LINE") {
        self.BEO.isDraw = true
        self.BEO.isDrawing = drawingType
        self.BEO.gesturesAreLocked = true
        self.toolBarIsEnabled = false
        self.showMenuBar = false
    }
    
    func disableDrawing() {
        self.BEO.isDraw = false
        self.BEO.gesturesAreLocked = false
        self.toolBarIsEnabled = true
        self.showMenuBar = true
    }
    
    @State var menuIsOpen = false
    
    var body: some View {
        
        GlobalPositioningZStack { geo, gps in
            
            if self.BEO.isLoading {
                ProgressView()
                    .frame(width: 300, height: 300)
                    .progressViewStyle(.circular)
                    .scaleEffect(5) // Adjust the size as needed
                    .padding(20)
                    .cornerRadius(10)
                    .position(using: gps, at: .center)
            }
            
            MenuBarStatic(){
                menuIsOpen = !menuIsOpen
            }
            .frame(width: 60, height: menuIsOpen ? (gps.screenSize.height - 200) : 60)
            .position(using: gps, at: .topLeft, offsetX: 50, offsetY: menuIsOpen ? ((gps.screenSize.height - 200) / 2) : 30)
//            GeometryReader { geo in
//                MenuBarStatic()
//            }
//            .frame(width: 60)
//            .position(using: gps, at: .topLeft, offsetX: 50, offsetY: 200)
            
            NavPadView()
                .environmentObject(self.BEO)
                .position(using: gps, at: .bottomCenter, offsetX: 0, offsetY: 150)
            
            ForEach(Array(managedWindowsObject.managedViewGenerics.values)) { managedViewWindow in
                managedViewWindow.viewBuilder().environmentObject(self.BEO)
            }.zIndex(5.0)
            
            
            if toolBarIsEnabled {
                ToolBarPicker {
                    LineIconView(isBgColor: false)
                        .frame(width: 50, height: 50)
                        .onTapAnimation {
                            enableDrawing(drawingType: "LINE")
                        }
                    DottedLineIconView()
                        .frame(width: 50, height: 50)
                        .onTapAnimation {
                            enableDrawing(drawingType: "DOTTED-LINE")
                        }
                    CurvedLineIconView()
                        .frame(width: 50, height: 50)
                        .onTapAnimation {
                            enableDrawing(drawingType: "CURVED-LINE")
                        }
                }
                .zIndex(2.0)
                .position(using: gps, at: .bottomCenter, offsetY: 50)
            }
            
            if self.BEO.isDraw {
                GeometryReader { geo in
                    TipBoxViewFlasher(tips: TipLineDrawing){
                        disableDrawing()
                    }
                }
                .frame(width: 300)
                .position(using: gps, at: .topRight, offsetX: 150, offsetY: 0)
            }
            
            if self.BEO.showTipViewStatic {
                GeometryReader { geo in
                    TipBoxViewStatic(tips: TipLineGestures){
                        self.BEO.showTipViewStatic = false
                    }
                }
                .frame(width: 300)
                .position(using: gps, at: .topRight, offsetX: 150, offsetY: 0)
            }
            
            
//            FloatingEmojiView()
//                .position(using: gps, at: .topLeft, offsetX: 200, offsetY: 0)
        }
        .zIndex(3.0)
        
        ZStack() {
            
            // Board/Canvas Level
            ZStack() {
                DrawGridLines().zIndex(1.0)
                BoardEngine()
                    .zIndex(2.0)
                    .environmentObject(self.BEO)
                
            }
            .frame(width: 20000, height: 20000)
            .offset(x: self.BEO.canvasOffset.x, y: self.BEO.canvasOffset.y)
            .scaleEffect(self.BEO.canvasScale)
            .rotationEffect(Angle(degrees: self.BEO.canvasRotation))
            .zIndex(1.0)
            
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .blur(radius: self.BEO.isLoading ? 10 : 0)
        .gesture(self.BEO.gesturesAreLocked ? nil : dragAngleGestures.simultaneously(with: scaleGestures))
        .background(Color.clear)
        .zIndex(0.0)
        .onAppear() {
            self.BEO.loadUser()
            
            menuBarButtonListener()
            handleChat()
//            handleBuddyProfile()
            handleSessionPlan()
            handleShare()
//            handleBuddyList()
//            handleNavPad()
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
                case .menuBar: return self.showMenuBar = !self.showMenuBar
                case .info: return self.BEO.showTipViewStatic = !self.BEO.showTipViewStatic
                case .toolbox: return self.toolBarIsEnabled = !self.toolBarIsEnabled
                case .lock: return self.handleGestureLock() //self.BEO.isShowingPopUp = !self.BEO.isShowingPopUp //
                case .canvasGrid: return
                case .navHome: return 
                case .buddyList: return
                case .boardList: return
                case .boardCreate: return
                case .boardDetails: return
                case .reset: return
                case .trash: return
                case .boardBackground: return
                case .profile: return// self.BEO.isLoading = !self.BEO.isLoading
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
        if self.BEO.gesturesAreLocked {
            self.BEO.gesturesAreLocked = false
        } else {
            self.BEO.gesturesAreLocked = true
        }
    }
    func handleChat() {
        let caller = MenuBarProvider.chat.tool.title
        let temp = ManagedViewWindow(id: caller, viewBuilder: {NavStackWindow(id: caller, viewBuilder: {ChatView(chatId: "default-1")})})
        temp.title = "Real-Time Chat"
        temp.windowId = caller
        managedWindowsObject.safelyAddItem(key: caller, item: temp)
    }
    func handleTimeManagement() {
        let caller = MenuBarProvider.chat.tool.title
        let temp = ManagedViewWindow(id: caller, viewBuilder: {NavStackWindow(id: caller, viewBuilder: {StopwatchView()})})
        temp.title = "Stop-Watch"
        temp.windowId = caller
        managedWindowsObject.safelyAddItem(key: caller, item: temp)
    }
    
    func handleNavPad() {
        let caller = MenuBarProvider.navHome.tool.title
        let temp = ManagedViewWindow(id: caller, viewBuilder: {NavPadView()})
        temp.title = "NavPad"
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
        let buddies = ManagedViewWindow(id: caller, viewBuilder: {NavStackWindow(id: caller, viewBuilder: {SessionPlanView(sessionId: "SOL", isShowing: .constant(true), isMasterWindow: true)})})
        buddies.title = "Session Planner"
        buddies.windowId = caller
        managedWindowsObject.toggleItem(key: caller, item: buddies)
    }
//    
    func handleSessionPlans() {
        let caller = MenuBarProvider.boardCreate.tool.title
        let buddies = ManagedViewWindow(id: caller, viewBuilder: {NavStackWindow(id: caller, viewBuilder: {SessionPlanOverview()})})
        buddies.title = "SOL Sessions"
        buddies.windowId = caller
        managedWindowsObject.toggleItem(key: caller, item: buddies)
    }
//    
    func handleShare() {
        let caller = MenuBarProvider.profile.tool.title
        let buddies = ManagedViewWindow(id: caller, viewBuilder: {NavStackWindow(id: caller, viewBuilder: {
            SignUpView().environmentObject(self.BEO)
        })})
        buddies.title = "Sign Up"
        buddies.windowId = caller
        managedWindowsObject.toggleItem(key: caller, item: buddies)
    }
    func handleMVSettings() {
        let caller = "mv_settings"
        let buddies = ManagedViewWindow(id: caller, viewBuilder: {NavStackWindow(id: caller, viewBuilder: {SettingsView(onDelete: {})})})
        buddies.title = "Tool View Settings"
        buddies.windowId = caller
        managedWindowsObject.safelyAddItem(key: caller, item: buddies)
    }
}

//struct LargeCanvasView2_Previews: PreviewProvider {
//    static var previews: some View {
//        CanvasEngine()
//    }
//}


