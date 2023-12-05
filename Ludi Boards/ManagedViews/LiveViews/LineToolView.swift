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

struct LineDrawingManaged: View {
    @State var viewId: String
    @State var activityId: String
    var managedView: ManagedView? = nil
    
    let realmInstance = realm()
    @State private var isDeleted = false
    @State private var isDisabled = false
    
    @State private var lifeDateUpdated = Int(Date().timeIntervalSince1970)
    
    @State private var lifeCenterPoint = CGPoint.zero
    @State private var lifeStartX = 0.0
    @State private var lifeStartY = 0.0
    @State private var lifeEndX = 0.0
    @State private var lifeEndY = 0.0
    
    @State private var lifeLineLength = 0.0
    @State private var lifeWidthTouch = 300.0
    @State private var lifeHeightTouch = 300.0
    
    @State private var lifeWidth: Double = 10.0
    @State private var lifeColor = Color.red
    
    @State private var lifeColorRed = 0.0
    @State private var lifeColorGreen = 0.0
    @State private var lifeColorBlue = 0.0
    @State private var lifeColorAlpha = 1.0
    
    @State private var lifeRotation: Angle = Angle.zero
    
    @State private var popUpIsVisible = false
    @State private var anchorsAreVisible = false
    
    @State private var offset = CGSize.zero
    @State private var position = CGPoint(x: 0, y: 0)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State var originalLifeStart = CGPoint.zero
    @State var originalLifeEnd = CGPoint.zero
    
    // Firebase
    let reference = Database
        .database()
        .reference()
        .child(DatabasePaths.managedViews.rawValue)
    
    @State private var objectNotificationToken: NotificationToken? = nil
    @State private var cancellables = Set<AnyCancellable>()
    
    // Functions
    func isDisabledChecker() -> Bool { return isDisabled }
    func isDeletedChecker() -> Bool { return isDeleted }

    private var lineLength: CGFloat {
        sqrt(pow(lifeEndX - lifeStartX, 2) + pow(lifeEndY - lifeStartY, 2))-100
    }
    
    func loadRotationOfLine() {
        let lineStart = CGPoint(x: lifeStartX, y: lifeStartY)
        let lineEnd = CGPoint(x: lifeEndX, y: lifeEndY)
        lifeRotation = rotationAngleOfLine(from: lineStart, to: lineEnd)
        print(lifeRotation)
    }
    
