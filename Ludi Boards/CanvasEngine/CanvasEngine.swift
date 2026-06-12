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


public class CanvasEngineControl: ObservableObject {
    
    @AppStorage("showMenuBar", store: UserDefaults(suiteName: "CoreEngine")) public var showMenuBar: Bool = true
    @AppStorage("toolBarPickerWindowIsVisible", store: UserDefaults(suiteName: "CoreEngine")) public var toolBarPickerWindowIsVisible: Bool = false
    @AppStorage("boardSettingsWindowIsVisible", store: UserDefaults(suiteName: "CoreEngine")) public var boardSettingsWindowIsVisible: Bool = false
    @AppStorage("mvSettingsWindowIsVisible", store: UserDefaults(suiteName: "CoreEngine")) public var mvSettingsWindowIsVisible: Bool = false
    
    @AppLifecycle(.appDidEnterBackground) public var appDidEnterBackground: Bool
    @AppStorage("gesturesAreLocked", store: UserDefaults(suiteName: "CoreEngine")) public var gesturesAreLocked: Bool = false
    @Published public var canvasWidth: CGFloat = 8000.0
    @Published public var canvasHeight: CGFloat = 8000.0
    @Published public var canvasOffset = CGPoint(x: 6000, y: 6000)
    @Published public var canvasScale: CGFloat = 0.1
    @Published public var canvasRotation: CGFloat = 0.0
    @GestureState public var gestureScale: CGFloat = 1.0
    @Published public var lastScaleValue: CGFloat = 1.0
    @Published public var angle: Angle = .zero
    @Published public var lastAngle: Angle = .zero
    
    @Published public var dropPosition = CGPoint.zero
    @Published public var coordinates: [String: Any] = [:]
    
    @Published public var translation: CGPoint = CGPoint(x: 6000, y: 6000)
    @Published public var lastOffset = CGPoint(x: 6000, y: 6000)
    @Published public var isDragging: Bool = false
    @Published public var position = CGPoint(x: 0, y: 0)
    
    @Published public var masterResetCanvas: Bool = false
    public func masterResetTheCanvas() {
        self.masterResetCanvas = true
        self.masterResetCanvas = false
    }
    
}

public struct CanvasEngine: View {
    
    @StateObject public var CanvasControl = CanvasEngineControl()
    
    @AppLifecycle(.appDidEnterBackground) public var appDidEnterBackground: Bool
    @StateObject public var navTools: NavWindowController = NavWindowController()
    @ObservedObject public var UTO = UserToolsObservable()
    @ObservedObject public var BEO = BoardEngineObject()
    @ObservedObject public var DO = OrientationInfo()

    @State var storeInMenuBar = Set<AnyCancellable>()
    @State var cancellables = Set<AnyCancellable>()
    @State var canvasCancellables = Set<AnyCancellable>()
    var maxScaleFactor: CGFloat = 1.0
    
    @State private var offsetTwo = CGSize.zero
    @GestureState private var dragOffset = CGSize.zero
    @State public var lastOffset = CGPoint.zero
    
    // Initial size of your drawing canvas
    let initialWidth: CGFloat = 6000
    let initialHeight: CGFloat = 6000
    
    
    
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
    public var alertRecordAnimationMessage: String {
        return "Are you sure you want to \(self.BEO.isRecording ? "Stop" : "Start") recording?"
    }
    
    
    
    @StateObject public var modelPanel = PanelModeController(title: "Testing Mode Panel", subTitle: "Looks to be good to me!")
    @State public var testTrigger = true
    @State public var wrapIsVisible = true
    
    
    @State public var CanvasMenuHeightFull: Double = UIScreen.main.bounds.height
    @State public var CanvasMenuHeightHalf: Double = UIScreen.main.bounds.height / 2
    
