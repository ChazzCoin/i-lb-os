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
import CoreGraphics

public struct MatchedShape: View {
    public var startPoint: CGPoint
    public var endPoint: CGPoint
    public var controlPoint1: CGPoint
    
    public var body: some View {
        Path { path in
            path.move(to: startPoint)
            path.addQuadCurve(to: endPoint,
                              control: controlPoint1)
        }
        .stroke(Color.black.opacity(0.01), style: StrokeStyle(lineWidth: 300.0, dash: [1]))
    }
}

public struct CurvedLineDrawingManaged: View {
    @State public var viewId: String
    @State public var activityId: String
    public init(viewId: String, activityId: String) {
        self.viewId = viewId
        self.activityId = activityId
    }
    
    public let realmInstance = realm()
    
    @StateObject public var MVO: ManagedViewObject = ManagedViewObject()
    @State public var dragOffset: CGSize = .zero

    public var body: some View {
        Path { path in
            path.move(to: CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY))
            path.addQuadCurve(to: CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY),
                              control: CGPoint(x: MVO.lifeCenterX, y: MVO.lifeCenterY))
        }
        .stroke(MVO.lifeColor, style: StrokeStyle(lineWidth: MVO.lifeWidth.bound(to: 1...400), dash: [MVO.lifeLineDash]))
        .opacity(!MVO.isDisabledChecker() && !MVO.isDeletedChecker() ? 1 : 0.0)
        .overlay(
            Triangle()
                .fill(MVO.anchorsAreVisible ? Color.AIMYellow : MVO.lifeColor)
                .frame(width: (MVO.lifeWidth*2).bound(to: 125...1000), height: (MVO.lifeWidth*2).bound(to: 125...1000)) // Increase size for finger tapping
                .opacity(MVO.lifeHeadIsEnabled ? 1 : 0) // Invisible
                .rotationEffect(Angle(degrees: MVO.calculateAngleAtEndPointOfQuadCurve()))
                .position(x: MVO.lifeEndX, y: MVO.lifeEndY)
                .gesture(!MVO.anchorsAreVisible ? nil : dragSingleAnchor(isStart: false))
                .gesture(MVO.anchorsAreVisible ? nil : fullCurvedLineDragGesture())
                .simultaneousGesture(!MVO.anchorsAreVisible ? nil : doubleTapForSettingsAndAnchors())
                .simultaneousGesture(!MVO.anchorsAreVisible ? nil : longPressGesture())
        )
        .overlay(
            Circle()
                .fill(Color.AIMYellow)
                .frame(width: 300, height: 300) // Adjust size for easier tapping
                .opacity(MVO.anchorsAreVisible ? 1 : 0) // Invisible
                .position(x: MVO.lifeStartX, y: MVO.lifeStartY)
                .gesture(!MVO.anchorsAreVisible ? nil : dragSingleAnchor(isStart: true))
                .gesture(MVO.anchorsAreVisible ? nil : fullCurvedLineDragGesture())
                .simultaneousGesture(!MVO.anchorsAreVisible ? nil : doubleTapForSettingsAndAnchors())
                .simultaneousGesture(!MVO.anchorsAreVisible ? nil : longPressGesture())
        )
        .overlay(
            Circle()
                .fill(Color.AIMYellow)
                .frame(width: 300, height: 300) // Increase size for finger tapping
                .opacity(MVO.anchorsAreVisible ? 1 : 0) // Invisible
                .position(x: MVO.lifeEndX, y: MVO.lifeEndY)
                .gesture(!MVO.anchorsAreVisible ? nil : dragSingleAnchor(isStart: false))
                .gesture(MVO.anchorsAreVisible ? nil : fullCurvedLineDragGesture())
                .simultaneousGesture(!MVO.anchorsAreVisible ? nil : doubleTapForSettingsAndAnchors())
                .simultaneousGesture(!MVO.anchorsAreVisible ? nil : longPressGesture())
        )
        .overlay(
            Circle() // Use a circle for the control point
                .fill(Color.AIMYellow)
                .frame(width: 300, height: 300) // Adjust size as needed
                .opacity(MVO.anchorsAreVisible ? 1 : 0)
                .position(quadBezierPoint(start: CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY), end: CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY), control: CGPoint(x: MVO.lifeCenterX, y: MVO.lifeCenterY)))
                .gesture(!MVO.anchorsAreVisible ? nil : dragCurvedCenterAnchor())
                .gesture(MVO.anchorsAreVisible ? nil : fullCurvedLineDragGesture())
                .simultaneousGesture(!MVO.anchorsAreVisible ? nil : doubleTapForSettingsAndAnchors())
                .simultaneousGesture(!MVO.anchorsAreVisible ? nil : longPressGesture())
        )
        .overlay(
            MatchedShape(
                startPoint: CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY),
                endPoint: CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY),
                controlPoint1: CGPoint(x: MVO.lifeCenterX, y: MVO.lifeCenterY)
            )
            .gesture(fullCurvedLineDragGesture())
            .simultaneousGesture(doubleTapForSettingsAndAnchors())
            .simultaneousGesture(longPressGesture())
        )
        .gesture(fullCurvedLineDragGesture())
