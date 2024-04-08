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
import CoreEngine

struct LineDrawingManaged: View {
    @State var viewId: String
    @State var activityId: String
    
    @StateObject var MVO: ManagedViewObject = ManagedViewObject()
    
    var body: some View {
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
    private func fullLineDragGesture() -> some Gesture {
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
    
    private func singleAnchorDragGesture(isStart: Bool) -> some Gesture {
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
    private func singleTapGesture() -> some Gesture {
        TapGesture(count: 1).onEnded({ _ in
            print("Tapped single")
         })
    }
    
    private func doubleTapGesture() -> some Gesture {
        TapGesture(count: 2).onEnded({ _ in
            print("Tapped double")
            MVO.popUpIsVisible = !MVO.popUpIsVisible
            MVO.anchorsAreVisible = !MVO.anchorsAreVisible
            MVO.toggleMenuWindow()
         })
    }
    
    private func longPressGesture() -> some Gesture {
        LongPressGesture(minimumDuration: 0.4).onEnded { _ in
            MVO.anchorsAreVisible = !MVO.anchorsAreVisible
       }
    }
    
}




//struct LineOverlay: View {
//    var startPoint: CGPoint
//    var endPoint: CGPoint
//    let lineThickness: CGFloat = 10 // Adjust as needed
//
//    private var lineLength: CGFloat {
//        sqrt(pow(endPoint.x - startPoint.x, 2) + pow(endPoint.y - startPoint.y, 2))
//    }
//
//    private var centerPoint: CGPoint {
//        CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
//    }
//
//    private var rotationAngle: Angle {
//        rotationAngleOfLine(from: startPoint, to: endPoint)
//    }
//
//    var body: some View {
//        Rectangle()
//            .frame(width: lineLength, height: lineThickness)
//            .rotationEffect(rotationAngle)
//            .position(x: centerPoint.x, y: centerPoint.y)
//    }
//}



//struct Arrowhead: Shape {
//    var size: CGFloat
//
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//
//        // Drawing a simple triangle
//        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
//        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
//        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
//        path.closeSubpath()
//
//        return path
//    }
//}

//struct Arrowheady: Shape {
//    var size: CGFloat
//
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//
//        // Defining the arrowhead path
//        path.move(to: CGPoint(x: 0, y: -size / 2)) // Top point
//        path.addLine(to: CGPoint(x: size / 2, y: size / 2)) // Bottom right
//        path.addLine(to: CGPoint(x: -size / 2, y: size / 2)) // Bottom left
//        path.closeSubpath()
//
//        return path
//    }
//}

