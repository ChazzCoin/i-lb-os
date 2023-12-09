//
//  DragAndDrop.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/13/23.
//

import Foundation
import SwiftUI
import FirebaseDatabase
import RealmSwift
import Combine

struct enableManagedViewTool : ViewModifier {
    @State var viewId: String
    @State var activityId: String
    
    let minSizeWH = 100.0
    
    let realmInstance = realm()
    
    @State private var updateDragCount = 0
    @State private var isAnimating = false
    @State private var coordinateStack: [CGPoint] = []
    
    @State private var MVS: ManagedViewService? = nil
    @State private var isDeleted = false
    @State private var isDisabled = false
    @State private var lifeIsLocked = false
    @State private var lifeUpdatedAt: Int = 0 // Using Double for time representation
    @State private var lifeBorderColor = Color.AIMYellow
    @State private var lifeColor = ColorProvider.black // SwiftUI color representation
//    @State private var lifeOffsetX: Double = 0.0 // CGFloat in SwiftUI
//    @State private var lifeOffsetY: Double = 0.0 // CGFloat in SwiftUI
    @State private var lifeWidth = 75.0 // CGFloat in SwiftUI
    @State private var lifeHeight = 75.0 // CGFloat in SwiftUI
    @State private var lifeScale = 1.0 // CGFloat for scale
    @State private var lifeRotation = 0.0 // Angle in degrees, represented by Double in SwiftUI
    @State private var lifeToolType = SoccerToolProvider.playerDummy.tool.image // Assuming 'toolType' is an enum or similar
    
    @State private var lifeColorRed = 0.0
    @State private var lifeColorGreen = 0.0
    @State private var lifeColorBlue = 0.0
    @State private var lifeColorAlpha = 1.0
    
    @State private var popUpIsVisible = false
    
    @State private var position = CGPoint(x: 100, y: 100)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var managedViewNotificationToken: NotificationToken? = nil
    // Firebase
    @State var reference = Database.database().reference().child(DatabasePaths.managedViews.rawValue)
    
    @State var cancellables = Set<AnyCancellable>()
    
    // Functions
    func isDisabledChecker() -> Bool { return isDisabled }
    func isDeletedChecker() -> Bool { return isDeleted }
    func minSizeCheck() {
        if lifeWidth < minSizeWH { lifeWidth = minSizeWH }
        if lifeHeight < minSizeWH { lifeHeight = minSizeWH }
    }
    
    func observeView() {
        observeFromRealm()
        MVS = ManagedViewService(realm: self.realmInstance, activityId: self.activityId, viewId: self.viewId)
        MVS?.start()
    }
    
    func loadFromRealm(managedView: ManagedView?=nil) {
        if isDisabledChecker() {return}
        var mv = managedView
        if mv == nil {mv = realmInstance.object(ofType: ManagedView.self, forPrimaryKey: viewId)}
        guard let umv = mv else { return }
        // set attributes
        activityId = umv.boardId
        self.position = CGPoint(x: umv.x, y: umv.y)
        lifeWidth = Double(umv.width)
        lifeHeight = Double(umv.height)
        lifeRotation = umv.rotation
        lifeToolType = umv.toolType
        lifeColorRed = umv.colorRed
        lifeColorGreen = umv.colorGreen
        lifeColorBlue = umv.colorBlue
        lifeColorAlpha = umv.colorAlpha
        lifeIsLocked = umv.isLocked
        minSizeCheck()
    }
    
