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

    // NOTE: The canvas transform (offset/scale/rotation) is owned solely by
    // BoardEngineObject (BEO). The gestures below write BEO and the canvas
    // renders BEO — keep it that way. Do not reintroduce transform state here.

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
    @StateObject public var UTO = UserToolsObservable()
    @StateObject public var BEO = BoardEngineObject()
    @StateObject public var DO = OrientationInfo()

    @State var storeInMenuBar = Set<AnyCancellable>()
    @State var cancellables = Set<AnyCancellable>()
    @State var canvasCancellables = Set<AnyCancellable>()
    @State private var didWireListeners = false
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
            
            // Screen-level chrome (menus, nav window, floating panels) is wired
            // here when re-enabled — currently the canvas renders the board only.
            GlobalPositioningReader(coordinateSpace: .global) { geo, gps in
                EmptyView()
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
            if self.didWireListeners { return }
            self.didWireListeners = true
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
            let temp = controller as! WindowController
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
                if self.CanvasControl.gesturesAreLocked { return }

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
                if self.CanvasControl.gesturesAreLocked { return }
                self.lastOffset = self.BEO.canvasOffset
            }
            .updating($dragOffset) { value, state, _ in
                if self.CanvasControl.gesturesAreLocked { return }
                state = value.translation
            }
    }

    var scaleGestures: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if self.CanvasControl.gesturesAreLocked { return }
                let delta = value / self.BEO.lastScaleValue
                self.BEO.canvasScale *= delta
                self.BEO.lastScaleValue = value
            }
            .onEnded { value in
                if self.CanvasControl.gesturesAreLocked { return }
                self.BEO.lastScaleValue = 1.0
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
