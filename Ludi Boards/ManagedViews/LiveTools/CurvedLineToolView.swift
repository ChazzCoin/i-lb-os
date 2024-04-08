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
import CoreEngine

//struct OverlayLineV: View {
//    @Binding var startX: CGFloat
//    @Binding var startY: CGFloat
//    @Binding var centerX: CGFloat
//    @Binding var centerY: CGFloat
//    @Binding var endX: CGFloat
//    @Binding var endY: CGFloat
//    
//    
//    var body: some View {
//        Path { path in
//                path.move(to: CGPoint(x: startX, y: startY))
//                path.addQuadCurve(to: CGPoint(x: endX, y: endY),
//                                  control: CGPoint(x: centerX, y: centerY))
//            }
//        .stroke(Color.black, style: StrokeStyle(lineWidth: 100, dash: [0.0]))
//    }
//}


struct MatchedShape: View {
    var startPoint: CGPoint
    var endPoint: CGPoint
    var controlPoint1: CGPoint
    
    var body: some View {
        Path { path in
            path.move(to: startPoint)
            path.addQuadCurve(to: endPoint,
                              control: controlPoint1)
        }
        .stroke(Color.black.opacity(0.01), style: StrokeStyle(lineWidth: 300.0, dash: [1]))
    }
}

struct CurvedLineDrawingManaged: View {
    @State var viewId: String
    @State var activityId: String
//    @EnvironmentObject var BEO: BoardEngineObject
//    var managedView: ManagedView? = nil
//    private let menuWindowId = "mv_settings"
    
//    @State private var isWriting = false
//    @State private var coordinateStack: [[String:CGPoint]] = []
    
    let realmInstance = realm()
    
    @StateObject var MVO: ManagedViewObject = ManagedViewObject()
//    @GestureState public var dragOffset = CGSize.zero
    
//    @State private var managedViewNotificationToken: NotificationToken? = nil
//    @State private var MVS: SingleManagedViewService = SingleManagedViewService()
//    @State private var isDisabled = false
//    @State private var lifeIsLocked = false
//    @State private var lifeDateUpdated = Int(Date().timeIntervalSince1970)
//    
//    @State var lifeToolType = "CURVED-LINE"
//    
    @State private var dragOffset: CGSize = .zero
//    @GestureState private var dragOffseter: CGSize = .zero
//    @State private var lifeCenterX: CGFloat = 0.0
//    @State private var lifeCenterY: CGFloat = 0.0
//    @State private var lifeStartX: CGFloat = 0.0
//    @State private var lifeStartY: CGFloat = 0.0
//    @State private var lifeEndX: CGFloat = 0.0
//    @State private var lifeEndY: CGFloat = 0.0
//    
//    @State private var lifeLineLength = 0.0
//    @State private var lifeWidthTouch = 300.0
//    @State private var lifeHeightTouch = 300.0
//    
//    @State private var lifeWidth: Double = 10.0
//    @State private var lifeColor = Color.red
//    
//    @State private var lifeColorRed = 0.0
//    @State private var lifeColorGreen = 0.0
//    @State private var lifeColorBlue = 0.0
//    @State private var lifeColorAlpha = 1.0
//    @State private var lifeLineDash = 1.0
//    @State private var lifeHeadIsEnabled = true
//    @State private var lifeRotation: Angle = Angle.zero
//    
//    @State private var popUpIsVisible = false
//    @State private var anchorsAreVisible = false
//    
//    @State private var offset = CGSize.zero
//    @State private var position = CGPoint(x: 0, y: 0)
////    @GestureState private var dragOffset = CGSize.zero
//    @State private var isDragging = false
//    @State var originalLifeStart = CGPoint.zero
//    @State var originalLifeEnd = CGPoint.zero
//    @State var originalLifeCenter = CGPoint.zero
//    
//    @State private var objectNotificationToken: NotificationToken? = nil
//    @State private var cancellables = Set<AnyCancellable>()
    
