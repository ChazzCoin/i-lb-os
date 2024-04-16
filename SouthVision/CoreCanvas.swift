//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/8/24.
//

import Foundation
import SwiftUI

public struct SpaceCanvasEngine<G: View, C: View>: View {
    public var global: (GeometryProxy) -> G
    public var canvas: (CanvasGPS) -> C
    public init(@ViewBuilder global: @escaping (GeometryProxy) -> G, @ViewBuilder canvas: @escaping (CanvasGPS) -> C) {
        self.global = global
        self.canvas = canvas
    }
    
//    @StateObject public var managedWindowsObject: NavWindowController = NavWindowController()
//    @ObservedObject public var DO = OrientationInfo()
    @AppStorage("gesturesAreLocked") public var gesturesAreLocked: Bool = false
    @AppStorage("isLoading") public var isLoading: Bool = false
    @State public var maxScaleFactor: CGFloat = 1.0
    @State public var canvasRotation: CGFloat = .zero
    @State public var canvasScale: CGFloat = 1.0
    @State public var lastScaleValue: CGFloat = 1.0
    @State public var canvasOffset = CGPoint.zero
    @State public var lastOffset = CGPoint.zero
    @State public var angle: Angle = .zero
    @State public var lastAngle: Angle = .zero
    @GestureState public var dragOffset = CGSize.zero
    
    // Initial size of your drawing canvas
    public let initialWidth: CGFloat = 10000
    public let initialHeight: CGFloat = 10000
    
    public var dragAngleGestures: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if self.gesturesAreLocked { return }

                // Simplify calculations and potentially invert them
                let translation = gesture.translation
                let cosAngle = cos(Angle(degrees: self.canvasRotation).radians)
                let sinAngle = sin(Angle(degrees: self.canvasRotation).radians)

                // Invert the translation adjustments
                let adjustedX = cosAngle * translation.width + sinAngle * translation.height
                let adjustedY = -sinAngle * translation.width + cosAngle * translation.height
                let rotationAdjustedTranslation = CGPoint(x: adjustedX, y: adjustedY)

                let offsetX = self.lastOffset.x + (rotationAdjustedTranslation.x / self.canvasScale)
                let offsetY = self.lastOffset.y + (rotationAdjustedTranslation.y / self.canvasScale)
                self.canvasOffset = CGPoint(x: offsetX, y: offsetY)
            }
            .onEnded { _ in
                if self.gesturesAreLocked { return }
                self.lastOffset = self.canvasOffset
            }
            .updating($dragOffset) { value, state, _ in
                if self.gesturesAreLocked { return }
                state = value.translation
            }
    }
    
    public var scaleGestures: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if self.gesturesAreLocked { return }
                let delta = value / self.lastScaleValue
                self.canvasScale *= delta
                self.lastScaleValue = value
            }
            .onEnded { value in
                if self.gesturesAreLocked { return }
                self.lastScaleValue = 1.0
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
    
    @State var masterResetCanvas = false
    public func masterResetTheCanvas() {
        self.masterResetCanvas = true
        self.masterResetCanvas = false
    }
    
    public var body: some View {
        
        if !masterResetCanvas {
            
            GeometryReader { geo in
                global(geo)
            }
            .zIndex(3.0)
            
            ZStack() {
                // Board/Canvas Level
                
                CanvasPositioningZStack { gps in
                    canvas(gps)
                }
                .offset(x: self.canvasOffset.x, y: self.canvasOffset.y)
                .scaleEffect(self.canvasScale)
                .rotationEffect(Angle(degrees: self.canvasRotation))
                
            }
            .zIndex(0.0)
            .frame(width: self.initialWidth, height: self.initialHeight)
            .blur(radius: self.isLoading ? 10 : 0)
//            .background(DrawGridLines())
            .background(Color.white.opacity(0.001))
            .gesture(self.gesturesAreLocked ? nil : dragAngleGestures.simultaneously(with: scaleGestures))
//            .onChange(of: self.DO.orientation, perform: { value in
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    masterResetTheCanvas()
//                }
//            })
            
        }
        
        
    }
    
}