    func loadCenterPoint() {
        let lineStart = CGPoint(x: lifeStartX, y: lifeStartY)
        let lineEnd = CGPoint(x: lifeEndX, y: lifeEndY)
        lifeCenterPoint = getCenterOfLine(start: lineStart, end: lineEnd)
    }
    func loadWidthAndHeight() {
        let lineStart = CGPoint(x: lifeStartX, y: lifeStartY)
        let lineEnd = CGPoint(x: lifeEndX, y: lifeEndY)
        let (lineWidth, lineHeight) = getWidthAndHeightOfLine(start: lineStart, end: lineEnd)
        lifeWidthTouch = Double(lineWidth).bound(to: 100...200)
        lifeHeightTouch = Double(lineHeight).bound(to: 100...200)
    }
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: lifeStartX, y: lifeStartY))
            path.addLine(to: CGPoint(x: lifeEndX, y: lifeEndY))
        }
        .stroke(lifeColor, lineWidth: CGFloat(lifeWidth))
        .opacity(!isDisabledChecker() && !isDeletedChecker() ? 1 : 0.0)
        .overlay(
            Circle()
                .fill(Color.AIMYellow)
                .frame(width: 150, height: 150) // Adjust size for easier tapping
                .opacity(anchorsAreVisible ? 1 : 0) // Invisible
                .position(x: lifeStartX, y: lifeStartY)
                .gesture(dragGesture(isStart: true))
        )
        .overlay(
            Circle()
                .fill(Color.AIMYellow)
                .frame(width: 150, height: 150) // Increase size for finger tapping
                .opacity(anchorsAreVisible ? 1 : 0) // Invisible
                .position(x: lifeEndX, y: lifeEndY)
                .gesture(dragGesture(isStart: false))
        )
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.001))
                .frame(width: Double(lifeWidth+300).bound(to: 20...500), height: 200)
                .rotationEffect(lifeRotation)
                .opacity(1)
                .position(x: lifeCenterPoint.x.isFinite ? lifeCenterPoint.x : 0, y: lifeCenterPoint.y.isFinite ? lifeCenterPoint.y : 0)
                .gesture(dragGestureDuo())
        )
        .gesture(dragGestureDuo())
        .onAppear() {
            loadFromRealm()

            CodiChannel.TOOL_ATTRIBUTES.receive(on: RunLoop.main) { vId in
                let temp = vId as! ViewAtts
                if viewId != temp.viewId {return}
                if let ts = temp.size { lifeWidth = ts }
                if let tc = temp.color { lifeColor = tc }
                if temp.stateAction == "close" {
                    popUpIsVisible = false
                }
                if temp.isDeleted {
                    isDeleted = true  
                    isDisabled = true
                    deleteFromRealm()
                    return
                }
                updateRealm()
            }.store(in: &cancellables)
            CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { vId in
                let temp = vId as! WindowController
                if temp.windowId != "mv_settings" {return}
                if temp.stateAction == "close" {
                    popUpIsVisible = false
                }
            }.store(in: &cancellables)
        }
    }
    
    // Drag gesture definition
    private func dragGesture(isStart: Bool) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if !anchorsAreVisible {return}
                if isStart {
                    self.lifeStartX = value.location.x
                    self.lifeStartY = value.location.y
                } else {
                    self.lifeEndX = value.location.x
                    self.lifeEndY = value.location.y
                }
                loadCenterPoint()
                loadWidthAndHeight()
                loadRotationOfLine()
            }
            .onEnded { _ in
                if !anchorsAreVisible {return}
                updateRealm()
            }
            .simultaneously(with: TapGesture(count: 1)
                 .onEnded { _ in
                     anchorsAreVisible = !anchorsAreVisible
                 }
            ).simultaneously(with: TapGesture(count: 2).onEnded({ _ in
                print("Tapped double")
                popUpIsVisible = !popUpIsVisible
                CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(
                   windowId: "mv_settings",
                   stateAction: popUpIsVisible ? "open" : "close",
                   viewId: viewId
                ))
                if popUpIsVisible {
                    CodiChannel.TOOL_ATTRIBUTES.send(value: ViewAtts(
                       viewId: viewId,
                       size: lifeWidth,
                       color: lifeColor,
                       level: ToolLevels.LINE.rawValue,
                       stateAction: popUpIsVisible ? "open" : "close")
                    )
                }
            }))
    }
    
    // Drag gesture definition
    private func dragGestureDuo() -> some Gesture {
        DragGesture()
            .updating($dragOffset, body: { (value, state, transaction) in
                state = value.translation
            })
            .onChanged { value in
                if self.originalLifeStart == .zero {
                    self.originalLifeStart = CGPoint(x: lifeStartX, y: lifeStartY)
                    self.originalLifeEnd = CGPoint(x: lifeEndX, y: lifeEndY)
                }

                let translation = value.translation
                lifeStartX = self.originalLifeStart.x + translation.width
                lifeStartY = self.originalLifeStart.y + translation.height
                lifeEndX = self.originalLifeEnd.x + translation.width
                lifeEndY = self.originalLifeEnd.y + translation.height
                loadCenterPoint()
            }
            .onEnded { value in
                let translation = value.translation
                lifeStartX = self.originalLifeStart.x + translation.width
                lifeStartY = self.originalLifeStart.y + translation.height
                lifeEndX = self.originalLifeEnd.x + translation.width
                lifeEndY = self.originalLifeEnd.y + translation.height
                loadCenterPoint()
                updateRealm(start: CGPoint(x: lifeStartX, y: lifeStartY),
                            end: CGPoint(x: lifeEndX, y: lifeEndY))
                self.originalLifeStart = .zero
                self.originalLifeEnd = .zero
            }.simultaneously(with: TapGesture(count: 1)
                .onEnded { _ in
                    anchorsAreVisible = !anchorsAreVisible
                }
           ).simultaneously(with: TapGesture(count: 2).onEnded({ _ in
               print("Tapped double")
               popUpIsVisible = !popUpIsVisible
               CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(
                  windowId: "mv_settings",
                  stateAction: popUpIsVisible ? "open" : "close",
                  viewId: viewId
               ))
               if popUpIsVisible {
                   CodiChannel.TOOL_ATTRIBUTES.send(value: ViewAtts(
                      viewId: viewId,
                      size: lifeWidth,
                      color: lifeColor,
                      level: ToolLevels.LINE.rawValue,
                      stateAction: popUpIsVisible ? "open" : "close")
                   )
               }
           }))
    }
    
    func updateRealm(start: CGPoint? = nil, end: CGPoint? = nil) {
        print("!!!! Updating Realm!")
        if isDisabledChecker() {return}
        if isDeletedChecker() {return}
        let mv = realmInstance.findByField(ManagedView.self, value: viewId)
        if mv == nil { return }
        realmInstance.safeWrite { r in
            lifeDateUpdated = Int(Date().timeIntervalSince1970)
            mv?.dateUpdated = lifeDateUpdated
            mv?.startX = Double(start?.x ?? CGFloat(lifeStartX))
            mv?.startY = Double(start?.y ?? CGFloat(lifeStartY))
            mv?.endX = Double(end?.x ?? CGFloat(lifeEndX))
            mv?.endY = Double(end?.y ?? CGFloat(lifeEndY))
            
            if let lc = lifeColor.toRGBA() {
                mv?.colorRed = lc.red
                mv?.colorGreen = lc.green
                mv?.colorBlue = lc.blue
                mv?.colorAlpha = lc.alpha
            }
            
            mv?.toolType = "LINE"
            mv?.width = Int(lifeWidth)
            guard let tMV = mv else { return }
            r.create(ManagedView.self, value: tMV, update: .all)
            
            // TODO: Firebase Users ONLY
            firebaseDatabase { fdb in
                fdb.child(DatabasePaths.managedViews.rawValue)
                    .child(activityId)
                    .child(viewId)
                    .setValue(mv?.toDict())
            }
        }
    }
    
    func loadFromRealm() {
        if isDisabledChecker() {return}
        if isDeletedChecker() {return}
        let mv = realmInstance.object(ofType: ManagedView.self, forPrimaryKey: viewId)
        guard let umv = mv else { return }
        // set attributes
        activityId = umv.boardId
        lifeStartX = umv.startX
        lifeStartY = umv.startY
        lifeEndX = umv.endX
        lifeEndY = umv.endY
        lifeWidth = Double(umv.width)
        
        lifeColorRed = umv.colorRed
        lifeColorGreen = umv.colorGreen
        lifeColorBlue = umv.colorBlue
        lifeColorAlpha = umv.colorAlpha
        lifeColor = colorFromRGBA(red: lifeColorRed, green: lifeColorGreen, blue: lifeColorBlue, alpha: lifeColorAlpha)
        
        loadCenterPoint()
        loadWidthAndHeight()
        loadRotationOfLine()
    }
    
    func deleteFromRealm() {
        let mv = realmInstance.object(ofType: ManagedView.self, forPrimaryKey: viewId)
        guard let umv = mv else { return }
        realmInstance.safeWrite { r in
            r.delete(umv)
        }
        
        // TODO: Firebase Users ONLY
        firebaseDatabase { fdb in
            fdb.child(DatabasePaths.managedViews.rawValue)
                .child(activityId)
                .child(viewId)
                .removeValue()
        }
    }
}