    // Functions
//    func isDisabledChecker() -> Bool { return isDisabled }
//    func isDeletedChecker() -> Bool { return self.MVS.isDeleted }

//    private var lineLength: CGFloat {
//        sqrt(pow(lifeEndX - lifeStartX, 2) + pow(lifeEndY - lifeStartY, 2))-100
//    }
//    
//    func loadRotationOfLine() {
//        let lineStart = CGPoint(x: lifeStartX, y: lifeStartY)
//        let lineEnd = CGPoint(x: lifeEndX, y: lifeEndY)
//        lifeRotation = rotationAngleOfLine(from: lineStart, to: lineEnd)
//        print(lifeRotation)
//    }
//    
//    func loadWidthAndHeight() {
//        let lineStart = CGPoint(x: lifeStartX, y: lifeStartY)
//        let lineEnd = CGPoint(x: lifeEndX, y: lifeEndY)
//        let (lineWidth, lineHeight) = getWidthAndHeightOfLine(start: lineStart, end: lineEnd)
//        lifeWidthTouch = Double(lineWidth).bound(to: 100...200)
//        lifeHeightTouch = Double(lineHeight).bound(to: 100...200)
//    }
//    
//    func loadControlAnchor() {
//        let t: CGFloat = 0.5
//        lifeCenterX = (pow(1-t, 2) * lifeStartX + 2*(1-t)*t*lifeCenterX + pow(t, 2) * lifeEndX)
//        lifeCenterY = (pow(1-t, 2) * lifeStartY + 2*(1-t)*t*lifeCenterY + pow(t, 2) * lifeEndY)
//    }
    
//    func quadBezierPoint(start: CGPoint, end: CGPoint, control: CGPoint) -> CGPoint {
//        let t: CGFloat = 0.5
//        let x = pow(1-t, 2) * start.x + 2*(1-t)*t*control.x + pow(t, 2) * end.x
//        let y = pow(1-t, 2) * start.y + 2*(1-t)*t*control.y + pow(t, 2) * end.y
//        return CGPoint(x: x, y: y)
//    }
//    
//    func calculateAngle(startX: CGFloat, startY: CGFloat, endX: CGFloat, endY: CGFloat) -> Double {
//        let deltaX = endX - startX
//        let deltaY = endY - startY
//        let angle = atan2(deltaY, deltaX) * 180 / .pi
//        return Double(angle) + 90
//    }
    
//    func calculateAngleAtEndPointOfQuadCurve() -> Double {
//        // Since we are calculating the angle at the end point, t = 1
//        let t: CGFloat = 1.0
//
//        // Breaking down the derivative calculation into smaller parts
//        let dx1 = lifeCenterX - lifeStartX
//        let dy1 = lifeCenterY - lifeStartY
//        let dx2 = lifeEndX - lifeCenterX
//        let dy2 = lifeEndY - lifeCenterY
//
//        let derivativeX = 2 * (1 - t) * dx1 + 2 * t * dx2
//        let derivativeY = 2 * (1 - t) * dy1 + 2 * t * dy2
//
//        // Calculate the angle
//        let angle = atan2(derivativeY, derivativeX) * 180 / .pi
//        return Double(angle) + 90
//    }

    
    var body: some View {
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

        }
    }
    
    func fullCurvedLineDragGesture() -> some Gesture {
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
    
    func handleFullDragTranslation(value: DragGesture.Value) {
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
    private func doubleTapForSettingsAndAnchors() -> some Gesture {
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
    
    func dragCurvedCenterAnchor() -> some Gesture {
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
    private func dragSingleAnchor(isStart: Bool) -> some Gesture {
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
    private func singleTapGesture() -> some Gesture {
        TapGesture(count: 1).onEnded({ _ in
            print("Tapped single")
         })
    }
    
    private func doubleTapGesture() -> some Gesture {
        TapGesture(count: 2).onEnded({ _ in
            print("Tapped double")
//            toggleMenuSettings()
         })
    }
    
    private func longPressGesture() -> some Gesture {
        LongPressGesture(minimumDuration: 0.4).onEnded { _ in
            MVO.anchorsAreVisible = !MVO.anchorsAreVisible
       }
    }
    

    
}

