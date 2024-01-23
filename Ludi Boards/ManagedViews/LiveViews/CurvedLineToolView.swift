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

struct OverlayLineV: View {
    @Binding var startX: CGFloat
    @Binding var startY: CGFloat
    @Binding var centerX: CGFloat
    @Binding var centerY: CGFloat
    @Binding var endX: CGFloat
    @Binding var endY: CGFloat
    
    
    var body: some View {
        Path { path in
                path.move(to: CGPoint(x: startX, y: startY))
                path.addQuadCurve(to: CGPoint(x: endX, y: endY),
                                  control: CGPoint(x: centerX, y: centerY))
            }
        .stroke(Color.black, style: StrokeStyle(lineWidth: 100, dash: [0.0]))
    }
}

struct CurvedLineDrawingManaged: View {
    @State var viewId: String
    @State var activityId: String
    @EnvironmentObject var BEO: BoardEngineObject
    var managedView: ManagedView? = nil
    private let menuWindowId = "mv_settings"
    
    @State private var isWriting = false
    @State private var coordinateStack: [[String:CGPoint]] = []
    
    let realmInstance = realm()
    @State private var managedViewNotificationToken: NotificationToken? = nil
    @State private var MVS: SingleManagedViewService = SingleManagedViewService()
    @State private var isDisabled = false
    @State private var lifeIsLocked = false
    @State private var lifeDateUpdated = Int(Date().timeIntervalSince1970)
    
    @State private var dragOffset: CGSize = .zero
    @State private var lifeCenterX: CGFloat = 0.0
    @State private var lifeCenterY: CGFloat = 0.0
    @State private var lifeStartX: CGFloat = 0.0
    @State private var lifeStartY: CGFloat = 0.0
    @State private var lifeEndX: CGFloat = 0.0
    @State private var lifeEndY: CGFloat = 0.0
    
    @State private var lifeLineLength = 0.0
    @State private var lifeWidthTouch = 300.0
    @State private var lifeHeightTouch = 300.0
    
    @State private var lifeWidth: Double = 10.0
    @State private var lifeColor = Color.red
    
    @State private var lifeColorRed = 0.0
    @State private var lifeColorGreen = 0.0
    @State private var lifeColorBlue = 0.0
    @State private var lifeColorAlpha = 1.0
    @State private var lifeLineDash = 0.0
    @State private var lifeHeadIsEnabled = true
    @State private var lifeRotation: Angle = Angle.zero
    
    @State private var popUpIsVisible = false
    @State private var anchorsAreVisible = false
    
    @State private var offset = CGSize.zero
    @State private var position = CGPoint(x: 0, y: 0)
    @State private var isDragging = false
    @State var originalLifeStart = CGPoint.zero
    @State var originalLifeEnd = CGPoint.zero
    @State var originalLifeCenter = CGPoint.zero
    
    @State private var objectNotificationToken: NotificationToken? = nil
    @State private var cancellables = Set<AnyCancellable>()
    
    // Functions
    func isDisabledChecker() -> Bool { return isDisabled }
    func isDeletedChecker() -> Bool { return self.MVS.isDeleted }

    private var lineLength: CGFloat {
        sqrt(pow(lifeEndX - lifeStartX, 2) + pow(lifeEndY - lifeStartY, 2))-100
    }
    
    func loadRotationOfLine() {
        let lineStart = CGPoint(x: lifeStartX, y: lifeStartY)
        let lineEnd = CGPoint(x: lifeEndX, y: lifeEndY)
        lifeRotation = rotationAngleOfLine(from: lineStart, to: lineEnd)
        print(lifeRotation)
    }
    
    func loadWidthAndHeight() {
        let lineStart = CGPoint(x: lifeStartX, y: lifeStartY)
        let lineEnd = CGPoint(x: lifeEndX, y: lifeEndY)
        let (lineWidth, lineHeight) = getWidthAndHeightOfLine(start: lineStart, end: lineEnd)
        lifeWidthTouch = Double(lineWidth).bound(to: 100...200)
        lifeHeightTouch = Double(lineHeight).bound(to: 100...200)
    }
    
