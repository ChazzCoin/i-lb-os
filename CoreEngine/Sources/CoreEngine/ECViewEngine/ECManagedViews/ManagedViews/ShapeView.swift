//
//  ManagedViewToolBar.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/15/23.
//

import Foundation
import SwiftUI
import RealmSwift
import Combine
import FirebaseDatabase

public struct ShapeToolManaged: View {
    @State public var viewId: String
    @State public var activityId: String
    public let isTriple: Bool
    public let isQuad: Bool
    
    public init(viewId: String, activityId: String, isTriple: Bool=false, isQuad: Bool=false) {
        self.viewId = viewId
        self.activityId = activityId
        self.isTriple = isTriple
        self.isQuad = isQuad
    }
    
    @StateObject public var MVO: ManagedViewObject = ManagedViewObject()
    
    public var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: MVO.lifeX, y: MVO.lifeY))
                path.addLine(to: CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY))
                if isQuad || isTriple { path.addLine(to: CGPoint(x: MVO.lifeCenterX, y: MVO.lifeCenterY)) }
                if isQuad { path.addLine(to: CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY)) }
                path.closeSubpath()

            }
            .stroke(MVO.lifeColor, style: StrokeStyle(lineWidth: MVO.lifeWidth, dash: [MVO.lifeLineDash]))
            .opacity(!MVO.isDisabledChecker() && !MVO.isDeletedChecker() ? 1 : 0.0)
            .gesture(fullLineDragGesture())
            
            DragAnchor(x: $MVO.lifeX, y: $MVO.lifeY, width: MVO.lifeWidth * 2, height: MVO.lifeWidth * 2)
            DragAnchor(x: $MVO.lifeStartX, y: $MVO.lifeStartY, width: MVO.lifeWidth * 2, height: MVO.lifeWidth * 2)
            if isQuad || isTriple { DragAnchor(x: $MVO.lifeCenterX, y: $MVO.lifeCenterY, width: MVO.lifeWidth * 2, height: MVO.lifeWidth * 2) }
            if isQuad { DragAnchor(x: $MVO.lifeEndX, y: $MVO.lifeEndY, width: MVO.lifeWidth * 2, height: MVO.lifeWidth * 2) }
        }
        .onChange(of: self.MVO.toolBarCurrentViewId, perform: { _ in
            if self.MVO.toolBarCurrentViewId != self.viewId { self.MVO.popUpIsVisible = false
                self.MVO.anchorsAreVisible = false
            }
        })
        .onChange(of: self.MVO.toolSettingsIsShowing, perform: { _ in
            if !self.MVO.toolSettingsIsShowing {
                self.MVO.popUpIsVisible = false
                self.MVO.anchorsAreVisible = false
            }
        })
        .onAppear() {
            print("OnAppear: LineTool.")
            MVO.initializeWithViewId(viewId: self.viewId)
        }
    }
    
    // Gestures
    public func fullLineDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                DispatchQueue.main.async {
                    self.MVO.ignoreUpdates = true
                    if self.MVO.lifeIsLocked {return}
                    self.MVO.isDragging = true
                    if MVO.useOriginal {
                        self.MVO.originalPosition = CGPoint(x: MVO.lifeX, y: MVO.lifeY)
                        self.MVO.originalLifeStart = CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY)
                        self.MVO.originalLifeCenter = CGPoint(x: MVO.lifeCenterX, y: MVO.lifeCenterY)
                        self.MVO.originalLifeEnd = CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY)
                        self.MVO.useOriginal = false
                    }

                    let translation = value.translation
                    MVO.lifeX = self.MVO.originalPosition.x + translation.width
                    MVO.lifeY = self.MVO.originalPosition.y + translation.height
                    MVO.lifeStartX = self.MVO.originalLifeStart.x + translation.width
                    MVO.lifeStartY = self.MVO.originalLifeStart.y + translation.height
                    MVO.lifeCenterX = self.MVO.originalLifeCenter.x + translation.width
                    MVO.lifeCenterY = self.MVO.originalLifeCenter.y + translation.height
                    MVO.lifeEndX = self.MVO.originalLifeEnd.x + translation.width
                    MVO.lifeEndY = self.MVO.originalLifeEnd.y + translation.height
                    if !MVO.useOriginal { MVO.loadCenterPoint() }
                    MVO.updateRealmPos()
                }
            }
            .onEnded { value in
                DispatchQueue.main.async {
                    self.MVO.ignoreUpdates = false
                    if self.MVO.lifeIsLocked {return}
                    let translation = value.translation
                    MVO.lifeX = self.MVO.originalPosition.x + translation.width
                    MVO.lifeY = self.MVO.originalPosition.y + translation.height
                    MVO.lifeStartX = self.MVO.originalLifeStart.x + translation.width
                    MVO.lifeStartY = self.MVO.originalLifeStart.y + translation.height
                    MVO.lifeCenterX = self.MVO.originalLifeCenter.x + translation.width
                    MVO.lifeCenterY = self.MVO.originalLifeCenter.y + translation.height
                    MVO.lifeEndX = self.MVO.originalLifeEnd.x + translation.width
                    MVO.lifeEndY = self.MVO.originalLifeEnd.y + translation.height
                    self.MVO.isDragging = false
                    self.MVO.updateRealmPos()
                    self.MVO.useOriginal = true
                }
            }
    }
    
    public func singleAnchorDragGesture(isStart: Bool) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if self.MVO.lifeIsLocked || !MVO.anchorsAreVisible { return }
                self.MVO.isDragging = true
                self.MVO.ignoreUpdates = true
                if isStart {
                    self.MVO.lifeStartX = value.location.x
                    self.MVO.lifeStartY = value.location.y
                } else {
                    self.MVO.lifeEndX = value.location.x
                    self.MVO.lifeEndY = value.location.y
                }
                MVO.updateRealm()
            }
            .onEnded { _ in
                if self.MVO.lifeIsLocked || !MVO.anchorsAreVisible { return }
                self.MVO.isDragging = false
                self.MVO.ignoreUpdates = false
                self.MVO.updateRealm()
            }
            
    }
    
    // Basic Gestures
    public func singleTapGesture() -> some Gesture {
        TapGesture(count: 1).onEnded({ _ in
            print("Tapped single")
         })
    }
    
    public func doubleTapGesture() -> some Gesture {
        TapGesture(count: 2).onEnded({ _ in
            print("Tapped double")
            MVO.popUpIsVisible = !MVO.popUpIsVisible
            MVO.anchorsAreVisible = !MVO.anchorsAreVisible
            MVO.toggleMenuWindow()
         })
    }
    
    public func longPressGesture() -> some Gesture {
        LongPressGesture(minimumDuration: 0.4).onEnded { _ in
            MVO.anchorsAreVisible = !MVO.anchorsAreVisible
       }
    }
    
}

