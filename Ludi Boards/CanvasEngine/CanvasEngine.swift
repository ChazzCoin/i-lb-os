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
    
    @State var masterResetCanvas = false
    func masterResetTheCanvas() {
        self.masterResetCanvas = true
        self.masterResetCanvas = false
    }
    
    
    
    var body: some View {
        
//        let boardView = BoardEngine()
//            .zIndex(2.0)
//            .environmentObject(self.BEO)
        
        if !masterResetCanvas {
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
                MenuBarStatic(showIcons: $menuIsOpen, gps: gps){}
                
                // Navigation Bar
                NavPadView()
                    .environmentObject(self.BEO)
                    .position(using: gps, at: .bottomCenter, offsetX: 0, offsetY: 150)
                
                if !self.managedWindowsObject.reload {
                    ForEachActiveManagedWindow(managedWindowsObject: managedWindowsObject)
//                    ForEach(Array(managedWindowsObject.activeViews.keys), id: \.self) { key in
//                        managedWindowsObject.getView(withId: key)
//                            .viewBuilder()
//                            .zIndex(50.0)
//                            .environmentObject(self.BEO)
//                    }
                }
                
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
                
                // Tool Bar
                if self.BEO.toolBarIsShowing && !self.BEO.screenIsActiveAndLocked() {
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
                    .zIndex(2.0)
                    .position(using: gps, at: .bottomCenter, offsetY: 50)
                    .environmentObject(self.BEO)
                }
                
                // Drawing Mode Popup
                if self.BEO.isPlayingAnimation {
                    GeometryReader { geo in
                        ModePanel(title: "Playing in Progress...", subTitle: "Playback Mode.", showButton: true) {
                            self.BEO.stopAnimationRecording()
                        }
                    }
                    .frame(width: 300)
                    .position(using: gps, at: .topRight, offsetX: 150, offsetY: 0)
                }
                
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
                        NotificationPanel(message: self.$notificationMessage, icon: self.$notificationIcon)
                    }
                    .zIndex(50.0)
                    .position(using: gps, at: .topRight, offsetX: 150, offsetY: 0)
                }
                
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
            .onChange(of: self.DO.orientation, perform: { value in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    masterResetTheCanvas()
                }
            })
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
            .onAppear() {
                self.BEO.loadUser()
                menuBarButtonListener()
                addWindowsToNavManager()
                
                
//                if let results = newRealm().findByField(CoreUser.self, field: "", value: "") {
//                    print("The Old way... -> \(results)")
//                }
//                FusedTools.findByField(CoreUser.self, value: "ckrphone@gmail.com", field: "email") { results in
//                    print("Fused this bitch up!!! -> \(results)")
//                }
                
                
//                if let user = UserTools.user {
//                    fusedWriter { r in
//                        user.name = "Johnny Law Dog"
//                        return user
//                    }
//                }
//                UserTools.login(email: "chazzromeo@gmail.com", password: "soccer23", onResult: { _ in
//                    if let user = UserTools.user {
//                        newRealm().safeWrite { r in
//                            user.handle = "YESSSSSSSSSSS"
//                            FusedDB.saveToFirebase(item: user)
//                        }
//                    }
//                }, onError: { _ in
//                    print("failed to login")
//                })
                
                
                
                
            }
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
        addSessionPlanWindow()
        addSessionPlansWindow()
        addChatWindow()
        addProfileWindow()
        addMvSettingsWindow()
    }
    
    func handleNavPad() {
        let caller = MenuBarProvider.navHome.tool.title
        managedWindowsObject.addNewViewToPool(viewId: caller, viewBuilder: { NavPadView().environmentObject(self.BEO) })
    }
    func addChatWindow() {
        let caller = MenuBarProvider.chat.tool.title
        managedWindowsObject.addNewViewToPool(viewId: caller, viewBuilder: {
            NavStackWindow(id: caller, isFloatable: true, contentBuilder: {
                ChatView().environmentObject(self.BEO)
            })
        })
    }
    func addProfileWindow() {
        let caller = MenuBarProvider.profile.tool.title
        managedWindowsObject.addNewViewToPool(viewId: caller, viewBuilder: {
            NavStackWindow(id: caller, contentBuilder: {
                SignUpView().environmentObject(self.BEO)
            })
        })
    }
    func addSessionPlanWindow() {
        let caller = MenuBarProvider.boardDetails.tool.title
        managedWindowsObject.addNewViewToPool(viewId: caller, viewBuilder: {
            AnyView(NavStackWindow(id: caller, contentBuilder: {
                SessionPlanView(sessionId: "SOL", isShowing: .constant(true), isMasterWindow: true).environmentObject(self.BEO)
            }))
        })
    }
    func addSessionPlansWindow() {
        let caller = MenuBarProvider.boardCreate.tool.title
        managedWindowsObject.addNewViewToPool(viewId: caller, viewBuilder: {
            AnyView(NavStackWindow(id: caller, contentBuilder: {
                HomeDashboardView().environmentObject(self.BEO)
            }))
        })
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


