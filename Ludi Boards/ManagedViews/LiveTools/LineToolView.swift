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
    @EnvironmentObject var BEO: BoardEngineObject
    var managedView: ManagedView? = nil
    private let menuWindowId = "mv_settings"
    
    @State private var coordinateStack: [[String:CGPoint]] = []
    
    @State private var managedViewNotificationToken: NotificationToken? = nil
    @State private var MVS: SingleManagedViewService = SingleManagedViewService()
    @State private var isDisabled = false
    @State private var lifeIsLocked = false
    @State private var lifeDateUpdated = Int(Date().timeIntervalSince1970)
    
    @State private var lifeHeadIsEnabled = true
    @State private var lifeCenterPoint = CGPoint.zero
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
    @State private var lifeRotation: Angle = Angle.zero
    
    @State private var popUpIsVisible = false
    @State private var anchorsAreVisible = false
    
    @State private var offset = CGSize.zero
    @State private var position = CGPoint(x: 0, y: 0)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State var originalLifeStart = CGPoint.zero
    @State var originalLifeEnd = CGPoint.zero
    
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
    
    func loadCenterPoint() {
        let lineStart = CGPoint(x: lifeStartX, y: lifeStartY)
        let lineEnd = CGPoint(x: lifeEndX, y: lifeEndY)
        lifeCenterPoint = getCenterOfLine(start: lineStart, end: lineEnd)
    }
    func loadWidthAndHeight() {
        let lineStart = CGPoint(x: lifeStartX, y: lifeStartY)
        let lineEnd = CGPoint(x: lifeEndX, y: lifeEndY)
        let (lineWidth, lineHeight) = getWidthAndHeightOfLine(start: lineStart, end: lineEnd)
        lifeWidthTouch = Double(lineWidth)
        lifeHeightTouch = Double(lineHeight)
    }
    func lengthOfLine(start: CGPoint, end: CGPoint) -> CGFloat {
        let deltaX = end.x - start.x
        let deltaY = end.y - start.y
        return sqrt(deltaX * deltaX + deltaY * deltaY)
    }
    
    func boundedLength(start: CGPoint, end: CGPoint) -> CGFloat {
        let length = lengthOfLine(start: start, end: end)
        return length.bounded(byMin: 1.0, andMax: length - 400.0)
    }
    
    func calculateAngle(startX: CGFloat, startY: CGFloat, endX: CGFloat, endY: CGFloat) -> Double {
        let deltaX = endX - startX
        let deltaY = endY - startY
        let angle = atan2(deltaY, deltaX) * 180 / .pi
        return Double(angle) + 90
    }
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: lifeStartX, y: lifeStartY))
            path.addLine(to: CGPoint(x: lifeEndX, y: lifeEndY))
        }
        .stroke(lifeColor, style: StrokeStyle(lineWidth: lifeWidth, dash: [lifeLineDash]))
        .opacity(!isDisabledChecker() && !isDeletedChecker() ? 1 : 0.0)
        .overlay(
            Triangle()
                .fill(anchorsAreVisible ? Color.AIMYellow : lifeColor)
                .frame(width: (lifeWidth*2).bound(to: 125...1000), height: (lifeWidth*2).bound(to: 125...1000)) // Increase size for finger tapping
                .opacity(lifeHeadIsEnabled ? 1 : 0) // Invisible
                .rotationEffect(Angle(degrees: calculateAngle(startX: lifeStartX, startY: lifeStartY, endX: lifeEndX, endY: lifeEndY)))
                .position(x: lifeEndX, y: lifeEndY)
                .gesture(singleAnchorDragGesture(isStart: false))
        )
        .overlay(
            Circle()
                .fill(Color.AIMYellow)
                .frame(width: 150, height: 150) // Adjust size for easier tapping
                .opacity(anchorsAreVisible ? 1 : 0) // Invisible
                .position(x: lifeStartX, y: lifeStartY)
                .gesture(singleAnchorDragGesture(isStart: true))
        )
        .overlay(
            Circle()
                .fill(Color.AIMYellow)
                .frame(width: 150, height: 150) // Increase size for finger tapping
                .opacity(anchorsAreVisible && !lifeHeadIsEnabled  ? 1 : 0) // Invisible
                .position(x: lifeEndX, y: lifeEndY)
                .gesture(singleAnchorDragGesture(isStart: false))
        )
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.001))
                .frame(width: boundedLength(start: CGPoint(x: lifeStartX, y: lifeStartY), end: CGPoint(x: lifeEndX, y: lifeEndY)), height: Double(lifeWidth+300))
                .rotationEffect(lifeRotation)
                .opacity(1)
                .position(x: lifeCenterPoint.x.isFinite ? lifeCenterPoint.x : 0, y: lifeCenterPoint.y.isFinite ? lifeCenterPoint.y : 0)
                .gesture(fullLineDragGesture())
        )
        .gesture(fullLineDragGesture())
        .onAppear() {
        
            MVS.initialize(realm: self.BEO.realmInstance, activityId: self.activityId, viewId: self.viewId)
            loadFromRealm()
            observeView()

            // Codi Channels
            onToolAttributes()
            onWindowController()
        }
    }
    
    @MainActor
    func onToolAttributes() {
        CodiChannel.TOOL_ATTRIBUTES.receive(on: RunLoop.main) { vId in
            let temp = vId as! ViewAtts
            if viewId != temp.viewId {return}
            if temp.isDeleted {
                isDisabled = true
                return
            }
            
            if let tdash = temp.lineDash { lifeLineDash = tdash }
            if let thead = temp.headIsEnabled { lifeHeadIsEnabled = thead }
            if let ts = temp.size { lifeWidth = ts }
            if let tc = temp.color { lifeColor = tc }
            if let tstroke = temp.stroke { lifeWidth = tstroke }
            if let tl = temp.isLocked { lifeIsLocked = tl }
            
            if temp.stateAction == "close" {
                popUpIsVisible = false
            }
            
            updateRealm()
        }.store(in: &cancellables)
    }
    
    @MainActor
    func onWindowController() {
        CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { vId in
            let temp = vId as! WindowController
            if temp.windowId != self.menuWindowId {return}
            if temp.stateAction == "close" {
                popUpIsVisible = false
                anchorsAreVisible = false
            }
        }.store(in: &cancellables)
    }
    
    private func toggleMenuSettings() {
        anchorsAreVisible = !anchorsAreVisible
        popUpIsVisible = !popUpIsVisible
        CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(
           windowId: self.menuWindowId,
           stateAction: popUpIsVisible ? "open" : "close",
           viewId: viewId,
           x: self.lifeStartX + 500,
           y: self.lifeStartY
        ))
        if popUpIsVisible {
            CodiChannel.TOOL_ATTRIBUTES.send(value: ViewAtts(
               viewId: viewId,
               color: lifeColor,
               stroke: lifeWidth,
               position: CGPoint(x: lifeStartX, y: lifeStartY),
               headIsEnabled: lifeHeadIsEnabled,
               lineDash: lifeLineDash,
               toolType: "LINE",
               level: ToolLevels.LINE.rawValue,
               isLocked: lifeIsLocked,
               stateAction: popUpIsVisible ? "open" : "close")
            )
        }
    }
    
    // Gestures
    private func fullLineDragGesture() -> some Gesture {
        DragGesture()
            .updating($dragOffset, body: { (value, state, transaction) in
                if self.lifeIsLocked {return}
                state = value.translation
            })
            .onChanged { value in
                if self.lifeIsLocked {return}
                self.isDragging = true
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
                CodiChannel.TOOL_ON_FOLLOW.send(value: ViewFollowing(
                    viewId: self.viewId,
                    x: lifeStartX,
                    y: lifeStartY
                ))
                updateRealmPos(start: CGPoint(x: lifeStartX, y: lifeStartY),
                            end: CGPoint(x: lifeEndX, y: lifeEndY))
            }
            .onEnded { value in
                if self.lifeIsLocked {return}
                let translation = value.translation
                lifeStartX = self.originalLifeStart.x + translation.width
                lifeStartY = self.originalLifeStart.y + translation.height
                lifeEndX = self.originalLifeEnd.x + translation.width
                lifeEndY = self.originalLifeEnd.y + translation.height
                loadCenterPoint()
                self.isDragging = false
                updateRealmPos(start: CGPoint(x: lifeStartX, y: lifeStartY),
                            end: CGPoint(x: lifeEndX, y: lifeEndY))
                self.originalLifeStart = .zero
                self.originalLifeEnd = .zero
            }
            .simultaneously(with: doubleTapGesture())
            .simultaneously(with: longPressGesture())
    }
    
    private func singleAnchorDragGesture(isStart: Bool) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if self.lifeIsLocked || !anchorsAreVisible { return }
                self.isDragging = true
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
                updateRealmPos(start: CGPoint(x: lifeStartX, y: lifeStartY),
                            end: CGPoint(x: lifeEndX, y: lifeEndY))
            }
            .onEnded { _ in
                if self.lifeIsLocked || !anchorsAreVisible { return }
                self.isDragging = false
                updateRealmPos(start: CGPoint(x: lifeStartX, y: lifeStartY),
                            end: CGPoint(x: lifeEndX, y: lifeEndY))
            }
            .simultaneously(with: doubleTapGesture())
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
            toggleMenuSettings()
         })
    }
    
    private func longPressGesture() -> some Gesture {
        LongPressGesture(minimumDuration: 0.4).onEnded { _ in
           anchorsAreVisible = !anchorsAreVisible
       }
    }
    
    
    // Observers
    
    func observeView() {
        observeFromRealm()
        MVS.startFirebaseObserver()
    }
    
    func observeFromRealm() {
        if isDisabledChecker() || isDeletedChecker() {return}
        
        MVS.observeRealmManagedView() { temp in
            print("!!ManagedToolView!!")
            
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
                
                if temp.lastUserId != (getFirebaseUserId() ?? CURRENT_USER_ID) {
                    let startPosition = CGPoint(x: temp.startX, y: temp.startY)
                    let endPosition = CGPoint(x: temp.endX, y: temp.endY)
                    let centerPosition = getCenterOfLine(start: startPosition, end: endPosition)
                    
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
                            mv.endX = Double(end?.x ?? CGFloat(lifeEndX))
                            mv.endY = Double(end?.y ?? CGFloat(lifeEndY))
                            mv.lastUserId = getFirebaseUserId() ?? CURRENT_USER_ID
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
        
        guard !coordinateStack.isEmpty || self.isDragging || !self.BEO.isSharedBoard else {
            return
        }
        
        let nextCoordinate = coordinateStack.removeFirst()

        withAnimation {
            lifeStartX = nextCoordinate["start"]?.x ?? lifeStartX
            lifeStartY = nextCoordinate["start"]?.y ?? lifeStartY
            lifeEndX = nextCoordinate["end"]?.x ?? lifeEndX
            lifeEndY = nextCoordinate["end"]?.y ?? lifeEndY
            lifeCenterPoint = nextCoordinate["center"] ?? lifeCenterPoint
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
        let mv = self.BEO.realmInstance.findByField(ManagedView.self, value: viewId)
        if mv == nil { return }
        self.BEO.realmInstance.safeWrite { r in
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
            mv?.isLocked = self.isDragging ? true : lifeIsLocked
            mv?.toolType = "LINE"
            mv?.width = Int(lifeWidth)
            mv?.lineDash = Int(lifeLineDash)
            mv?.lastUserId = getFirebaseUserIdOrCurrentLocalId()
            mv?.headIsEnabled = lifeHeadIsEnabled
            MVS.updateFirebase(mv: mv)
        }
    }
    
    func loadFromRealm() {
        if isDisabledChecker() || isDeletedChecker() {return}
        if let umv = self.BEO.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: viewId) {
            // set attributes
            activityId = umv.boardId
            lifeIsLocked = umv.isLocked
            
            lifeStartX = umv.startX
            lifeStartY = umv.startY
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
            
            loadCenterPoint()
            loadWidthAndHeight()
            loadRotationOfLine()
        }
    }
    
}


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
        .stroke(Color.white.opacity(0.01), style: StrokeStyle(lineWidth: 300.0, dash: [1]))
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