    public var body: some View {
        
        GlobalPositioningZStack(coordinateSpace: .global) { windowGPS in
            
            // Screen
            GlobalPositioningReader(coordinateSpace: .global) { geo, gps in
                
                /*
                    1. Canvas Management
                    2. Canvas Global Windows
                    3. Board Management
                 */
                
//                Icons.SystemIcon(icon: .arrowLeft)
//                CanvasMenuView(onTapTop: { CanvasControl.toolBarPickerWindowIsVisible.toggle() })
//                    .environmentObject(gps)
//                    .environmentObject(self.BEO)
//                
//                MvSettingsBar {}
//                    .zIndex(2.0)
//                    .toggleFromBelow($CanvasControl.boardSettingsWindowIsVisible, using: gps, viewHeight: 165)
//                    .environmentObject(self.BEO)
//                    
//                
//                // Left Hand Menu Bar
//                MenuBarStatic(showIcons: $menuIsOpen, gps: gps){}
//                // Navigation Window
//                navTools.getNavStackView()
                                
//                DynaWrap(id: "dynaWrapFloatingButtons") {
//                    FloatingProfileView(profileImageDiameter: 360, orbitRadius: 300)
//                }
//                FloatingSocialView()
                
//                self.modelPanel.Display(.center)
                
//                TimedView($testTrigger, seconds: 10) {
//                    NotificationPanel(message: self.$notificationMessage, icon: self.$notificationIcon)
//                        .position(using: gps, at: .topCenter, offsetX: 0, offsetY: 75)
//                }
                
//                ModePanel(title: "Your Current Activity", subTitle: self.BEO.currentActivityId, showButton: false, isFlashing: true)
//                    .position(using: gps, at: .topRight, offsetX: 200, offsetY: 50)
                
            }.zIndex(2.0)
            
            // Board
            GlobalPositioningZStack(coordinateSpace: CoreNameSpace.canvas.name, width: 20000, height: 20000) { cGps in
                
                if !CanvasControl.masterResetCanvas {
                    BoardEngine()
                        .zIndex(0.0)
                        .environmentObject(self.BEO)
                        .environmentObject(self.navTools)

                }

            }
            .offset(x: self.BEO.canvasOffset.x, y: self.BEO.canvasOffset.y)
            .scaleEffect(self.BEO.canvasScale)
            .rotationEffect(Angle(degrees: self.BEO.canvasRotation))
            .zIndex(0.0)

        }
        .zIndex(1.0)
        .background(Color.black.opacity(0.0001))
        .gesture(dragAngleGestures.simultaneously(with: scaleGestures))
//        .background(StarryNightAnimatedView())
        .onAppear() {
            _appDidEnterBackground.onChange = {
                print("YESSSS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            }
            addViewsToNavStack()
            BroadcastTools.listenForCanvasCalls(storeIn: &canvasCancellables, onEvent: { action in
                if action == CanvasAction.refresh {
                    self.CanvasControl.masterResetTheCanvas()
                }
                else if action == CanvasAction.closeWindows {
                    closeAllWindows()
                }
            })
            BroadcastTools.listenForWindowCalls(storeIn: &storeInMenuBar, onEvent: { id, action in
                print("ID!!!!! \(id)")
                switch id {
                    case "toolbox":
                        if action == WindowAction.open {
                            closeAllWindows()
                            self.CanvasControl.toolBarPickerWindowIsVisible = true
                        }
                        else if action == WindowAction.close {
                            closeAllWindows()
                        }
                        else if action == WindowAction.toggle {
                            self.CanvasControl.toolBarPickerWindowIsVisible.toggle()
                        }
                    case "board settings":
                        if action == WindowAction.open {
                            closeAllWindows()
                            self.CanvasControl.boardSettingsWindowIsVisible = true
                        }
                        else if action == WindowAction.close {
                            closeAllWindows()
                        }
                        else if action == WindowAction.toggle {
                            self.CanvasControl.boardSettingsWindowIsVisible.toggle()
                        }
                    case "mvsettings":
                        if action == WindowAction.open {
                            closeAllWindows()
                            self.CanvasControl.mvSettingsWindowIsVisible = true
                        }
                        else if action == WindowAction.close {
                            closeAllWindows()
                        }
                        else if action == WindowAction.toggle {
                            self.CanvasControl.mvSettingsWindowIsVisible.toggle()
                        }
                    default: return
                }
            })
        }
    }
    
    func closeAllWindows() {
        CanvasControl.boardSettingsWindowIsVisible = false
        CanvasControl.toolBarPickerWindowIsVisible = false
        CanvasControl.mvSettingsWindowIsVisible = false
    }
    
    func addViewsToNavStack() {
        
        //
        navTools.addView(
            callerId: MenuBarProvider.home.tool.title,
            mainContent: { HomeDashboardView().environmentObject(self.BEO) },
            sideContent: { MenuListView(isShowing: .constant(true)).clearSectionBackground() }
        )
        // Profile
        navTools.addView(
            callerId: MenuBarProvider.profile.tool.title,
            mainContent: { SignUpView() },
            sideContent: { EmptyView() }
        )
        
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
            guard let temp = controller as? WindowController else { return }
            switch MenuBarProvider.parseByTitle(title: temp.windowId) {
            case .menuBar: return self.CanvasControl.showMenuBar = !self.CanvasControl.showMenuBar
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

    func addSessionPlansWindow() {
        let caller = MenuBarProvider.home.tool.title
        navTools.addView(window: VF.BuildManagedHolder(
            callerId: MenuBarProvider.home.tool.title,
            mainContent: { HomeDashboardView().environmentObject(self.BEO) },
            sideContent: { EmptyView() }
        ))
//        navTools.addNewNavStackToPool(viewId: caller, viewBuilder: { HomeDashboardView().environmentObject(self.BEO) })
    }
    
    
    var dragAngleGestures: some Gesture {
        DragGesture()
            .onChanged { gesture in
//                if self.CanvasControl.gesturesAreLocked { return }

                // Simplify calculations and potentially invert them
                let translation = gesture.translation
                let cosAngle = cos(Angle(degrees: self.CanvasControl.canvasRotation).radians)
                let sinAngle = sin(Angle(degrees: self.CanvasControl.canvasRotation).radians)

                // Invert the translation adjustments
                let adjustedX = cosAngle * translation.width + sinAngle * translation.height
                let adjustedY = -sinAngle * translation.width + cosAngle * translation.height
                let rotationAdjustedTranslation = CGPoint(x: adjustedX, y: adjustedY)

                let offsetX = self.lastOffset.x + (rotationAdjustedTranslation.x / self.CanvasControl.canvasScale)
                let offsetY = self.lastOffset.y + (rotationAdjustedTranslation.y / self.CanvasControl.canvasScale)
                self.CanvasControl.canvasOffset = CGPoint(x: offsetX, y: offsetY)
            }
            .onEnded { _ in
//                if self.CanvasControl.gesturesAreLocked { return }
                self.lastOffset = self.CanvasControl.canvasOffset
            }
            .updating($dragOffset) { value, state, _ in
//                if self.CanvasControl.gesturesAreLocked { return }
                state = value.translation
            }
    }
    
    var scaleGestures: some Gesture {
        MagnificationGesture()
            .onChanged { value in
//                if self.CanvasControl.gesturesAreLocked { return }
                let delta = value / self.BEO.lastScaleValue
                self.CanvasControl.canvasScale *= delta
                self.CanvasControl.lastScaleValue = value
            }
            .onEnded { value in
//                if self.CanvasControl.gesturesAreLocked { return }
                self.CanvasControl.lastScaleValue = 1.0
            }
    }
    
    var rotationGestures: some Gesture {
        RotationGesture()
            .onChanged { value in
                let scaledAngle = (value - self.CanvasControl.lastAngle) * 0.5
                self.CanvasControl.angle = self.CanvasControl.lastAngle + scaledAngle
            }
            .onEnded { value in
                self.CanvasControl.lastAngle += value // Update the last angle on gesture end
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
        self.CanvasControl.gesturesAreLocked = true
//        self.toolBarIsShowing = false
        self.CanvasControl.showMenuBar = false
    }
    
    func disableDrawing() {
        self.BEO.isDraw = false
        self.CanvasControl.gesturesAreLocked = false
//        self.BEO.toolBarIsShowing = true
        self.CanvasControl.showMenuBar = true
    }

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

//        .onChange(of: self.DO.orientation) {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                masterResetTheCanvas()
//            }
//        }
//        .onChange(of: self.BEO.toolBarIsShowing) {
//            if self.BEO.toolBarIsShowing {
//                self.BEO.toolSettingsIsShowing = false
//            }
//        }
//        .onChange(of: self.BEO.toolSettingsIsShowing) {
//            if self.BEO.toolSettingsIsShowing {
//                self.BEO.toolBarIsShowing = false
//            }
//        }


struct DraggableView: View {
    // State variables to control the position of the view
    @State private var position: CGPoint = CGPoint(x: UIScreen.main.bounds.width * 0.92, y: UIScreen.main.bounds.height * 0.5)
    @State private var lastDragValue: CGFloat = 0

    // Constants for open and closed positions
    let closedOffset: CGFloat = UIScreen.main.bounds.height + 500
    let openOffset: CGFloat = UIScreen.main.bounds.height * 0.5

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer() // Fills the empty space
                RoundedRectangle(cornerRadius: 16)
//                    .fill(Color.blue)
                    .frame(width: UIScreen.main.bounds.width * 0.95, height: UIScreen.main.bounds.height) // Covers 50% of the screen
                    .solBackground()
                    .position(x: position.x + 100, y: position.y + 500)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // Update the view's position based on drag amount
                                mainAnimation {
                                    self.position.y = self.lastDragValue + value.translation.height
                                }
                            }
                            .onEnded { _ in
                                // Snap to open or closed state
                                if self.position.y <= (self.closedOffset + self.openOffset) / 2 {
                                    self.position.y = self.openOffset
                                } else {
                                    self.position.y = self.closedOffset
                                }
                                self.lastDragValue = self.position.y
                            }
                    )
            }
            
//            .frame(width: UIScreen.main.bounds.width * 0.9, height: geometry.size.height * 0.5) // Covers 50% of the screen
        }
        .edgesIgnoringSafeArea(.all) // Allows the view to extend into the safe area
    }
}


// MARK: - Modifier for Draggable and Positionable View
struct DraggablePositionableModifier: ViewModifier {
    @State private var position: CGPoint = .zero
    @State private var lastDragValue: CGSize = .zero