//        .simultaneousGesture(doubleTapForSettingsAndAnchors())
//        .simultaneousGesture(longPressGesture())
        .onChange(of: self.MVO.toolBarCurrentViewId, perform: { _ in
            if self.MVO.toolBarCurrentViewId != self.viewId {
                MVO.popUpIsVisible = false
                MVO.anchorsAreVisible = false
            }
        })
        .onChange(of: self.MVO.toolSettingsIsShowing, perform: { _ in
            if !self.MVO.toolSettingsIsShowing {
                MVO.popUpIsVisible = false
                MVO.anchorsAreVisible = false
            }
        })
        .onAppear() {
            print("OnAppear: CurvedLineTool.")
            MVO.initializeWithViewId(viewId: self.viewId)
        }
    }
    
    public func fullCurvedLineDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                if MVO.lifeIsLocked || MVO.anchorsAreVisible { return }
                self.MVO.isDragging = true
                self.MVO.ignoreUpdates = true
                if MVO.originalLifeStart == .zero {
                    MVO.originalLifeStart = CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY)
                    MVO.originalLifeEnd = CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY)
                    MVO.originalLifeCenter = CGPoint(x: MVO.lifeCenterX, y: MVO.lifeCenterY)
                }
                
                handleFullDragTranslation(value: value)
            }
            .onEnded { value in
                if MVO.lifeIsLocked || MVO.anchorsAreVisible { return }
                self.MVO.ignoreUpdates = false
                handleFullDragTranslation(value: value)
                self.MVO.isDragging = false
                
                MVO.originalLifeStart = .zero
                MVO.originalLifeEnd = .zero
                MVO.originalLifeCenter = .zero
            }
            
    }
    
    public func handleFullDragTranslation(value: DragGesture.Value) {
        let dragAmount = value.translation
        let startPoint = CGPoint(x: MVO.originalLifeStart.x + dragAmount.width, y: MVO.originalLifeStart.y + dragAmount.height)
        let controlPoint = CGPoint(x: MVO.originalLifeCenter.x + dragAmount.width, y: MVO.originalLifeCenter.y + dragAmount.height)
        let endPoint = CGPoint(x: MVO.originalLifeEnd.x + dragAmount.width, y: MVO.originalLifeEnd.y + dragAmount.height)
        
        MVO.lifeStartX = startPoint.x
        MVO.lifeStartY = startPoint.y
        MVO.lifeCenterX = controlPoint.x
        MVO.lifeCenterY = controlPoint.y
        MVO.lifeEndX = endPoint.x
        MVO.lifeEndY = endPoint.y
        
        MVO.updateRealmPos(start: CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY),
                       end: CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY))
        MVO.saveSnapshotToHistoryInRealm()
    }
    
    // Drag gesture definition
    public func doubleTapForSettingsAndAnchors() -> some Gesture {
        TapGesture(count: 2).onEnded({ _ in
            print("Tapped double")
            MVO.anchorsAreVisible = !MVO.anchorsAreVisible
            MVO.popUpIsVisible = !MVO.popUpIsVisible
            if MVO.popUpIsVisible {
                self.MVO.toolBarCurrentViewId = self.viewId
                self.MVO.toolSettingsIsShowing = true
            } else {
                self.MVO.toolSettingsIsShowing = false
            }
        })
    }
    
    public func dragCurvedCenterAnchor() -> some Gesture {
        DragGesture()
            .onChanged { value in
                if MVO.lifeIsLocked || !MVO.anchorsAreVisible {return}
                MVO.isDragging = true
                self.MVO.ignoreUpdates = true
                if self.dragOffset == .zero {
                    self.dragOffset = CGSize(width: (MVO.lifeCenterX - value.startLocation.x),
                                             height: (MVO.lifeCenterY - value.startLocation.y))
                }
                MVO.lifeCenterX = (value.location.x + dragOffset.width)
                MVO.lifeCenterY = (value.location.y + dragOffset.height)
            }
            .onEnded { _ in
                if MVO.lifeIsLocked || !MVO.anchorsAreVisible { return }
                self.dragOffset = .zero
                MVO.isDragging = false
                self.MVO.ignoreUpdates = false
                MVO.updateRealm()
            }
    }

    // Drag gesture definition
    public func dragSingleAnchor(isStart: Bool) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if MVO.lifeIsLocked || !MVO.anchorsAreVisible {return}
                MVO.isDragging = true
                self.MVO.ignoreUpdates = true
                if isStart {
                    MVO.lifeStartX = value.location.x
                    MVO.lifeStartY = value.location.y
//                    CodiChannel.TOOL_ON_FOLLOW.send(value: ViewFollowing(
//                        viewId: self.viewId,
//                        x: self.lifeStartX,
//                        y: (self.lifeStartY + 200)
//                    ))
                } else {
                    MVO.lifeEndX = value.location.x
                    MVO.lifeEndY = value.location.y
                }
                MVO.loadWidthAndHeight()
                MVO.loadRotationOfLine()
                MVO.updateRealmPos(start: CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY),
                                   end: CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY))
            }
            .onEnded { _ in
                if MVO.lifeIsLocked || !MVO.anchorsAreVisible {return}
                MVO.isDragging = false
                self.MVO.ignoreUpdates = false
                MVO.updateRealmPos(start: CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY),
                                   end: CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY))
                MVO.saveSnapshotToHistoryInRealm()
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
//            toggleMenuSettings()
         })
    }
    
    public func longPressGesture() -> some Gesture {
        LongPressGesture(minimumDuration: 0.4).onEnded { _ in
            MVO.anchorsAreVisible = !MVO.anchorsAreVisible
       }
    }
    

    
}