struct LineOverlay: View {
    var startPoint: CGPoint
    var endPoint: CGPoint
    let lineThickness: CGFloat = 10 // Adjust as needed

    private var lineLength: CGFloat {
        sqrt(pow(endPoint.x - startPoint.x, 2) + pow(endPoint.y - startPoint.y, 2))
    }

    private var centerPoint: CGPoint {
        CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
    }

    private var rotationAngle: Angle {
        rotationAngleOfLine(from: startPoint, to: endPoint)
    }

    var body: some View {
        Rectangle()
            .frame(width: lineLength, height: lineThickness)
            .rotationEffect(rotationAngle)
            .position(x: centerPoint.x, y: centerPoint.y)
    }
}

func rotationAngleOfLine(from startPoint: CGPoint, to endPoint: CGPoint) -> Angle {
    let deltaY = endPoint.y - startPoint.y
    let deltaX = endPoint.x - startPoint.x

    let angleInRadians = atan2(deltaY, deltaX)
    return Angle(radians: Double(angleInRadians))
}

func getCenterOfLine(start: CGPoint, end: CGPoint) -> CGPoint {
    let midX = (start.x + end.x) / 2
    let midY = (start.y + end.y) / 2
    return CGPoint(x: midX, y: midY)
}

func getWidthAndHeightOfLine(start: CGPoint, end: CGPoint) -> (width: CGFloat, height: CGFloat) {
    let width = abs(end.x - start.x)
    let height = abs(end.y - start.y)
    return (width, height)
}

func boundingRect(start: CGPoint, end: CGPoint) -> CGRect {
    let minX = min(start.x, end.x)
    let minY = min(start.y, end.y)
    let width = abs(end.x - start.x)
    let height = abs(end.y - start.y)
    return CGRect(x: minX, y: minY, width: width, height: height)
}

struct Arrowhead: Shape {
    var size: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Drawing a simple triangle
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

struct Arrowheady: Shape {
    var size: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Defining the arrowhead path
        path.move(to: CGPoint(x: 0, y: -size / 2)) // Top point
        path.addLine(to: CGPoint(x: size / 2, y: size / 2)) // Bottom right
        path.addLine(to: CGPoint(x: -size / 2, y: size / 2)) // Bottom left
        path.closeSubpath()

        return path
    }
}

