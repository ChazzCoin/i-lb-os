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
    
    @EnvironmentObject public var USER: UserToolsObservable
    @StateObject public var fusedRoom = FusedRoom()
    @StateObject public var BEO = BoardEngineObject()
    @StateObject public var navTools: NavWindowController = NavWindowController()
    @StateObject public var nodeTools: NodeWindowController = NodeWindowController()
    @ObservedObject public var MVEngine: ManagedViewEngine = ManagedViewEngine(bounds: CGRect(origin: .zero, size: CGSize(width: 20000.0, height: 20000.0)))
    @State public var cancellables = Set<AnyCancellable>()
    @State public var showMenuBar: Bool = false
    @State public var popupIsVisible: Bool = true
    public var maxScaleFactor: CGFloat = 1.0
    
    @State public var angle: Angle = .zero
    @State public var lastAngle: Angle = .zero
    
    @State public var translation: CGPoint = .zero
    @State public var lastOffset = CGPoint.zero
    
    @State public var offsetTwo = CGSize.zero
    @State public var isDragging = false
    @State public var toolBarIsEnabled = true
    @State public var position = CGPoint(x: 0, y: 0) // Initial position
    @GestureState public var dragOffset = CGSize.zero
    
    @State public var menuIsOpen: Bool = false
    
    @State var storeInMenuBar = Set<AnyCancellable>()
    
    @State var idone = UUID()
    
    @State var canvasOneRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: 20000.0, height: 20000.0))
    @State var canvasTwoRect = CGRect(origin: CGPoint(x: 20000.0, y: 0.0), size: CGSize(width: 20000.0, height: 20000.0))
    
    public var body: some View {
        GlobalPositioningZStack(coordinateSpace: CoreNameSpace.local.name, width: 50000, height: 50000) { windowGPS in
            
            // Screen/Window Level
            GlobalPositioningReader(coordinateSpace: CoreNameSpace.global) { geo, gps in
                // Left Hand Menu Bar
                CoreCanvasMenuView(onTapTop: { menuIsOpen.toggle() })
                    .environmentObject(gps)
                    .environmentObject(self.BEO)
                // Navigation Window
                navTools.getNavStackView().zIndex(100.0)
//                nodeTools.displayFullScreenView().zIndex(100.0)
            }
            .zIndex(2.0)
            
            // Board/Canvas Level
            GlobalPositioningZStack(coordinateSpace: CoreNameSpace.canvas.name, width: 20000, height: 20000) { cGps in
                
                ZStack {
                    AwakeningBanner(
                        title: "Welcome to the Awakening",
                        subtitle: "Go on, explore.",
                        position: CGPoint(x: 0.0, y: 0.0),
                        maxWidth: 1000,                 // fits your 20k canvas nicely
                        cornerRadius: 1600,
                        canvasScale: 7.0     // pass your live zoom to keep strokes crisp
                    )
                }
                .zIndex(2.0)
                .scaleEffect(7.0)
                .position(CGPoint(x: 0.0, y: 0.0))
                
                MVEngine.Display().zIndex(2.0)
                
                WindowManagerView {
                    BinauralSoundView()
                        .environmentObject(self.USER)
                }
                .zIndex(2.0)
                .frame(width: 1000, height: 1500)
                .scaleEffect(7.0)
                .position(CGPoint(x: 20000.0, y: 20000.0))

            }
            .offset(x: self.BEO.canvasOffset.x, y: self.BEO.canvasOffset.y)
            .scaleEffect(self.BEO.canvasScale)
            .rotationEffect(Angle(degrees: self.BEO.canvasRotation))
            .zIndex(0.0)
            
            // Board/Canvas Level
            GlobalPositioningZStack(coordinateSpace: CoreNameSpace.canvas.name, width: 20000, height: 20000) { cGps in
                
                nodeTools.displayAllNodes().zIndex(5.0)
                BoardEngineView()
                    .zIndex(0.0)
        

            }

            }
            .offset(x: self.BEO.canvasOffset.x + 20000.0, y: self.BEO.canvasOffset.y)
            .scaleEffect(self.BEO.canvasScale)
            .rotationEffect(Angle(degrees: self.BEO.canvasRotation))
            .zIndex(0.0)
            
        }
        .zIndex(1.0)
        .background(Color.white.opacity(0.0001))
        .gesture(self.BEO.gesturesAreLocked ? nil : dragAngleGestures.simultaneously(with: scaleGestures))
        .onDoubleTap() {
            self.BEO.canvasScale -= 0.01
        }
        .onAppear() {
            if self.BEO.isPad {
                self.BEO.canvasScale = 0.1
            } else {
                self.BEO.canvasScale = 0.03
            }
            if self.USER.currentUserId.isEmpty {
                print("Setting New User ID")
                self.USER.currentUserId = generateRandomUserId()
                self.USER.currentUserName = generateRandomName()
            }
            self.fusedRoom.startUp()
            
            nodeTools.addView(
                callerId: MenuBarProvider.chat.tool.title,
                mainContent: { RoomChatView(fusedRoom: fusedRoom).environmentObject(self.BEO) },
                sideContent: { EmptyView() }
            )
            nodeTools.addView(
                callerId: "media_player",
                mainContent: { MusicPlayerView() },
                sideContent: { EmptyView() }
            )
            
            navTools.addView(
                callerId: MenuBarProvider.buddyList.tool.title,
                mainContent: {  UsersListView().environmentObject(self.BEO) },
                sideContent: { EmptyView() }
            )
            navTools.addView(
                callerId: MenuBarProvider.toolbox.tool.title,
                mainContent: {  RoomWindow().environmentObject(self.fusedRoom) },
                sideContent: { EmptyView() }
            )
            navTools.addView(
                callerId: MenuBarProvider.chat.tool.title,
                mainContent: { RoomChatView(fusedRoom: fusedRoom).environmentObject(self.BEO) },
                sideContent: { EmptyView() }
            )
            navTools.addView(
                callerId: MenuBarProvider.info.tool.title,
                mainContent: { BinauralSoundView().environmentObject(self.USER) },
                sideContent: { EmptyView() }
            )
            navTools.addView(
                callerId: MenuBarProvider.profile.tool.title,
                mainContent: { CoreProfileView().environmentObject(self.USER) },
                sideContent: { EmptyView() }
            )

            
            BroadcastTools.listenForNodeStreams(storeIn: &storeInMenuBar, onEvent: { stream in
                print("Node Stream: \(stream.id) - \(stream.position)")
            })
            
            BroadcastTools.listenForWindowCalls(storeIn: &storeInMenuBar, onEvent: { id, action in
                print("ID!!!!! \(id)")
                switch id {
                    case "toolbox":
                        if action == WindowAction.open {
                            closeAllWindows()
                            self.BEO.toolBarPickerWindowIsVisible = true
                        }
                        else if action == WindowAction.close {
                            closeAllWindows()
                        }
                        else if action == WindowAction.toggle {
                            self.BEO.toolBarPickerWindowIsVisible.toggle()
                        }
                    case "board settings":
                        if action == WindowAction.open {
                            closeAllWindows()
                            self.BEO.boardSettingsWindowIsVisible = true
                        }
                        else if action == WindowAction.close {
                            closeAllWindows()
                        }
                        else if action == WindowAction.toggle {
                            self.BEO.boardSettingsWindowIsVisible.toggle()
                        }
                    case MenuBarProvider.chat.tool.title:
                        if action == WindowAction.open {
                            closeAllWindows()
                            self.BEO.mvSettingsWindowIsVisible = true
                        }
                        else if action == WindowAction.close {
                            closeAllWindows()
                        }
                        else if action == WindowAction.toggle {
                            self.BEO.mvSettingsWindowIsVisible.toggle()
                        }
                    default: return
                }
            })
        }
        
    }
    
    public func closeAllWindows() {
        self.BEO.boardSettingsWindowIsVisible = false
        self.BEO.toolBarPickerWindowIsVisible = false
        self.BEO.mvSettingsWindowIsVisible = false
    }
    
    // Gestures
    public var dragAngleGestures: some Gesture {
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
    
    public var scaleGestures: some Gesture {
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
    
    public var rotationGestures: some Gesture {
        RotationGesture()
            .onChanged { value in
                let scaledAngle = (value - self.lastAngle) * 0.5
                self.angle = self.lastAngle + scaledAngle
            }
            .onEnded { value in
                self.lastAngle += value // Update the last angle on gesture end
            }
    }
    

    
}