    let gps: GlobalPositioningSystem
    let area: ScreenArea
    let offsetX: CGFloat
    let offsetY: CGFloat
    let safePadding: Bool

    // Locking Positions
    let topY: CGFloat
    let bottomY: CGFloat

    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
                .position(using: gps, at: area, offsetX: offsetX, offsetY: offsetY)
                .offset(x: position.x, y: position.y)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Update the view's position based on drag amount
                            self.position.y = self.lastDragValue.height + value.translation.height

                            // Ensure the position stays within the locked range
                            if self.position.y < self.topY {
                                self.position.y = self.topY
                            } else if self.position.y > self.bottomY {
                                self.position.y = self.bottomY
                            }
                        }
                        .onEnded { _ in
                            // Snap to the nearest locked position
                            if abs(self.position.y - self.topY) < abs(self.position.y - self.bottomY) {
                                self.position.y = self.topY
                            } else {
                                self.position.y = self.bottomY
                            }
                            self.lastDragValue = CGSize(width: self.position.x, height: self.position.y)
                        }
                )
        }
        .onAppear {
            // Initialize the starting position to the bottom position
            self.position = CGPoint(x: 0, y: bottomY)
            self.lastDragValue = CGSize(width: 0, height: bottomY)
        }
    }
}

// MARK: - Extension for Position and Drag Modifier
extension View {
    func draggablePositionable(
        using gps: GlobalPositioningSystem,
        at area: ScreenArea,
        offsetX: CGFloat = 0,
        offsetY: CGFloat = 0,
        safePadding: Bool = true,
        topY: CGFloat = UIScreen.main.bounds.height * 0.5, // Default open position
        bottomY: CGFloat = UIScreen.main.bounds.height - 50 // Default closed position just above bottom
    ) -> some View {
        self.modifier(DraggablePositionableModifier(gps: gps, area: area, offsetX: offsetX, offsetY: offsetY, safePadding: safePadding, topY: topY, bottomY: bottomY))
    }
}