    func loadControlAnchor() {
        let t: CGFloat = 0.5
        lifeCenterX = (pow(1-t, 2) * lifeStartX + 2*(1-t)*t*lifeCenterX + pow(t, 2) * lifeEndX)
        lifeCenterY = (pow(1-t, 2) * lifeStartY + 2*(1-t)*t*lifeCenterY + pow(t, 2) * lifeEndY)
    }
    
    func quadBezierPoint(start: CGPoint, end: CGPoint, control: CGPoint) -> CGPoint {
        let t: CGFloat = 0.5
        let x = pow(1-t, 2) * start.x + 2*(1-t)*t*control.x + pow(t, 2) * end.x
        let y = pow(1-t, 2) * start.y + 2*(1-t)*t*control.y + pow(t, 2) * end.y
        return CGPoint(x: x, y: y)
    }
    
    func calculateAngle(startX: CGFloat, startY: CGFloat, endX: CGFloat, endY: CGFloat) -> Double {
        let deltaX = endX - startX
        let deltaY = endY - startY
        let angle = atan2(deltaY, deltaX) * 180 / .pi
        return Double(angle) + 90
    }
    
    func calculateAngleAtEndPointOfQuadCurve() -> Double {
        // Since we are calculating the angle at the end point, t = 1
        let t: CGFloat = 1.0

        // Breaking down the derivative calculation into smaller parts
        let dx1 = lifeCenterX - lifeStartX
        let dy1 = lifeCenterY - lifeStartY
        let dx2 = lifeEndX - lifeCenterX
        let dy2 = lifeEndY - lifeCenterY

        let derivativeX = 2 * (1 - t) * dx1 + 2 * t * dx2
        let derivativeY = 2 * (1 - t) * dy1 + 2 * t * dy2

        // Calculate the angle
        let angle = atan2(derivativeY, derivativeX) * 180 / .pi
        return Double(angle) + 90
    }

    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: lifeStartX, y: lifeStartY))
            path.addQuadCurve(to: CGPoint(x: lifeEndX, y: lifeEndY),
                              control: CGPoint(x: lifeCenterX, y: lifeCenterY))
        }
        .stroke(lifeColor, style: StrokeStyle(lineWidth: lifeWidth, dash: [lifeLineDash]))
        .opacity(!isDisabledChecker() && !isDeletedChecker() ? 1 : 0.0)
        .overlay(
            MatchedShape(
                startPoint: CGPoint(x: lifeStartX, y: lifeStartY),
                endPoint: CGPoint(x: lifeEndX, y: lifeEndY),
                controlPoint1: CGPoint(x: lifeCenterX, y: lifeCenterY)
            ).gesture(fullCurvedLineDragGesture())
        )
        .overlay(
            Triangle()
                .fill(anchorsAreVisible ? Color.AIMYellow : lifeColor)
                .frame(width: 125, height: 125) // Increase size for finger tapping
                .opacity(lifeHeadIsEnabled ? 1 : 0) // Invisible
                .rotationEffect(Angle(degrees: calculateAngleAtEndPointOfQuadCurve()))
                .position(x: lifeEndX, y: lifeEndY)
                .gesture(dragSingleAnchor(isStart: false))
        )
        .overlay(
            Circle()
                .fill(Color.AIMYellow)
                .frame(width: 150, height: 150) // Adjust size for easier tapping
                .opacity(anchorsAreVisible ? 1 : 0) // Invisible
                .position(x: lifeStartX, y: lifeStartY)
                .gesture(dragSingleAnchor(isStart: true))
        )
        .overlay(
            Circle()
                .fill(Color.AIMYellow)
                .frame(width: 150, height: 150) // Increase size for finger tapping
                .opacity(anchorsAreVisible ? 1 : 0) // Invisible
                .position(x: lifeEndX, y: lifeEndY)
                .gesture(dragSingleAnchor(isStart: false))
        )
        .overlay(
            Circle() // Use a circle for the control point
                .fill(Color.AIMYellow)
                .frame(width: 150, height: 150) // Adjust size as needed
                .opacity(anchorsAreVisible ? 1 : 0)
                .position(quadBezierPoint(start: CGPoint(x: lifeStartX, y: lifeStartY), end: CGPoint(x: lifeEndX, y: lifeEndY), control: CGPoint(x: lifeCenterX, y: lifeCenterY)))
                .gesture(dragCurvedCenterAnchor())
        )
        .gesture(fullCurvedLineDragGesture())
        .onAppear() {
        
            MVS.initialize(realm: self.realmInstance, activityId: self.activityId, viewId: self.viewId)
            loadFromRealm()
            
            observeView()

            CodiChannel.TOOL_ATTRIBUTES.receive(on: RunLoop.main) { vId in
                let temp = vId as! ViewAtts
                if viewId != temp.viewId {return}
                if temp.isDeleted {
                    isDisabled = true
                    return
                }
                if let ts = temp.size { lifeWidth = ts }
                if let tc = temp.color { lifeColor = tc }
                if let tstroke = temp.stroke { lifeWidth = tstroke }
                
                if let tl = temp.isLocked { lifeIsLocked = tl }
                
                if temp.stateAction == "close" {
                    popUpIsVisible = false
                }
                
                updateRealm()
            }.store(in: &cancellables)
            CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { vId in
                let temp = vId as! WindowController
                if temp.windowId != self.menuWindowId {return}
                if temp.stateAction == "close" {
                    popUpIsVisible = false
                    anchorsAreVisible = false
                }
            }.store(in: &cancellables)
        }
    }
    
    func fullCurvedLineDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                if self.lifeIsLocked { return }
                self.isDragging = true
                
                if self.originalLifeStart == .zero {
                    self.originalLifeStart = CGPoint(x: lifeStartX, y: lifeStartY)
                    self.originalLifeEnd = CGPoint(x: lifeEndX, y: lifeEndY)
                    self.originalLifeCenter = CGPoint(x: lifeCenterX, y: lifeCenterY)
                }
                
                handleFullDragTranslation(value: value)
            }
            .onEnded { value in
                handleFullDragTranslation(value: value)
                self.isDragging = false
                self.originalLifeStart = .zero
                self.originalLifeEnd = .zero
                self.originalLifeCenter = .zero
            }
            .simultaneously(with: longPressGesture())
    }
    
    func handleFullDragTranslation(value: DragGesture.Value) {
        let dragAmount = value.translation
        let startPoint = CGPoint(x: originalLifeStart.x + dragAmount.width, y: originalLifeStart.y + dragAmount.height)
        let controlPoint = CGPoint(x: originalLifeCenter.x + dragAmount.width, y: originalLifeCenter.y + dragAmount.height)
        let endPoint = CGPoint(x: originalLifeEnd.x + dragAmount.width, y: originalLifeEnd.y + dragAmount.height)
        
        lifeStartX = startPoint.x
        lifeStartY = startPoint.y
        lifeCenterX = controlPoint.x
        lifeCenterY = controlPoint.y
        lifeEndX = endPoint.x
        lifeEndY = endPoint.y
        
        updateRealmPos(start: CGPoint(x: lifeStartX, y: lifeStartY),
                    end: CGPoint(x: lifeEndX, y: lifeEndY))
    }
    
    
    // Drag gesture definition
    private func doubleTapForSettingsAndAnchors() -> some Gesture {
        TapGesture(count: 2).onEnded({ _ in
            print("Tapped double")
            anchorsAreVisible = !anchorsAreVisible
            popUpIsVisible = !popUpIsVisible
            CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(
                windowId: self.menuWindowId,
               stateAction: popUpIsVisible ? "open" : "close",
               viewId: viewId,
               x: self.lifeStartX,
               y: self.lifeStartY
            ))
            if popUpIsVisible {
                CodiChannel.TOOL_ATTRIBUTES.send(value: ViewAtts(
                   viewId: viewId,
                   color: lifeColor,
                   stroke: lifeWidth,
                   position: CGPoint(x: lifeStartX, y: lifeStartY),
                   toolType: "Line",
                   level: ToolLevels.LINE.rawValue,
                   isLocked: lifeIsLocked,
                   stateAction: popUpIsVisible ? "open" : "close")
                )
            }
        })
        .simultaneously(with: longPressGesture())
    }

    
    func dragCurvedCenterAnchor() -> some Gesture {
        DragGesture()
            .onChanged { value in
                if self.lifeIsLocked {return}
                if dragOffset == .zero {
                    dragOffset = CGSize(width: (lifeCenterX - value.startLocation.x),
                                        height: (lifeCenterY - value.startLocation.y))
                }
                lifeCenterX = (value.location.x + dragOffset.width)
                lifeCenterY = (value.location.y + dragOffset.height)
            }
            .onEnded { _ in
                dragOffset = .zero
                updateRealm()
            }
            .simultaneously(with: longPressGesture())
    }

    
    // Drag gesture definition
    private func dragSingleAnchor(isStart: Bool) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if self.lifeIsLocked {return}
                if !anchorsAreVisible {return}
                self.isDragging = true
                if isStart {
                    self.lifeStartX = value.location.x
                    self.lifeStartY = value.location.y
                    CodiChannel.TOOL_ON_FOLLOW.send(value: ViewFollowing(
                        viewId: self.viewId,
                        x: self.lifeStartX,
                        y: (self.lifeStartY + 200)
                    ))
                } else {
                    self.lifeEndX = value.location.x
                    self.lifeEndY = value.location.y
                }
                loadWidthAndHeight()
                loadRotationOfLine()
                updateRealmPos(start: CGPoint(x: lifeStartX, y: lifeStartY),
                            end: CGPoint(x: lifeEndX, y: lifeEndY))
            }
            .onEnded { _ in
                if self.lifeIsLocked {return}
                if !anchorsAreVisible {return}
                self.isDragging = false
                updateRealmPos(start: CGPoint(x: lifeStartX, y: lifeStartY),
                            end: CGPoint(x: lifeEndX, y: lifeEndY))
            }
            .simultaneously(with: longPressGesture())
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
           anchorsAreVisible = !anchorsAreVisible
       }
    }
    
    func observeView() {
        observeFromRealm()
        MVS.startFirebaseObserver()
    }
    
    func observeFromRealm() {
        if isDisabledChecker() || isDeletedChecker() {return}
        
        MVS.observeRealmManagedView() { temp in
            if self.isDragging {return}
            
            DispatchQueue.main.async {
                if self.isDragging {return}
                if activityId != temp.boardId { activityId = temp.boardId }
                self.MVS.isDeleted = temp.isDeleted
                if lifeWidth != Double(temp.width) {lifeWidth = Double(temp.width)}
                if lifeLineDash != Double(temp.lineDash) {lifeLineDash = Double(temp.lineDash)}
                
                var colorHasChanged = false
                if lifeColorRed != temp.colorRed { colorHasChanged = true; lifeColorRed = temp.colorRed}
                if lifeColorGreen != temp.colorGreen { colorHasChanged = true; lifeColorGreen = temp.colorGreen}
                if lifeColorBlue != temp.colorBlue { colorHasChanged = true; lifeColorBlue = temp.colorBlue }
                if lifeColorAlpha != temp.colorAlpha { colorHasChanged = true; lifeColorAlpha = temp.colorAlpha }
                if colorHasChanged {
                    lifeColor = colorFromRGBA(red: lifeColorRed, green: lifeColorGreen, blue: lifeColorBlue, alpha: lifeColorAlpha)
                }
                loadWidthAndHeight()
                loadRotationOfLine()
                //
                
                if temp.lastUserId != getFirebaseUserIdOrCurrentLocalId() {
                    let startPosition = CGPoint(x: temp.startX, y: temp.startY)
                    let endPosition = CGPoint(x: temp.endX, y: temp.endY)
                    let centerPosition = CGPoint(x: temp.centerX, y: temp.centerY)
                    
                    let coords = [
                        "start":startPosition,
                        "end":endPosition,
                        "center":centerPosition
                    ]
                    
                    self.coordinateStack.append(coords)
                    animateToNextCoordinate()
                }
                
                lifeHeadIsEnabled = temp.headIsEnabled
                
                if lifeIsLocked != temp.isLocked { lifeIsLocked = temp.isLocked}
            }
            
        }
    }
    
    // Function to update a Realm object in the background
    func updateRealmPos(start: CGPoint? = nil, end: CGPoint? = nil) {
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    if let mv = realm.findByField(ManagedView.self, value: self.viewId) {
                        try realm.write {
                            mv.startX = Double(start?.x ?? CGFloat(lifeStartX))
                            mv.startY = Double(start?.y ?? CGFloat(lifeStartY))
                            mv.centerX = Double(lifeCenterX)
                            mv.centerY = Double(lifeCenterY)
                            mv.endX = Double(end?.x ?? CGFloat(lifeEndX))
                            mv.endY = Double(end?.y ?? CGFloat(lifeEndY))
                            mv.lastUserId = getFirebaseUserIdOrCurrentLocalId()
                        }
                        
                        MVS.updateFirebase(mv: mv)
                    }
                } catch {
                    print("Realm error: \(error)")
                }
            }
        }
    }
    
    func animateToNextCoordinate() {
        print("!!!COORDINATES COUNT: \(coordinateStack.count)")
        guard !coordinateStack.isEmpty || self.isDragging else {
            return
        }
        
        let nextCoordinate = coordinateStack.removeFirst()

        withAnimation {
            lifeStartX = nextCoordinate["start"]?.x ?? lifeStartX
            lifeStartY = nextCoordinate["start"]?.y ?? lifeStartY
            lifeEndX = nextCoordinate["end"]?.x ?? lifeEndX
            lifeEndY = nextCoordinate["end"]?.y ?? lifeEndY
            let lifeCenterPoint = nextCoordinate["center"] ?? .zero
            lifeCenterX = lifeCenterPoint.x
            lifeCenterY = lifeCenterPoint.y
        }

        // Schedule the next animation after a delay
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if !self.coordinateStack.isEmpty {
                self.animateToNextCoordinate()
            }
        }
    }
    
    func updateRealm(start: CGPoint? = nil, end: CGPoint? = nil) {
        if isDisabledChecker() {return}
        if isDeletedChecker() {return}
        let mv = realmInstance.findByField(ManagedView.self, value: viewId)
        if mv == nil { return }
        realmInstance.safeWrite { r in
            mv?.startX = Double(start?.x ?? CGFloat(lifeStartX))
            mv?.startY = Double(start?.y ?? CGFloat(lifeStartY))
            mv?.centerX = Double(start?.x ?? CGFloat(lifeCenterX))
            mv?.centerY = Double(start?.y ?? CGFloat(lifeCenterY))
            mv?.endX = Double(end?.x ?? CGFloat(lifeEndX))
            mv?.endY = Double(end?.y ?? CGFloat(lifeEndY))
            
            if let lc = lifeColor.toRGBA() {
                mv?.colorRed = lc.red
                mv?.colorGreen = lc.green
                mv?.colorBlue = lc.blue
                mv?.colorAlpha = lc.alpha
            }
            mv?.isLocked = self.isDragging ? true : lifeIsLocked
            mv?.toolType = "CURVED-LINE"
            mv?.width = Int(lifeWidth)
            mv?.headIsEnabled = lifeHeadIsEnabled
            mv?.lastUserId = getFirebaseUserIdOrCurrentLocalId()
            // TODO: Firebase Users ONLY
            MVS.updateFirebase(mv: mv)
        }
    }
    
    func loadFromRealm() {
        if isDisabledChecker() {return}
        if isDeletedChecker() {return}
        if let umv = realmInstance.object(ofType: ManagedView.self, forPrimaryKey: viewId) {
            // set attributes
            activityId = umv.boardId
            lifeIsLocked = umv.isLocked
            
            lifeStartX = umv.startX
            lifeStartY = umv.startY
            lifeCenterX = umv.centerX
            lifeCenterY = umv.centerY
            lifeEndX = umv.endX
            lifeEndY = umv.endY
            lifeWidth = Double(umv.width)
            lifeLineDash = Double(umv.lineDash)
            lifeHeadIsEnabled = umv.headIsEnabled
            
            lifeColorRed = umv.colorRed
            lifeColorGreen = umv.colorGreen
            lifeColorBlue = umv.colorBlue
            lifeColorAlpha = umv.colorAlpha
            lifeColor = colorFromRGBA(red: lifeColorRed, green: lifeColorGreen, blue: lifeColorBlue, alpha: lifeColorAlpha)
            
            loadWidthAndHeight()
            loadRotationOfLine()
        }
    }
    
}

