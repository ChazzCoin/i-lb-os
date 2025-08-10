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
    @StateObject var BEO = BoardEngineObject()
    @StateObject var navTools: NavWindowController = NavWindowController()
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
    @State var menuIsOpen: Bool = false
    
    var body: some View {
        GlobalPositioningZStack(coordinateSpace: CoreNameSpace.local) { windowGPS in
            
            GlobalPositioningReader(coordinateSpace: CoreNameSpace.global) { geo, gps in
                
                // Left Hand Menu Bar
                MenuBarStatic(showIcons: $menuIsOpen, gps: gps){}
                // Navigation Window
                navTools.getNavStackView()
                    
//                FloatingFusedRoomManagerView()
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
                
            }.zIndex(35.0)
            
            GlobalPositioningReader(coordinateSpace: CoreNameSpace.canvas, width: 20000, height: 20000) { cGeo, cGps in
                // Board/Canvas Level
                BoardEngine()
                    .zIndex(2.0)
                    .environmentObject(self.BEO)
                    .frame(width: 20000, height: 20000)
                    .offset(x: self.BEO.canvasOffset.x, y: self.BEO.canvasOffset.y)
                    .scaleEffect(self.BEO.canvasScale)
                    .rotationEffect(Angle(degrees: self.BEO.canvasRotation))
                    .zIndex(1.0)
            }
            .zIndex(0.0)
            .background(DynamicGradientBackground())
            .gesture(self.BEO.gesturesAreLocked ? nil : dragAngleGestures.simultaneously(with: scaleGestures))
        }
        .onAppear() {
            if self.USER.currentUserId.isEmpty {
                print("Setting New User ID")
                self.USER.currentUserId = generateRandomUserId()
            }
            navTools.addView(
                callerId: MenuBarProvider.home.tool.title,
                mainContent: { RoomChatView(fusedRoom: fusedRoom).environmentObject(self.BEO) },
                sideContent: { EmptyView() }
            )
            navTools.addView(
                callerId: MenuBarProvider.info.tool.title,
                mainContent: { BinauralSoundView().environmentObject(self.USER) },
                sideContent: { EmptyView() }
            )
        }
        
//        GlobalPositioningZStack { geo, gps in
            
//            BinauralSoundView()
                
            
//            CoreSignUpView()
//                .position(gps.getCoordinate(for: .bottomCenter))
//            MusicPlayerView()
//                .frame(width: 500, height: 500)
//                .background(Color.white)
//                .position(gps.getCoordinate(for: .center))
//            FloatingSocialView()
//            FloatingFusedRoomManagerView()
//            navTools.getNavStackView()
//        }
//        .zIndex(3.0)
        
//        ZStack() {
//            // Board/Canvas Level
//            ZStack() {
//                
//                
//                
//                BoardEngine()
//                    .zIndex(2.0)
//                    .environmentObject(self.BEO)
//                
//            }
//            .frame(width: 20000, height: 20000)
//            .offset(x: self.BEO.canvasOffset.x, y: self.BEO.canvasOffset.y)
//            .scaleEffect(self.BEO.canvasScale)
//            .rotationEffect(Angle(degrees: self.BEO.canvasRotation))
//            .zIndex(1.0)
//            
//        }
//        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
////        .background(Color.purple.opacity(0.5))
////        .background(StarryNightAnimatedView())
//        .background(DynamicGradientBackground())
////        .background(DrawGridLines())
////        .background(DynamicGradientBackground())
//        .gesture(self.BEO.gesturesAreLocked ? nil : dragAngleGestures.simultaneously(with: scaleGestures))
//        .zIndex(0.0)
//        .onAppear() {
//            //
//            navTools.addView(
//                callerId: MenuBarProvider.activity.tool.title,
//                mainContent: { RoomChatView(fusedRoom: fusedRoom).environmentObject(self.BEO) },
//                sideContent: { EmptyView() }
//            )
//            // Profile
////            navTools.addView(
////                callerId: MenuBarProvider.profile.tool.title,
////                mainContent: { CoreSignUpView() },
////                sideContent: { EmptyView() }
////            )
//            
//           
////            navTools.mainState = .open
//            
////            navTools.navTo(viewId: MenuBarProvider.activity.tool.title)
//        }
        
    }
    
}