// MARK: - Example Usage
struct ContentVieweeee: View {
    var body: some View {
        GlobalPositioningReader(coordinateSpace: .global) { geo, gps in
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue)
                .frame(width: UIScreen.main.bounds.width * 0.95, height: UIScreen.main.bounds.height * 0.5)
                .draggablePositionable(using: gps, at: .bottomCenter, offsetX: 35, offsetY: 150, topY: UIScreen.main.bounds.height * 0.5, bottomY: UIScreen.main.bounds.height - 100)
        }
    }
}


// MARK: - Draggable View Modifier
struct DraggableViewModifier: ViewModifier {
    @State private var position: CGPoint = .zero
    @State private var lastDragValue: CGSize = .zero

    let openPosition: CGPoint
    let closedPosition: CGPoint

    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
                .offset(x: position.x, y: position.y)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Update the view's position based on drag amount
                            self.position.y = self.lastDragValue.height + value.translation.height

                            // Ensure the position stays within the locked range
                            if self.position.y < openPosition.y {
                                self.position.y = openPosition.y
                            } else if self.position.y > closedPosition.y {
                                self.position.y = closedPosition.y
                            }
                        }
                        .onEnded { _ in
                            // Snap to the nearest locked position
                            if abs(self.position.y - openPosition.y) < abs(self.position.y - closedPosition.y) {
                                self.position.y = openPosition.y
                            } else {
                                self.position.y = closedPosition.y
                            }
                            self.lastDragValue = CGSize(width: self.position.x, height: self.position.y)
                        }
                )
        }
        .onAppear {
            // Initialize the starting position to the closed position
            self.position = CGPoint(x: 0, y: closedPosition.y)
            self.lastDragValue = CGSize(width: 0, height: closedPosition.y)
        }
    }
}

// MARK: - Extension for Draggable Modifier
extension View {
    func draggable(
        from openPosition: CGPoint,
        to closedPosition: CGPoint
    ) -> some View {
        self.modifier(DraggableViewModifier(openPosition: openPosition, closedPosition: closedPosition))
    }
}
