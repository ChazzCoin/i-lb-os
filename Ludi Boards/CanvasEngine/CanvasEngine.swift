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
    
    @ObservedObject var BEO = BoardEngineObject()
    
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
//    @State private var toolBarIsEnabled = true
    @State private var position = CGPoint(x: 0, y: 0) // Initial position
    @GestureState private var dragOffset = CGSize.zero
    
    // Initial size of your drawing canvas
    let initialWidth: CGFloat = 6000
    let initialHeight: CGFloat = 6000
    
    @StateObject var managedWindowsObject: NavWindowController = NavWindowController()
    
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
        self.BEO.drawType = drawingType
        self.BEO.gesturesAreLocked = true
        self.BEO.toolBarIsShowing = false
        self.showMenuBar = false
    }
    
    func disableDrawing() {
        self.BEO.isDraw = false
        self.BEO.gesturesAreLocked = false
        self.BEO.toolBarIsShowing = true
        self.showMenuBar = true
    }
    
    @State var showRecordingsSheet = false
    @State var menuIsOpen = false
    @State var showNotification = false
    @State var notificationMessage = ""
    @State var notificationIcon = ""
    @State var sessionPlan = SessionPlan()
    
    @State var alertDeleteAllTools = false
    @State var alertDeleteAllToolsTitle = "Delete All Tools"
    @State var alertDeleteAllToolsMessage = "Are you sure you want to delete all tools?"
    
    @State var alertRecordAnimation = false
    @State var alertRecordAnimationTitle = "Animation Recording"
    var alertRecordAnimationMessage: String {
        return "Are you sure you want to \(self.BEO.isRecording ? "Stop" : "Start") recording?"
    }
    
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
            
            // Menu Bar
            MenuBarStatic(showIcons: $menuIsOpen){}
                .frame(width: 60, height: menuIsOpen ? (gps.screenSize.height - 100) : 60)
                .position(using: gps, at: .topLeft, offsetX: 50, offsetY: menuIsOpen ? ((gps.screenSize.height - 60) / 2) : 50)
                .environmentObject(self.BEO)
            
            // Navigation Bar
            NavPadView()
                .environmentObject(self.BEO)
                .position(using: gps, at: .bottomCenter, offsetX: 0, offsetY: 150)
            
            if !self.managedWindowsObject.reload {
                ForEach(Array(managedWindowsObject.activeViews.keys), id: \.self) { key in
                    managedWindowsObject.getView(withId: key)
                        .viewBuilder()
                        .zIndex(50.0)
                        .environmentObject(self.BEO)
                }
            }
            
            if self.BEO.toolSettingsIsShowing && !self.BEO.screenIsActiveAndLocked() {
                MvSettingsBar {}
                    .zIndex(2.0)
                    .position(using: gps, at: .bottomCenter, offsetY: 100)
                    .environmentObject(self.BEO)
            }
            
            // Tool Bar
            if self.BEO.toolBarIsShowing && !self.BEO.screenIsActiveAndLocked() {
                ToolBarPicker {
                    LineIconView(isBgColor: false)
                        .frame(width: 50, height: 50)
                        .onTapAnimation {
                            enableDrawing(drawingType: "LINE")
                        }
                    CurvedLineIconView()
                        .frame(width: 50, height: 50)
                        .onTapAnimation {
                            enableDrawing(drawingType: "CURVED-LINE")
                        }
                }
                .zIndex(2.0)
                .position(using: gps, at: .bottomCenter, offsetY: 50)
                .environmentObject(self.BEO)
            }
            
            // Drawing Mode Popup
            if self.BEO.isPlayingAnimation {
                GeometryReader { geo in
                    ModeAlert(title: "Playing in Progress...", subTitle: "Playback Mode.", showButton: true) {
                        self.BEO.stopAnimationRecording()
                    }
                }
                .frame(width: 300)
                .position(using: gps, at: .topRight, offsetX: 150, offsetY: 0)
            }
            
            // Drawing Mode Popup
            if self.BEO.isRecording {
                GeometryReader { geo in
                    ModeAlert(title: "Recording in Progress...", subTitle: "Animation Mode.", showButton: true) {
                        self.BEO.stopRecording()
                    }
                }
                .frame(width: 300)
                .position(using: gps, at: .topRight, offsetX: 150, offsetY: 0)
            }
            
            // Drawing Mode Popup
            if self.BEO.isDraw {
                GeometryReader { geo in
                    TipBoxViewFlasher(tips: TipLineDrawing){
                        disableDrawing()
                    }
                }
                .frame(width: 300)
                .position(using: gps, at: .topRight, offsetX: 150, offsetY: 0)
            }
            
            // Tip Box
            if self.BEO.showTipViewStatic {
                GeometryReader { geo in
                    TipBoxViewStatic(tips: TipLineGestures, subTitle: "General Tips"){
                        self.BEO.showTipViewStatic = false
                    }
                }
                .frame(width: 300)
                .position(using: gps, at: .topLeft, offsetX: 150, offsetY: 0)
            }
            
            // Notify Box
            if self.showNotification {
                GeometryReader { geo in
                    NotificationView(message: self.$notificationMessage, icon: self.$notificationIcon)
                }
                .zIndex(50.0)
                .position(using: gps, at: .topRight, offsetX: 150, offsetY: 0)
            }
            
            
