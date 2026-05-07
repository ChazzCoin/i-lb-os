//
//  CanvasView.swift
//  CoreEngine
//
//  Created by Charles Romeo on 1/26/26.
//

import Foundation
import SwiftUI
import Combine


public struct CanvasEngine: View {
    
    @EnvironmentObject public var USER: UserToolsObservable
    @StateObject public var CanvasControl = CoreCanvasControl()
    @StateObject public var navTools: NavWindowController = NavWindowController()
    @State public var cancellables = Set<AnyCancellable>()
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
    
    // Initial size of your drawing canvas
    let initialWidth: CGFloat = 6000
    let initialHeight: CGFloat = 6000

    
    public var body: some View {
        GlobalPositioningZStack(coordinateSpace: CoreNameSpace.local) { windowGPS in
            
            // Screen/Window Level
            GlobalPositioningReader(coordinateSpace: CoreNameSpace.global) { geo, gps in
                // Navigation Window
                navTools.getNavStackView()
            }
            .zIndex(35.0)
            
            // Board/Canvas Level
            GlobalPositioningReader(coordinateSpace: CoreNameSpace.canvas, width: 20000, height: 20000) { cGeo, cGps in
                
                    
            }
            .zIndex(0.0)
        }
        .gesture(self.CanvasControl.gesturesAreLocked ? nil : dragAngleGestures.simultaneously(with: scaleGestures))
        .onAppear() {
            if self.CanvasControl.isPad {
                self.CanvasControl.canvasScale = 0.1
            } else {
                self.CanvasControl.canvasScale = 0.03
            }
            if self.USER.currentUserId.isEmpty {
                print("Setting New User ID")
                self.USER.currentUserId = generateRandomUserId()
                self.USER.currentUserName = generateRandomName()
            }

        }
        
    }
    
    // Gestures
    public var dragAngleGestures: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if self.CanvasControl.gesturesAreLocked { return }

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
                if self.CanvasControl.gesturesAreLocked { return }
                self.lastOffset = self.CanvasControl.canvasOffset
            }
            .updating($dragOffset) { value, state, _ in
                if self.CanvasControl.gesturesAreLocked { return }
                state = value.translation
            }
    }
    
    public var scaleGestures: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if self.CanvasControl.gesturesAreLocked { return }
                let delta = value / self.CanvasControl.lastScaleValue
                self.CanvasControl.canvasScale *= delta
                self.CanvasControl.lastScaleValue = value
            }
            .onEnded { value in
                if self.CanvasControl.gesturesAreLocked { return }
                self.CanvasControl.lastScaleValue = 1.0
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
