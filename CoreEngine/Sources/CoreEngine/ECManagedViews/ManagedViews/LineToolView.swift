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

public struct LineDrawingManaged: View {
    @State public var viewId: String
    @State public var activityId: String
    public init(viewId: String, activityId: String) {
        self.viewId = viewId
        self.activityId = activityId
    }
    
    @StateObject public var MVO: ManagedViewObject = ManagedViewObject()
    
    public var body: some View {
        Path { path in
            path.move(to: CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY))
            path.addLine(to: CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY))
        }
        .stroke(MVO.lifeColor, style: StrokeStyle(lineWidth: MVO.lifeWidth, dash: [MVO.lifeLineDash]))
        .opacity(!MVO.isDisabledChecker() && !MVO.isDeletedChecker() ? 1 : 0.0)
        .overlay(
            Triangle()
                .fill(MVO.anchorsAreVisible ? Color.AIMYellow : MVO.lifeColor)
                .frame(width: (MVO.lifeWidth*2).bound(to: 125...1000), height: (MVO.lifeWidth*2).bound(to: 125...1000)) // Increase size for finger tapping
                .opacity(MVO.lifeHeadIsEnabled ? 1 : 0) // Invisible
                .rotationEffect(Angle(degrees: MVO.calculateAngle(startX: MVO.lifeStartX, startY: MVO.lifeStartY, endX: MVO.lifeEndX, endY: MVO.lifeEndY)))
                .position(x: MVO.lifeEndX, y: MVO.lifeEndY)
                .gesture(singleAnchorDragGesture(isStart: false))
                .simultaneousGesture(doubleTapGesture())
                .simultaneousGesture(longPressGesture())
        )
        .overlay(
            Circle()
                .fill(Color.AIMYellow)
                .frame(width: 200, height: 200) // Adjust size for easier tapping
                .opacity(MVO.anchorsAreVisible ? 1 : 0) // Invisible
                .position(x: MVO.lifeStartX, y: MVO.lifeStartY)
                .gesture(singleAnchorDragGesture(isStart: true))
                .simultaneousGesture(doubleTapGesture())
                .simultaneousGesture(longPressGesture())
        )
        .overlay(
            Circle()
                .fill(Color.AIMYellow)
                .frame(width: 200, height: 200) // Increase size for finger tapping
                .opacity(MVO.anchorsAreVisible && !MVO.lifeHeadIsEnabled  ? 1 : 0) // Invisible
                .position(x: MVO.lifeEndX, y: MVO.lifeEndY)
                .gesture(singleAnchorDragGesture(isStart: false))
                .simultaneousGesture(doubleTapGesture())
                .simultaneousGesture(longPressGesture())
        )
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.001))
                .frame(width: MVO.boundedLength(start: CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY), end: CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY)), height: Double(MVO.lifeWidth+300))
                .rotationEffect(MVO.lifeRotation)
                .opacity(1)
                .position(x: MVO.lifeCenterPoint.x.isFinite ? MVO.lifeCenterPoint.x : 0, y: MVO.lifeCenterPoint.y.isFinite ? MVO.lifeCenterPoint.y : 0)
                .gesture(fullLineDragGesture())
                .simultaneousGesture(doubleTapGesture())
                .simultaneousGesture(longPressGesture())
        )
        .gesture(fullLineDragGesture())
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
                DispatchQueue.main.async { self.MVO.ignoreUpdates = true }
                if self.MVO.lifeIsLocked {return}
                self.MVO.isDragging = true
                if MVO.useOriginal {
                    self.MVO.originalLifeStart = CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY)
                    self.MVO.originalLifeEnd = CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY)
                    self.MVO.useOriginal = false
                }

                let translation = value.translation
                MVO.lifeStartX = self.MVO.originalLifeStart.x + translation.width
                MVO.lifeStartY = self.MVO.originalLifeStart.y + translation.height
                MVO.lifeEndX = self.MVO.originalLifeEnd.x + translation.width
                MVO.lifeEndY = self.MVO.originalLifeEnd.y + translation.height
                if !MVO.useOriginal { MVO.loadCenterPoint() }
//                CodiChannel.TOOL_ON_FOLLOW.send(value: ViewFollowing(
//                    viewId: self.viewId,
//                    x: lifeStartX,
//                    y: lifeStartY
//                ))
                MVO.updateRealmPos(start: CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY),
                            end: CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY))
            }
            .onEnded { value in
                DispatchQueue.main.async { self.MVO.ignoreUpdates = false }
                if self.MVO.lifeIsLocked {return}
                let translation = value.translation
                MVO.lifeStartX = self.MVO.originalLifeStart.x + translation.width
                MVO.lifeStartY = self.MVO.originalLifeStart.y + translation.height
                MVO.lifeEndX = self.MVO.originalLifeEnd.x + translation.width
                MVO.lifeEndY = self.MVO.originalLifeEnd.y + translation.height
                self.MVO.isDragging = false
                self.MVO.updateRealm()
                self.MVO.useOriginal = true
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
                MVO.updateRealmPos(start: CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY),
                            end: CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY))
            }
            .onEnded { _ in
                if self.MVO.lifeIsLocked || !MVO.anchorsAreVisible { return }
                self.MVO.isDragging = false
                self.MVO.ignoreUpdates = false
                self.MVO.updateRealm()
//                self.useOriginal = true
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