    func observeFromRealm() {
        if isDisabledChecker() {return}
        if let mv = realmInstance.object(ofType: ManagedView.self, forPrimaryKey: viewId) {
            managedViewNotificationToken = mv.observe { change in
                if isDisabledChecker() {return}
                if isDragging {return}
                switch change {
                    case .change(let obj, _):
                        let temp = obj as! ManagedView
                        if temp.id != self.viewId {return}
                        if self.isDragging {return}
                        
                        DispatchQueue.main.async {
                            // Position
                            if self.isDragging {return}
                            let newPosition = CGPoint(x: temp.x, y: temp.y)
                            self.coordinateStack.append(newPosition)
                            animateToNextCoordinate()
                            
                            if activityId != temp.boardId {activityId = temp.boardId}
                            
                            if lifeWidth != Double(temp.width) {lifeWidth = Double(temp.width)}
                            if lifeHeight != Double(temp.height) { lifeHeight = Double(temp.height)}
                            if lifeRotation != temp.rotation { lifeRotation = temp.rotation}
                            if lifeToolType != temp.toolType { lifeToolType = temp.toolType}
                            if lifeColorRed != temp.colorRed {lifeColorRed = temp.colorRed}
                            if lifeColorGreen != temp.colorGreen { lifeColorGreen = temp.colorGreen}
                            if lifeColorBlue != temp.colorBlue {lifeColorBlue = temp.colorBlue}
                            if lifeColorAlpha != temp.colorAlpha { lifeColorAlpha = temp.colorAlpha}
                            if lifeIsLocked != temp.isLocked { lifeIsLocked = temp.isLocked}

//                            minSizeCheck()

                        }
                    case .error(let error):
                        // Handle errors, if any
                        print("Error: \(error)")
                    case .deleted:
                        // Object has been deleted
                        self.isDeleted = true
                        self.isDisabled = true
                        self.deleteToolFromFirebase()
                        print("Object has been deleted.")
                }
            }
        }

    }
    
    
    func animateToNextCoordinate() {
        print("!!!COORDINATES COUNT: \(coordinateStack.count)")
        guard !coordinateStack.isEmpty else {
            return
        }
        
        let nextCoordinate = coordinateStack.removeFirst()

        withAnimation {
            self.position = nextCoordinate
        }

        // Schedule the next animation after a delay
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if !self.coordinateStack.isEmpty {
                self.animateToNextCoordinate()
            }
        }
    }
    
    
    func updateRealm(isBackground: Bool=true, x:Double?=nil, y:Double?=nil) {
        print("!!!! Updating Realm!")
        if isDisabledChecker() {return}
        let tempRealm = isBackground ? realm() : self.realmInstance
        let mv = tempRealm.findByField(ManagedView.self, value: viewId)
        if mv == nil { return }
        let t = Int(Date().timeIntervalSince1970)
        try? tempRealm.write {
            mv?.dateUpdated = t
            mv?.x = x ?? self.position.x
            mv?.y = y ?? self.position.y
            mv?.rotation = lifeRotation
            mv?.toolType = lifeToolType
            mv?.width = Int(lifeWidth)
            mv?.height = Int(lifeHeight)
            mv?.colorRed = lifeColorRed
            mv?.colorGreen = lifeColorGreen
            mv?.colorBlue = lifeColorBlue
            mv?.colorAlpha = lifeColorAlpha
            mv?.isLocked = lifeIsLocked
            guard let tMV = mv else { return }
            tempRealm.create(ManagedView.self, value: tMV, update: .all)
            // TODO: Firebase Users ONLY
            updateToolInFirebase(mv:mv)
        }
    }
    
    func updateToolInFirebase(mv:ManagedView?) {
        // TODO: Firebase Users ONLY
        reference.setValue(mv?.toDict())
    }
    
    func deleteToolFromFirebase() {
        // TODO: Firebase Users ONLY
        if self.activityId.isEmpty || self.viewId.isEmpty {return}
        reference.removeValue()
    }
    
    func body(content: Content) -> some View {
            content
                .frame(width: lifeWidth * 2, height: lifeHeight * 2)
                .rotationEffect(.degrees(lifeRotation))
                .border(popUpIsVisible ? lifeBorderColor : Color.clear, width: 10) // Border modifier
                .position(x: position.x + (isDragging ? dragOffset.width : 0) + (self.lifeWidth),
                          y: position.y + (isDragging ? dragOffset.height : 0) + (self.lifeHeight))
                .gesture(self.lifeIsLocked ? nil :
                    LongPressGesture(minimumDuration: 0.01)
                        .onEnded { _ in
                            self.isDragging = true
                        }
                        .sequenced(before: DragGesture())
                        .updating($dragOffset, body: { (value, state, transaction) in
                            switch value {
                                case .second(true, let drag?):
                                    state = drag.translation
                                    updateRealm(isBackground: true, x: self.position.x + drag.translation.width, y: self.position.y + drag.translation.height)
                                default:
                                    break
                            }
                        })
                        .onEnded { value in
                            if case .second(true, let drag?) = value {
                                self.position = CGPoint(x: self.position.x + drag.translation.width, y: self.position.y + drag.translation.height)
                                updateRealm(isBackground: true)
                                self.isDragging = false
                            }
                        }.simultaneously(with: self.lifeIsLocked ? nil : TapGesture(count: 2)
                            .onEnded { _ in
                                print("Tapped")
                                popUpIsVisible = !popUpIsVisible
                                CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: "mv_settings", stateAction: popUpIsVisible ? "open" : "close", viewId: viewId))
                                if popUpIsVisible {
                                    CodiChannel.TOOL_ATTRIBUTES.send(value: ViewAtts(
                                        viewId: viewId,
                                        size: lifeWidth,
                                        rotation: lifeRotation,
                                        level: ToolLevels.BASIC.rawValue
                                    ))
                                }
                            }
                        )
                )
                .opacity(!isDisabledChecker() && !isDeletedChecker() ? 1 : 0.0)
                .onAppear {
                    reference = reference
                        .child(self.activityId)
                        .child(self.viewId)
                    isDisabled = false
                    
                    observeView()
                    
                    loadFromRealm()
                    
                    CodiChannel.SESSION_ON_ID_CHANGE.receive(on: RunLoop.main) { sc in
                        let temp = sc as! SessionChange
                        if self.activityId == temp.activityId {
                            isDisabled = false
                        } else {
                            isDisabled = true
                        }
                    }.store(in: &cancellables)
                    
                    CodiChannel.TOOL_ON_DELETE.receive(on: RunLoop.main) { viewId in
                        if self.viewId == (viewId as! String) {
                            isDeleted = true
                            isDisabled = true
                        }
                    }.store(in: &cancellables)
                    
                    CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { vId in
                        let temp = vId as! WindowController
                        if temp.windowId != "mv_settings" {return}
                        if temp.stateAction == "close" {
                            popUpIsVisible = false
                        }
                    }.store(in: &cancellables)
                    
                    CodiChannel.TOOL_ATTRIBUTES.receive(on: RunLoop.main) { viewAtts in
                        let inVA = (viewAtts as! ViewAtts)
                        if viewId != inVA.viewId {
                            popUpIsVisible = false
                            return
                        }
                        if let inColor = inVA.color { lifeColor = ColorProvider.fromColor(inColor) }
                        if let inRotation = inVA.rotation { lifeRotation = inRotation }
                        lifeIsLocked = inVA.isLocked
                        if let inSize = inVA.size {
                            lifeWidth = inSize
                            lifeHeight = inSize
                        }
                        if inVA.isDeleted {
                            isDeleted = true
                            isDisabled = true
                            deleteToolFromFirebase()
                            return
                        }
                        updateRealm()
                    }.store(in: &cancellables)
                }
        }
    
    
}
