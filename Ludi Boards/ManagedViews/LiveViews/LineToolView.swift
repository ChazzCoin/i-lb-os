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

struct LineDrawingView: View {
    @State var managedView: ManagedView

    @State private var offset = CGSize.zero
    @State private var position = CGPoint(x: 0, y: 0)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: managedView.startX, y: managedView.startY))
            path.addLine(to: CGPoint(x: managedView.endX, y: managedView.endY))
        }
        .stroke(Color.red, lineWidth: CGFloat(managedView.width))
        .offset(x: position.x + (isDragging ? dragOffset.width : 0), y: position.y + (isDragging ? dragOffset.height : 0))
        .gesture(
            DragGesture()
                .updating($dragOffset, body: { (value, state, transaction) in
                    state = value.translation
                })
                .onChanged { _ in
                    self.isDragging = true
                }
                .onEnded { value in
                    self.position = CGPoint(x: self.position.x + value.translation.width, y: self.position.y + value.translation.height)
                    self.isDragging = false
                }
        )
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

struct LineDrawingManaged: View {
    let viewId: String
    @State var boardId: String = "boardEngine-1"
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
    @State private var lifeRotation: Angle = Angle.zero
    
    @State private var popUpIsVisible = false
    
    @State private var offset = CGSize.zero
    @State private var position = CGPoint(x: 0, y: 0)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State var originalLifeStart = CGPoint.zero
    @State var originalLifeEnd = CGPoint.zero
    
    // Firebase
    let reference = Database.database().reference().child(DatabasePaths.managedViews.rawValue)
    
    @State private var objectNotificationToken: NotificationToken? = nil
    @State private var cancellables = Set<AnyCancellable>()
    
