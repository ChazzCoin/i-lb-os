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
        // Solid hit band that follows the curve. WAS a `dash: [1]` stroke — a dotted
        // 1pt-on/1pt-off line that is almost entirely GAPS, so touches on the curve
        // landed on nothing and the line was uninteractable ("nothing happens").
        // strokedPath gives a fillable outline; a near-clear FILL hit-tests its whole
        // area, exactly like the straight line's filled-rectangle hit target.
        Path { path in
            path.move(to: startPoint)
            path.addQuadCurve(to: endPoint, control: controlPoint1)
        }
        .strokedPath(StrokeStyle(lineWidth: 220, lineCap: .round, lineJoin: .round))
        .fill(Color.black.opacity(0.01))
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
        // Redesign curved line (TASK-005): rounded caps + colour glow.
        .stroke(MVO.lifeColor,
                style: StrokeStyle(lineWidth: MVO.lifeWidth.bound(to: 1...400),
                                   lineCap: .round, lineJoin: .round,
                                   dash: MVO.lifeLineDash > 1 ? [MVO.lifeLineDash * 3, MVO.lifeLineDash * 3] : []))
        .shadow(color: MVO.lifeColor.opacity(0.45), radius: MVO.lifeWidth.bound(to: 1...400) * 0.35)
        .opacity(!MVO.isDisabledChecker() && !MVO.isDeletedChecker() ? 1 : 0.0)
        // BODY HIT-BAND — must be the LOWEST overlay so the anchor handles below
        // (added after, i.e. on top) win the touch when visible. This previously
        // sat on TOP and ate every anchor touch (the whole-line drag fired instead
        // of the anchor drag), so handles "did nothing". Whole-line move (always on,
        // bails only on lifeIsLocked) + double-tap toggle + long-press delete.
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
        // ANCHOR HANDLES — stacked ABOVE the body band. When visible: reshape
        // (highPriority) and NO move drag, so a handle grab is unambiguous. When
        // hidden: carry the move drag so the invisible 300pt disc doesn't block the
        // body band beneath it.
        .overlay(
            Triangle()
                .fill(MVO.anchorsAreVisible ? Color.AIMYellow : MVO.lifeColor)
                .frame(width: (MVO.lifeWidth*2).bound(to: 125...1000), height: (MVO.lifeWidth*2).bound(to: 125...1000)) // Increase size for finger tapping
                .opacity(MVO.lifeHeadIsEnabled ? 1 : 0) // Invisible
                .rotationEffect(Angle(degrees: MVO.calculateAngleAtEndPointOfQuadCurve()))
                .position(x: MVO.lifeEndX, y: MVO.lifeEndY)
                .highPriorityGesture(!MVO.anchorsAreVisible ? nil : dragSingleAnchor(isStart: false))
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
                .highPriorityGesture(!MVO.anchorsAreVisible ? nil : dragSingleAnchor(isStart: true))
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
                .highPriorityGesture(!MVO.anchorsAreVisible ? nil : dragSingleAnchor(isStart: false))
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
                .highPriorityGesture(!MVO.anchorsAreVisible ? nil : dragCurvedCenterAnchor())
                .gesture(MVO.anchorsAreVisible ? nil : fullCurvedLineDragGesture())
                .simultaneousGesture(!MVO.anchorsAreVisible ? nil : doubleTapForSettingsAndAnchors())
                .simultaneousGesture(!MVO.anchorsAreVisible ? nil : longPressGesture())
        )
        .gesture(fullCurvedLineDragGesture())
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
        .alertConfirm(isPresented: $MVO.showDeleteAlert, title: "Delete?", message: "Delete Tools?", action: {
            MVO.deleteTool()
        })
        .onAppear() {
            print("OnAppear: CurvedLineTool.")
            MVO.initializeWithViewId(viewId: self.viewId)
        }
    }
    
    public func fullCurvedLineDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                main {
                    if MVO.lifeIsLocked { return }   // movable in any anchor state (matches straight line)
                    self.MVO.isDragging = true
                    self.MVO.ignoreUpdates = true
                    if MVO.originalLifeStart == .zero {
                        MVO.originalLifeStart = CGPoint(x: MVO.lifeStartX, y: MVO.lifeStartY)
                        MVO.originalLifeEnd = CGPoint(x: MVO.lifeEndX, y: MVO.lifeEndY)
                        MVO.originalLifeCenter = CGPoint(x: MVO.lifeCenterX, y: MVO.lifeCenterY)
                    }
                    
                    handleFullDragTranslation(value: value)
                }
            }
            .onEnded { value in
                main {
                    if MVO.lifeIsLocked { return }   // movable in any anchor state (matches straight line)
                    self.MVO.ignoreUpdates = false
                    handleFullDragTranslation(value: value)
                    self.MVO.isDragging = false
                    
                    MVO.originalLifeStart = .zero
                    MVO.originalLifeEnd = .zero
                    MVO.originalLifeCenter = .zero
                }
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
        
        MVO.updateRealm()
    }
    
    public func dragCurvedCenterAnchor() -> some Gesture {
        DragGesture()
            .onChanged { value in
                // The handle sits on the curve (the apex, t=0.5). Make the apex
                // follow the finger 1:1 by solving for the control point:
                //   apex = 0.25*start + 0.5*control + 0.25*end
                //   => control = 2*finger - (start + end)/2
                // (Previously it dragged the control directly while drawing the
                //  handle at the apex, which moves at half-speed — felt "stuck".)
                if MVO.lifeIsLocked || !MVO.anchorsAreVisible { return }
                MVO.isDragging = true
                MVO.ignoreUpdates = true
                MVO.lifeCenterX = 2 * value.location.x - (MVO.lifeStartX + MVO.lifeEndX) / 2
                MVO.lifeCenterY = 2 * value.location.y - (MVO.lifeStartY + MVO.lifeEndY) / 2
            }
            .onEnded { _ in
                if MVO.lifeIsLocked || !MVO.anchorsAreVisible { return }
                MVO.isDragging = false
                MVO.ignoreUpdates = false
                MVO.updateRealm()
            }
    }

    // Drag gesture definition
    public func dragSingleAnchor(isStart: Bool) -> some Gesture {
        DragGesture()
            .onChanged { value in
                main {
                    if MVO.lifeIsLocked || !MVO.anchorsAreVisible {return}
                    MVO.isDragging = true
                    self.MVO.ignoreUpdates = true
                    if isStart {
                        MVO.lifeStartX = value.location.x
                        MVO.lifeStartY = value.location.y
                    } else {
                        MVO.lifeEndX = value.location.x
                        MVO.lifeEndY = value.location.y
                    }
                    MVO.loadWidthAndHeight()
                    MVO.loadRotationOfLine()
                    MVO.updateRealm()
                }
            }
            .onEnded { _ in
                main {
                    if MVO.lifeIsLocked || !MVO.anchorsAreVisible {return}
                    MVO.isDragging = false
                    self.MVO.ignoreUpdates = false
                    MVO.updateRealm()
//                    MVO.saveSnapshotToHistoryInRealm()
                }
            }
    }
    
    // Basic Gestures
    public func singleTapGesture() -> some Gesture {
        TapGesture(count: 1).onEnded({ _ in
            print("Tapped single")
         })
    }
    
    public func doubleTapForSettingsAndAnchors() -> some Gesture {
        TapGesture(count: 2).onEnded({ _ in
            print("Tapped double")
            MVO.popUpIsVisible = !MVO.popUpIsVisible
            MVO.anchorsAreVisible = !MVO.anchorsAreVisible
            self.MVO.toggleMenuWindow()
            delayThenMain(1, mainBlock: {
                if MVO.anchorsAreVisible {
                    MVO.listenForSettings()
                } else {
                    MVO.cancel = Set<AnyCancellable>()
                }
            })
         })
    }
    
    public func longPressGesture() -> some Gesture {
        LongPressGesture(minimumDuration: 0.4).onEnded { _ in
            MVO.showDeleteAlert = true
       }
    }
    
}

