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
import CoreEngine

struct CanvasEngine: View {
    
    @AppLifecycle(.appDidEnterBackground) public var appDidEnterBackground: Bool
    @AppStorageDictionary("coordinates") public var coordinates: [String: Any]
    
    @ObservedObject var UTO = UserToolsObservable()
    @ObservedObject var BEO = BoardEngineObject()
    @ObservedObject var DO = OrientationInfo()
    
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
    
    @StateObject var navTools: NavWindowController = NavWindowController()
    
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
    
    func toggleDrawingMode(shapeSubType:String=ShapeToolProvider.line_straight) {
        
        if self.BEO.isDraw {
            disableDrawing()
        } else {
            enableDrawing(shapeSubType: shapeSubType)
        }
    }
    
    func enableDrawing(shapeSubType:String=ShapeToolProvider.line_straight) {
        self.BEO.isDraw = true
        self.BEO.shapeSubType = shapeSubType
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
    @State var notificationMessage = "Testing Notification System!"
    @State var notificationIcon = "door_open"
    @State var sessionPlan = SessionPlan()
    
    @State var alertDeleteAllTools = false
    @State var alertDeleteAllToolsTitle = "Delete All Tools"
    @State var alertDeleteAllToolsMessage = "Are you sure you want to delete all tools?"
    
    @State var alertRecordAnimation = false
    @State var alertRecordAnimationTitle = "Animation Recording"
    var alertRecordAnimationMessage: String {
        return "Are you sure you want to \(self.BEO.isRecording ? "Stop" : "Start") recording?"
    }
    
    @State var masterResetCanvas = false
    func masterResetTheCanvas() {
        self.masterResetCanvas = true
        self.masterResetCanvas = false
    }
    
    @StateObject public var modelPanel = PanelModeController(title: "Testing Mode Panel", subTitle: "Looks to be good to me!")
    @State var testTrigger = true
    @State var wrapIsVisible = true
    var body: some View {
        
//        if !masterResetCanvas { EmptyView() }
        
        GlobalPositioningZStack(coordinateSpace: .global) { windowGPS in
            GlobalPositioningReader(coordinateSpace: .global) { geo, gps in
                
                // Just a basic wrap.
                Wrap {
                    Text("A simple wrap for anyview.. it will form/wrap the size of its contents.")
                }
                // GPS
                Wrap(.bottomCenter) {
                    Text("Places this view in the bottom center of the screen.")
                }
                // Visible Toggle Binding
                Wrap($wrapIsVisible) {
                    Text("This is able to toggle the views visibility.")
                }
                // Do one or do all.
                Wrap($testTrigger, .bottomCenter, padding: true) {
                    Text("Or.. do all of it haha.")
                }
                
                
                MenuBarStatic(showIcons: $menuIsOpen, gps: gps){}
                
                Wrap($testTrigger, .bottomCenter, padding: true) {
                    ToolBarPicker {
                        LineIconView(isBgColor: false)
                            .frame(width: 50, height: 50)
                            .onTapAnimation {
                                enableDrawing(shapeSubType: ShapeToolProvider.line_straight)
                            }
                        CurvedLineIconView()
                            .frame(width: 50, height: 50)
                            .onTapAnimation {
                                enableDrawing(shapeSubType: ShapeToolProvider.line_curved)
                            }
                    }
                    .environmentObject(self.BEO)
                }
    
                navTools.getNavStackView()
                self.modelPanel.Display(.center)
                
//                TimedView($testTrigger, seconds: 10) {
//                    NotificationPanel(message: self.$notificationMessage, icon: self.$notificationIcon)
//                        .position(using: gps, at: .topCenter, offsetX: 0, offsetY: 75)
//                }
                
//                ModePanel(title: "Playing in Progress...", subTitle: "Playback Mode.", showButton: true) {
//                    self.BEO.stopAnimationRecording()
//                }.position(using: gps, at: .topRight, offsetX: 150, offsetY: 150)
                
            }.zIndex(35.0)
            
            GlobalPositioningReader(coordinateSpace: .canvas, width: 20000, height: 20000) { cGeo, cGps in

                // Board/Canvas Level
                BoardEngine()
                    .zIndex(2.0)
                    .environmentObject(self.BEO)
                    .environmentObject(self.navTools)
                    .background(.clear)
                    .frame(width: cGeo.size.width, height: cGeo.size.height)
                    .offset(x: self.BEO.canvasOffset.x, y: self.BEO.canvasOffset.y)
                    .scaleEffect(self.BEO.canvasScale)
                    .rotationEffect(Angle(degrees: self.BEO.canvasRotation))

            }
            .zIndex(0.0)
            .background(Color.black.opacity(0.0001))
            .gesture(self.BEO.gesturesAreLocked ? nil : dragAngleGestures.simultaneously(with: scaleGestures))
        }
        .background(StarryNightAnimatedView())
        .onAppear() {
            _appDidEnterBackground.onChange = {
                print("YESSSS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            }
            delayThenMain(3, mainBlock: { self.testTrigger = false })
            navTools.addView(
                callerId: MenuBarProvider.boardCreate.tool.title,
                mainContent: { HomeDashboardView().environmentObject(self.BEO) },
                sideContent: { MenuListView(isShowing: .constant(true)).clearSectionBackground() }
            )
            navTools.navTo(viewId: MenuBarProvider.boardCreate.tool.title)
            NavTools.openNavStack()
//            BroadcastTools.toggleViewVisibility(viewId: SPanel.mode.name, isVisible: true)
        }
        
        
        /*
        ZStack {
            GlobalPositioningZStack(coordinateSpace: CoreNameSpace.global) { geo, gps in
                
                // Menu Bar
                MenuBarStatic(showIcons: $menuIsOpen, gps: gps){}
                
                // Navigation Bar
                NavPadView()
                    .environmentObject(self.BEO)
                    .position(using: gps, at: .bottomCenter, offsetX: 0, offsetY: 150)
                
                navTools.getNavStackView()
                
                if self.BEO.boardSettingsIsShowing && !self.BEO.screenIsActiveAndLocked() {
                    BoardSettingsBar()
                        .zIndex(2.0)
                        .position(using: gps, at: .bottomCenter, offsetY: 100)
                        .environmentObject(self.BEO)
                }
                
                if self.BEO.toolSettingsIsShowing {
                    MvSettingsBar {}
                        .zIndex(2.0)
                        .position(using: gps, at: .bottomCenter, offsetY: 100)
                        .environmentObject(self.BEO)
                }
                
                // MARK: Tool Bar -> self.BEO.toolBarIsShowing && !self.BEO.screenIsActiveAndLocked()
                V.IsVisible($testTrigger) {
                    ToolBarPicker {
                        LineIconView(isBgColor: false)
                            .frame(width: 50, height: 50)
                            .onTapAnimation {
                                enableDrawing(shapeSubType: ShapeToolProvider.line_straight)
                            }
                        CurvedLineIconView()
                            .frame(width: 50, height: 50)
                            .onTapAnimation {
                                enableDrawing(shapeSubType: ShapeToolProvider.line_curved)
                            }
                    }
                    .position(using: gps, at: .bottomCenter, offsetY: 50)
                    .environmentObject(self.BEO)
                }
//                .position(using: gps, at: .bottomCenter, offsetY: 50)
                .zIndex(2.0)
                
                
                V.IsVisible($BEO.isPlayingAnimation) {
                    ModePanel(title: "Playing in Progress...", subTitle: "Playback Mode.", showButton: true) {
                        self.BEO.stopAnimationRecording()
                    }
                }.position(using: gps, at: .topRight, offsetX: 150, offsetY: 0)

                
                // Drawing Mode Popup
                
    //                // Drawing Mode Popup
    //                if self.BEO.isPlayingAnimation {
    //                    GeometryReader { geo in
    //                        ModePanel(title: "Playing in Progress...", subTitle: "Playback Mode.", showButton: true) {
    //                            self.BEO.stopAnimationRecording()
    //                        }
    //                    }
    //                    .frame(width: 300)
    //                    .position(using: gps, at: .topRight, offsetX: 150, offsetY: 0)
    //                }
                
                // Drawing Mode Popup
                if self.BEO.isRecording {
                    GeometryReader { geo in
                        ModePanel(title: "Recording in Progress...", subTitle: "Animation Mode.", showButton: true) {
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
                        TipBoxViewStaticPanel(tips: TipLineGestures, subTitle: "General Tips"){
                            self.BEO.showTipViewStatic = false
                        }
                    }
                    .frame(width: 300)
                    .position(using: gps, at: .topLeft, offsetX: 150, offsetY: 0)
                }
                
                // Notify Box -> $showNotification
                V.IsVisible($testTrigger) {
                    NotificationPanel(message: self.$notificationMessage, icon: self.$notificationIcon)
                }.position(using: gps, at: .topRight, offsetX: 150, offsetY: 150)
                
                
    //            GlobalPositioningZStack(coordinateSpace: CoreNameSpace.canvas, width: 20000, height: 20000) { cGeo, cGps in
               
                
                
            }
            
            .background(.clear)
            
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .zIndex(50.0)
        
//        .gesture(self.BEO.gesturesAreLocked ? nil : dragAngleGestures.simultaneously(with: scaleGestures))
        */
//        ZStack {
//        GeometryReader { _ in
//        GlobalPositioningZStack(coordinateSpace: CoreNameSpace.canvas, width: 20000, height: 20000) { cGeo, cGps in
//            
//            // Board/Canvas Level
//            BoardEngine()
//                .zIndex(2.0)
//                .environmentObject(self.BEO)
//                .environmentObject(self.navTools)
//                .background(.red)
//                .frame(width: cGeo.size.width, height: cGeo.size.height)
//                .offset(x: self.BEO.canvasOffset.x, y: self.BEO.canvasOffset.y)
//                .scaleEffect(self.BEO.canvasScale)
//                .rotationEffect(Angle(degrees: self.BEO.canvasRotation))
//
//        }
//        .zIndex(0.0)
//        .background(.clear)
//        .frame(width: 20000, height: 20000)
        
//        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//            .blur(radius: self.BEO.isLoading ? 10 : 0)
//        .background(Color.white.opacity(0.001))
//        .gesture(self.BEO.gesturesAreLocked ? nil : dragAngleGestures.simultaneously(with: scaleGestures))
        
        .onChange(of: self.DO.orientation) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                masterResetTheCanvas()
            }
        }
        .onChange(of: self.BEO.toolBarIsShowing) {
            if self.BEO.toolBarIsShowing {
                self.BEO.toolSettingsIsShowing = false
            }
        }
        .onChange(of: self.BEO.toolSettingsIsShowing) {
            if self.BEO.toolSettingsIsShowing {
                self.BEO.toolBarIsShowing = false
            }
        }
        .onAppear() {
            menuBarButtonListener()
            
//                let newUser = CoreUser()
//                newUser.userName = "john boi"
//                newUser.handle = "jboi"
//
//                let json = newUser.toDict()
            
//                print("User Dict: \(json)")
            
            // Wabi -> 0dMBjcYFDRV6BnM8j4Nej8AD2kf2
            // Charles K Romeo -> 5mNVAE8vfhcYeT2cakcjUH3L9UE3
            // ME (chazzromeo@gmail.com) -> B1WMKiebpOScZaNzu58O2drK1l33
            
//                FusedTools.fusedCreator(FriendRequest.self, masterPass: true) { r in
//                    let request = FriendRequest()
//                    request.fromUserId = "B1WMKiebpOScZaNzu58O2drK1l33"
//                    request.toUserId = "5mNVAE8vfhcYeT2cakcjUH3L9UE3"
//                    return request
//                }
            
//            if let user = UserTools.user {
//                print(user)
//            }
//                UserTools.sendFriendRequest(toUserId: "0dMBjcYFDRV6BnM8j4Nej8AD2kf2")
//                UserTools.pullFriends()
//
//                if let user = UserTools.user {
//                    print("Users Friends: \(user.linkedFriends)")
//                }
            
//                navTools.addView(
//                    callerId: MenuBarProvider.profile.tool.title,
//                    mainContent: { SignUpView() },
//                    sideContent: { EmptyView() }
//                )
//                navTools.addView(
//                    callerId: MenuBarProvider.profile.tool.title,
//                    mainContent: { CoreSignUpView() },
//                    sideContent: { EmptyView() }
//                )
//            navTools.addView(
//                callerId: MenuBarProvider.boardCreate.tool.title,
//                mainContent: { HomeDashboardView().environmentObject(self.BEO) },
//                sideContent: { MenuListView(isShowing: .constant(true)).clearSectionBackground() }
//            )
//                NavTools.openNavStack()
//                delayThenMain(5, mainBlock: {
//                    self.testTrigger = true
//                })
                            
        }
        
    }
    

    @MainActor
    private func exportPDF() {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
     
        print("attempting to convert board view into pdf")
        let renderedUrl = documentDirectory.appending(path: "boardView.pdf")
     
        if let consumer = CGDataConsumer(url: renderedUrl as CFURL),
           let pdfContext = CGContext(consumer: consumer, mediaBox: nil, nil) {
     
            let renderer = ImageRenderer(content: ChatView())
            renderer.render { size, renderer in
                let options: [CFString: Any] = [
                    kCGPDFContextMediaBox: CGRect(origin: .zero, size: size)
                ]
     
                pdfContext.beginPDFPage(options as CFDictionary)
     
                renderer(pdfContext)
                pdfContext.endPDFPage()
                pdfContext.closePDF()
            }
        }
     
        print("Saving PDF to \(renderedUrl.path())")
        
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
            switch MenuBarProvider.parseByTitle(title: temp.windowId) {
                case .menuBar: return self.showMenuBar = !self.showMenuBar
                case .info: return self.BEO.showTipViewStatic = !self.BEO.showTipViewStatic
                case .toolbox: return self.BEO.toolBarIsShowing = !self.BEO.toolBarIsShowing
                case .boardSettings: return self.BEO.boardSettingsIsShowing = !self.BEO.boardSettingsIsShowing
                case .lock: return self.handleGestureLock()
                default: return
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
    
    func addWindowsToNavManager() {
//        addSessionPlanWindow()
//        addSessionPlansWindow()
//        addChatWindow()
//        addProfileWindow()
//        addMvSettingsWindow()
    }
    
//    func handleNavPad() {
//        let caller = MenuBarProvider.navHome.tool.title
//        navTools.addNewViewToPool(viewId: caller, viewBuilder: { NavPadView().environmentObject(self.BEO) })
//    }
//    func addChatWindow() {
//        let caller = MenuBarProvider.chat.tool.title
//        navTools.addNewViewToPool(viewId: caller, viewBuilder: {
//            NavStackWindow(id: caller, isFloatable: true, contentBuilder: {
//                ChatView().environmentObject(self.BEO)
//            })
//        })
//    }
//    func addProfileWindow() {
//        let caller = MenuBarProvider.profile.tool.title
//        navTools.addNewViewToPool(viewId: caller, viewBuilder: {
//            NavStackWindow(id: caller, contentBuilder: {
//                SignUpView().environmentObject(self.BEO)
//            })
//        })
//    }
//    func addSessionPlanWindow() {
//        let caller = MenuBarProvider.boardDetails.tool.title
//        navTools.addNewViewToPool(viewId: caller, viewBuilder: {
//            AnyView(NavStackWindow(id: caller, contentBuilder: {
//                SessionPlanView(sessionId: "SOL", isShowing: .constant(true), isMasterWindow: true).environmentObject(self.BEO)
//            }))
//        })
//    }
    func addSessionPlansWindow() {
        let caller = MenuBarProvider.boardCreate.tool.title
        navTools.addView(window: VF.BuildManagedHolder(
            callerId: MenuBarProvider.boardCreate.tool.title,
            mainContent: { HomeDashboardView().environmentObject(self.BEO) },
            sideContent: { EmptyView() }
        ))
//        navTools.addNewNavStackToPool(viewId: caller, viewBuilder: { HomeDashboardView().environmentObject(self.BEO) })
        
    }
    func addMvSettingsWindow() {
//        let caller = "mv_settings"
//        managedWindowsObject.addNewViewToPool(viewId: caller, viewBuilder: {
//            AnyView(NavStackFloatingWindow(id: caller, viewBuilder: {
//                SettingsView(onDelete: {}).environmentObject(self.BEO)
//            }))
//        })
    }
}