    // Functions
    func isDisabledChecker() -> Bool { return isDisabled }
    func isDeletedChecker() -> Bool { return isDeleted }
//    func minSizeCheck() {
//        if lifeWidth < minSizeWH { lifeWidth = minSizeWH }
//    }
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
                .frame(width: 100, height: 100) // Adjust size for easier tapping
                .opacity(popUpIsVisible ? 1 : 0) // Invisible
                .position(x: lifeStartX, y: lifeStartY)
                .gesture(dragGesture(isStart: true))
        )
        .overlay(
            Circle()
                .fill(Color.AIMYellow)
                .frame(width: 100, height: 100) // Increase size for finger tapping
                .opacity(popUpIsVisible ? 1 : 0) // Invisible
                .position(x: lifeEndX, y: lifeEndY)
                .gesture(dragGesture(isStart: false))
        )
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.001))
                .frame(width: lifeWidth, height: 100)
                .rotationEffect(lifeRotation)
                .opacity(1)
                .position(x: lifeCenterPoint.x.isFinite ? lifeCenterPoint.x : 0, y: lifeCenterPoint.y.isFinite ? lifeCenterPoint.y : 0)
                .gesture(dragGestureDuo())
        )
        .gesture(dragGestureDuo())
        .onAppear() {
            loadFromRealm()
//            observeFirebase()
            CodiChannel.TOOL_ATTRIBUTES.receive(on: RunLoop.main) { vId in
                let temp = vId as! ViewAtts
                if viewId != temp.viewId {return}
                if let ts = temp.size { lifeWidth = ts }
                if temp.stateAction == "close" {
                    popUpIsVisible = false
                }
                if temp.isDeleted {
                    isDeleted = true
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
                if !popUpIsVisible {return}
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
                if !popUpIsVisible {return}
                updateRealm()
            }
            .simultaneously(with: TapGesture(count: 2)
                 .onEnded { _ in
                     print("Tapped double")
                     popUpIsVisible = !popUpIsVisible
                     CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: "mv_settings", stateAction: popUpIsVisible ? "open" : "close", viewId: viewId))
                     if popUpIsVisible {
                         CodiChannel.TOOL_ATTRIBUTES.send(value: ViewAtts(viewId: viewId, size: lifeWidth, stateAction: popUpIsVisible ? "open" : "close"))
                     }
                 }
            )
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
            }.simultaneously(with: TapGesture(count: 2)
                .onEnded { _ in
                    print("Tapped duo")
                    popUpIsVisible = !popUpIsVisible
                    CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: "mv_settings", stateAction: popUpIsVisible ? "open" : "close", viewId: viewId))
                    if popUpIsVisible {
                        CodiChannel.TOOL_ATTRIBUTES.send(value: ViewAtts(viewId: viewId, size: lifeWidth))
                    }
                }
           )
    }
    
    func updateRealm(start: CGPoint? = nil, end: CGPoint? = nil) {
        print("!!!! Updating Realm!")
        if isDisabledChecker() {return}
//        lifeUpdatedAt = Int(Date().timeIntervalSince1970)
        let mv = realmInstance.findByField(ManagedView.self, value: viewId)
        if mv == nil { return }
        realmInstance.safeWrite { r in
            lifeDateUpdated = Int(Date().timeIntervalSince1970)
            mv?.dateUpdated = lifeDateUpdated
            mv?.startX = Double(start?.x ?? CGFloat(lifeStartX))
            mv?.startY = Double(start?.y ?? CGFloat(lifeStartY))
            mv?.endX = Double(end?.x ?? CGFloat(lifeEndX))
            mv?.endY = Double(end?.y ?? CGFloat(lifeEndY))
//            mv?.toolColor = lifeColor.rawValue
            mv?.toolType = "LINE"
            mv?.width = Int(lifeWidth)
            guard let tMV = mv else { return }
            r.create(ManagedView.self, value: tMV, update: .all)
            firebaseDatabase { fdb in
                fdb.child(DatabasePaths.managedViews.rawValue)
                    .child(boardId)
                    .child(viewId)
                    .setValue(mv?.toDictionary())
            }
        }
    }
    
    func loadFromRealm() {
        let mv = realmInstance.object(ofType: ManagedView.self, forPrimaryKey: viewId)
        guard let umv = mv else { return }
        // set attributes
        lifeStartX = umv.startX
        lifeStartY = umv.startY
        lifeEndX = umv.endX
        lifeEndY = umv.endY
        lifeWidth = Double(umv.width)
        loadCenterPoint()
        loadWidthAndHeight()
        loadRotationOfLine()
        
//        objectNotificationToken = umv.observe { change in
//            switch change {
//                case .change(let object, _):
//                    let obj = object as! ManagedView
//                    if obj.dateUpdated <= lifeDateUpdated { return }
//                    lifeStartX = obj.startX
//                    lifeStartY = obj.startY
//                    lifeEndX = obj.endX
//                    lifeEndY = obj.endY
//                    lifeWidth = Double(obj.width)
//                    loadCenterPoint()
//                    loadWidthAndHeight()
//                    loadRotationOfLine()
//                    print("\(object)")
//                case .error(let error):
//                    print("An error occurred: \(error)")
//                case .deleted:
//                    isDeleted = true
//                    isDisabled = true
//            }
//        }
    }
    
    func observeFirebase() {
        // TODO: make this more rock solid, error handling, retry logic...
        if boardId.isEmpty || viewId.isEmpty {return}
        DispatchQueue.global(qos: .userInitiated).async {
            reference.child(boardId).child(viewId).fireObserver { snapshot in
                let _ = snapshot.toLudiObject(ManagedView.self, realm: realmInstance)
            }
        }
    }
}

struct LineOverlay: View {
    var startPoint: CGPoint
    var endPoint: CGPoint
    let lineThickness: CGFloat = 2 // Adjust as needed

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

struct LineCreatorView: View {
    @State private var startPoint: CGPoint?
    @State private var endPoint: CGPoint?
    private let realm = try! Realm()
    
    @State private var isEnabled = true
    
    @State private var lifeWidth = 10.0
    @State private var lifeColor = Color.black
    
    @StateObject var viewModel = ViewModel()