//            FloatingEmojiView()
//                .position(using: gps, at: .topLeft, offsetX: 200, offsetY: 0)
        }
        .zIndex(3.0)
        
        ZStack() {
            
            // Board/Canvas Level
            ZStack() {
                BoardEngine()
                    .zIndex(2.0)
                    .environmentObject(self.BEO)
            }
            .zIndex(1.0)
            .frame(width: 20000, height: 20000)
            .offset(x: self.BEO.canvasOffset.x, y: self.BEO.canvasOffset.y)
            .scaleEffect(self.BEO.canvasScale)
            .rotationEffect(Angle(degrees: self.BEO.canvasRotation))

        }
        .zIndex(0.0)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .blur(radius: self.BEO.isLoading ? 10 : 0)
        .background(Color.white.opacity(0.001))
        .gesture(self.BEO.gesturesAreLocked ? nil : dragAngleGestures.simultaneously(with: scaleGestures))
        .onChange(of: self.BEO.toolBarIsShowing, perform: { value in
            if self.BEO.toolBarIsShowing {
                self.BEO.toolSettingsIsShowing = false
            }
        })
        .onChange(of: self.BEO.toolSettingsIsShowing, perform: { value in
            if self.BEO.toolSettingsIsShowing {
                self.BEO.toolBarIsShowing = false
            }
        })
        .sheet(isPresented: self.$showRecordingsSheet, content: {
            RecordingListView(isShowing: self.$showRecordingsSheet)
                .environmentObject(self.BEO)
        })
        .alert(self.alertDeleteAllToolsTitle, isPresented: $alertDeleteAllTools) {
            Button("Cancel", role: .cancel) {
                alertDeleteAllTools = false
            }
            Button("OK", role: .none) {
                alertDeleteAllTools = false
                self.BEO.deleteAllTools()
            }
        } message: {
            Text(self.alertDeleteAllToolsMessage)
        }
        .alert(self.alertRecordAnimationTitle, isPresented: $alertRecordAnimation) {
            Button("Cancel", role: .cancel) {
                alertRecordAnimation = false
            }
            Button("OK", role: .none) {
                alertRecordAnimation = false
                if !self.BEO.isRecording {
                    self.BEO.startRecording()
                } else {
                    self.BEO.stopRecording()
                }
            }
        } message: {
            Text(self.alertRecordAnimationMessage)
        }
        .onAppear() {
            self.BEO.loadUser()
            menuBarButtonListener()
            handleSessionPlan()
            handleSessionPlans()
            addChatWindow()
            addProfileWindow()
            addMvSettings()
        }
        
    }
    
    @MainActor
    func notificationListener() {
        
        CodiChannel.ON_NOTIFICATION.receive(on: RunLoop.main) { message in
            if let message = message as? NotificationController {
                print("Received on ON_NOTIFICATION channel: \(message.message)")
                self.notificationMessage = message.message
                self.notificationIcon = message.icon
                self.showNotification = true
                DispatchQueue.executeAfter(seconds: 5, action: {
                    withAnimation {
                        self.showNotification = false
                    }
                })
                
            }
        }.store(in: &cancellables)
        
    }
    
    @MainActor
    func menuBarButtonListener() {
        
        CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { controller in
            print("Received on MENU_TOGGLER channel: \(controller)")
            let temp = controller as! WindowController
            let buttonType = temp.windowId
            
            switch MenuBarProvider.parseByTitle(title: buttonType) {
                case .menuBar: return self.showMenuBar = !self.showMenuBar
                case .info: return self.BEO.showTipViewStatic = !self.BEO.showTipViewStatic
                case .toolbox: return self.BEO.toolBarIsShowing = !self.BEO.toolBarIsShowing
                case .trash: return self.alertDeleteAllTools = true
                case .lock: return self.handleGestureLock()
                case .video: return self.alertRecordAnimation = true
                case .play: return self.showRecordingsSheet = true
                //
                case .canvasGrid: return
                case .navHome: return 
                case .buddyList: return
                case .boardList: return
                case .boardCreate: return
                case .boardDetails: return
                case .reset: return
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
        if self.BEO.gesturesAreLocked {
            self.BEO.gesturesAreLocked = false
        } else {
            self.BEO.gesturesAreLocked = true
        }
    }

//    func handleTimeManagement() {
//        let caller = MenuBarProvider.chat.tool.title
//        let temp = ManagedViewWindow(id: caller, viewBuilder: {
//            NavStackWindow(id: caller, viewBuilder: {
//                StopwatchView()
//            })
//        })
//        temp.title = "Stop-Watch"
//        temp.windowId = caller
//        managedWindowsObject.safelyAddItem(key: caller, item: temp)
//    }
    
    func handleNavPad() {
        let caller = MenuBarProvider.navHome.tool.title
        managedWindowsObject.addNewViewToPool(viewId: caller, viewBuilder: { AnyView(NavPadView().environmentObject(self.BEO)) })
    }
    func addChatWindow() {
        let caller = MenuBarProvider.chat.tool.title
        managedWindowsObject.addNewViewToPool(viewId: caller, viewBuilder: {
            AnyView(NavStackWindow(id: caller, viewBuilder: {
                ChatView().environmentObject(self.BEO)
            }))
        })
    }
    func addProfileWindow() {
        let caller = MenuBarProvider.profile.tool.title
        managedWindowsObject.addNewViewToPool(viewId: caller, viewBuilder: {
            AnyView(NavStackWindow(id: caller, viewBuilder: {
                SignUpView().environmentObject(self.BEO)
            }))
        })
    }
    func handleSessionPlan() {
        let caller = MenuBarProvider.boardDetails.tool.title
        managedWindowsObject.addNewViewToPool(viewId: caller, viewBuilder: {
            AnyView(NavStackWindow(id: caller, viewBuilder: {
                SessionPlanView(sessionId: "SOL", isShowing: .constant(true), isMasterWindow: true).environmentObject(self.BEO)
            }))
        })
    }
    func handleSessionPlans() {
        let caller = MenuBarProvider.boardCreate.tool.title
        managedWindowsObject.addNewViewToPool(viewId: caller, viewBuilder: {
            AnyView(NavStackWindow(id: caller, viewBuilder: {
                SessionPlanOverview().environmentObject(self.BEO)
            }))
        })
    }
    func addMvSettings() {
        let caller = "mv_settings"
        managedWindowsObject.addNewViewToPool(viewId: caller, viewBuilder: {
            AnyView(NavStackFloatingWindow(id: caller, viewBuilder: {
                SettingsView(onDelete: {}).environmentObject(self.BEO)
            }))
        })
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

//    
   
////


}