    var body: some View {
        // Drawing existing lines from Realm

        if isEnabled {
            Canvas { context, size in
                
                // Drawing the current line
                if let start = startPoint, let end = endPoint {
                    var path = Path()
                    path.move(to: start)
                    path.addLine(to: end)
                    context.stroke(path, with: .color(lifeColor), lineWidth: lifeWidth)
                }

            }
            .frame(width: viewModel.width, height: viewModel.height)
            .position(x: viewModel.startPosX, y: viewModel.startPosY)
            .border(Color.yellow, width: 10)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isEnabled {return}
                        self.startPoint = value.startLocation
                        self.endPoint = value.location
                    }
                    .onEnded { value in
                        if !isEnabled {return}
                        self.endPoint = value.location
                        saveLineData(start: value.startLocation, end: value.location)
                    }
            )
        }
        
    }

    private func saveLineData(start: CGPoint, end: CGPoint) {
        realm.safeWrite { r in
            let line = ManagedView()
            line.boardId = "boardEngine-1"
            line.startX = Double(start.x)
            line.startY = Double(start.y)
            line.endX = Double(end.x)
            line.endY = Double(end.y)
            line.x = Double(start.x)
            line.y = Double(start.y)
            line.width = Int(lifeWidth)
            line.toolColor = "Black"
            line.toolType = "LINE"
            line.dateUpdated = Int(Date().timeIntervalSince1970)
            r.add(line, update: .modified)
        }
    }
}


struct LineViewManaged: View {
    let viewId: String
    var managedView: ManagedView? = nil
    
    let realmInstance = realm()
    @State private var lifeStartPointX = 0.0
    @State private var lifeStartPointY = 0.0
    @State private var lifeEndPointX = 0.0
    @State private var lifeEndPointY = 0.0
    
    @State private var lifeWidth = 10.0
    @State private var lifeColor = Color.black
    @State private var lifeRotation = 0.0
    
    let arrowSize: CGFloat = 50
    let lineWidth: CGFloat = 2
    
    @State private var offset = CGSize.zero
    @State private var position = CGPoint(x: 0, y: 0)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false
    
    func loadFromRealm() {
        
        let mv = realmInstance.object(ofType: ManagedView.self, forPrimaryKey: viewId)
        guard let umv = mv else { return }
        // set attributes
        lifeStartPointX = umv.startX
        lifeStartPointY = umv.startY
        self.position = CGPoint(x: umv.x, y: umv.y)
//        print("\(viewId) x: [ \(lifeOffsetX) ] y: [ \(lifeOffsetY) ]")
        lifeWidth = Double(umv.width)
        lifeRotation = Double(umv.rotation)
                
    }

    var body: some View {
        ZStack {
            Line(start: CGPoint(x: lifeStartPointX, y: lifeStartPointY), end: CGPoint(x: lifeEndPointX, y: lifeEndPointY))
                .stroke(Color.black, lineWidth: lineWidth)

            let angle = atan2(lifeEndPointY - lifeStartPointY, lifeEndPointX - lifeStartPointX) * 2
            Arrowhead(size: arrowSize)
                .frame(width: 10, height: 10)
                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 10)
                .rotationEffect(Angle(radians: Double(angle)), anchor: .center)
                .position(CGPoint(x: lifeStartPointX, y: lifeStartPointY))
        }
        .frame(width: 200, height: 200)
        .border(Color.red, width: 10)
        .offset(x: position.x + (isDragging ? dragOffset.width : 0), y: position.y + (isDragging ? dragOffset.height : 0))
        .gesture(
            DragGesture()
                .updating($dragOffset, body: { (value, state, transaction) in
                    state = value.translation
                })
                .onChanged { _ in
                    self.isDragging = true
                }
                .onEnded { value in
                    self.position = CGPoint(x: self.position.x + value.translation.width, y: self.position.y + value.translation.height)
                    self.isDragging = false
                }
        ).onAppear() {
            loadFromRealm()
        }
    }

    struct Line: Shape {
        var start: CGPoint
        var end: CGPoint

        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: start)
            path.addLine(to: end)
            return path
        }
    }

    struct Arrowhead: Shape {
        var size: CGFloat

        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -size / 2))
            path.addLine(to: CGPoint(x: size / 2, y: size / 2))
            path.addLine(to: CGPoint(x: -size / 2, y: size / 2))
            path.closeSubpath()
            return path
        }
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

