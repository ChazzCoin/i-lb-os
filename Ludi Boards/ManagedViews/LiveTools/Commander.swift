////
////  Commander.swift
////  Ludi Boards
////
////  Created by Charles Romeo on 1/4/24.
////
//
//import Foundation
//import SwiftUI
//import RealmSwift
//import Combine
//
//protocol Command {
//    func execute()
//    func undo()
//}
//
//class CommandController: ObservableObject {
//    // External services
//    var realmInstance: Realm
//    
//
//    init() {
//        realmInstance = realm() // Assuming realm() returns a Realm instance
//        
//    }
//    
//    @Published var coordinateStack: [CGPoint] = []
//    @Published var popUpIsVisible = false
//    @Published var currentUserId: String = getFirebaseUserIdOrCurrentLocalId()
//    
//    @Published var activityId: String = ""
//    @Published var viewId: String = ""
//    @Published var isDisabled = false
//    @Published var lifeIsLocked = false
//    @Published var lifeLastUserId = ""
//    @Published var lifeUpdatedAt: Int = 0 // Using Double for time representation
//    @Published var lifeBorderColor = Color.AIMYellow
//    @Published var lifeColor = ColorProvider.black // SwiftUI color representation
//    @Published var lifeWidth = 75.0 // CGFloat in SwiftUI
//    @Published var lifeHeight = 75.0 // CGFloat in SwiftUI
//    @Published var lifeScale = 1.0 // CGFloat for scale
//    @Published var lifeRotation = 0.0 // Angle in degrees, represented by Double in SwiftUI
//    @Published var lifeToolType = SoccerToolProvider.playerDummy.tool.image // Assuming 'toolType' is an enum or similar
//    @Published var toolType = "Basic"
//    @Published var lifeColorRed = 0.0
//    @Published var lifeColorGreen = 0.0
//    @Published var lifeColorBlue = 0.0
//    @Published var lifeColorAlpha = 1.0
//    
//    @Published var position = CGPoint(x: 100, y: 100)
//    @Published var isDragging = false
//    //
//    @Published var cancellables = Set<AnyCancellable>()
//    @Published var managedViewNotificationToken: NotificationToken? = nil
//    
//    //
//    let menuWindowId = "mv_settings"
//
//    //
//    func isDisabledChecker() -> Bool { return isDisabled }
//    func isDeletedChecker() -> Bool { return self.MVS.isDeleted }
//    
//    func minSizeCheck() {
//        if self.lifeWidth < 50 {
//            self.lifeWidth = 100
//        }
//        if self.lifeHeight < 50 {
//            self.lifeHeight = 100
//        }
//    }
//    
//    func initialize(viewId:String, activityId:String) {
//        self.viewId = viewId
//        self.activityId = activityId
//        // Setup
//        DispatchQueue.main.async {
//            safeFirebaseUserId() { userId in
//                self.currentUserId = userId
//            }
//            self.MVS.initialize(realm: self.realmInstance, activityId: self.activityId, viewId: self.viewId)
//            self.observeFromRealm()
//            self.MVS.startFirebaseObserver()
//        }
//        // Load View State
//        loadFromRealm()
//    }
//    
//    @MainActor
//    func initChannels() {
//        receiveOnSessionChange()
//        recieveMenuWindowController()
//        receiveToolAttributes()
//    }
//    
//    @MainActor
//    func receiveOnSessionChange() {
//        CodiChannel.SESSION_ON_ID_CHANGE.receive(on: RunLoop.main) { sc in
//            let temp = sc as! SessionChange
//            if self.activityId == temp.activityId {
//                self.isDisabled = false
//            } else {
//                self.isDisabled = true
//            }
//        }.store(in: &cancellables)
//    }
//    func toggleMenuWindow() {
//        CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: self.menuWindowId, stateAction: self.popUpIsVisible ? "open" : "close", viewId: self.viewId, x: self.position.x, y: self.position.y))
//    }
//    
//    @MainActor
//    func recieveMenuWindowController() {
//        CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { vId in
//            let temp = vId as! WindowController
//            if temp.windowId != self.menuWindowId {return}
//            if temp.stateAction == "close" {
//                self.popUpIsVisible = false
//            }
//        }.store(in: &cancellables)
//    }
//    
//    @MainActor
//    func receiveToolAttributes() {
//        CodiChannel.TOOL_ATTRIBUTES.receive(on: RunLoop.main) { viewAtts in
//            let inVA = (viewAtts as! ViewAtts)
//            if self.viewId != inVA.viewId {
//                self.popUpIsVisible = false
//                return
//            }
//            if inVA.isDeleted { return }
//            if let inColor = inVA.color { self.lifeColor = ColorProvider.fromColor(inColor) }
//            if let inRotation = inVA.rotation { self.lifeRotation = inRotation }
//            if let isL = inVA.isLocked { self.lifeIsLocked = isL }
//            if let inSize = inVA.size {
//                self.lifeWidth = inSize
//                self.lifeHeight = inSize
//            }
//            self.updateRealm()
//        }.store(in: &cancellables)
//    }
//    
//    @MainActor
//    func sendToolAttributes() {
//        CodiChannel.TOOL_ATTRIBUTES.send(value: ViewAtts(
//            viewId: self.viewId,
//            size: self.lifeWidth,
//            rotation: self.lifeRotation,
//            position: self.position,
//            toolType: self.toolType,
//            isLocked: self.lifeIsLocked
//        ))
//    }
//    
//    func sendXY(width:CGFloat, height:CGFloat) {
//        CodiChannel.TOOL_ON_FOLLOW.send(value: ViewFollowing(
//            viewId: self.viewId,
//            x: self.position.x + width,
//            y: self.position.y + height
//        ))
//    }
//    
//    // Realm / Firebase
//    func loadFromRealm(managedView: ManagedView?=nil) {
//        if isDisabledChecker() || isDeletedChecker() {return}
//        var mv = managedView
//        if mv == nil {mv = realm().object(ofType: ManagedView.self, forPrimaryKey: self.viewId)}
//        guard let umv = mv else { return }
//        // set attributes
//        activityId = umv.boardId
//        self.position = CGPoint(x: umv.x, y: umv.y)
//        lifeWidth = Double(umv.width)
//        lifeHeight = Double(umv.height)
//        lifeRotation = umv.rotation
//        lifeToolType = umv.toolType
//        lifeColorRed = umv.colorRed
//        lifeColorGreen = umv.colorGreen
//        lifeColorBlue = umv.colorBlue
//        lifeColorAlpha = umv.colorAlpha
//        lifeIsLocked = umv.isLocked
//        lifeLastUserId = umv.lastUserId
//        minSizeCheck()
//    }
//    
//    // TODO: COPY THIS TO MVSETTINGS FOR REALTIME UPDATES.
//    // Observe From Realm
//    func observeFromRealm() {
//        if isDisabledChecker() || isDeletedChecker() {return}
//        MVS.observeRealmManagedView() { temp in
//            self.isDisabled = false
//            if self.isDragging {return}
//            
//            DispatchQueue.main.async {
//                if self.isDragging {return}
//                
//                if temp.lastUserId != self.currentUserId {
//                    let newPosition = CGPoint(x: temp.x, y: temp.y)
//                    self.coordinateStack.append(newPosition)
//                    self.animateToNextCoordinate()
//                }
//                
//                if self.activityId != temp.boardId {self.activityId = temp.boardId}
//                if self.lifeWidth != Double(temp.width) {self.lifeWidth = Double(temp.width)}
//                if self.lifeHeight != Double(temp.height) { self.lifeHeight = Double(temp.height)}
//                if self.lifeRotation != temp.rotation { self.lifeRotation = temp.rotation}
//                if self.lifeToolType != temp.toolType { self.lifeToolType = temp.toolType}
//                if self.lifeColorRed != temp.colorRed {self.lifeColorRed = temp.colorRed}
//                if self.lifeColorGreen != temp.colorGreen { self.lifeColorGreen = temp.colorGreen}
//                if self.lifeColorBlue != temp.colorBlue {self.lifeColorBlue = temp.colorBlue}
//                if self.lifeColorAlpha != temp.colorAlpha { self.lifeColorAlpha = temp.colorAlpha}
//                if self.lifeIsLocked != temp.isLocked { self.lifeIsLocked = temp.isLocked}
//                self.lifeLastUserId = temp.lastUserId
//                self.MVS.isDeleted = temp.isDeleted
//                self.minSizeCheck()
//            }
//        }
//        
//    }
//    
//    func updateRealm(x:Double?=nil, y:Double?=nil) {
//        if isDisabledChecker() || isDeletedChecker() {return}
//        DispatchQueue.global(qos: .background).async {
//            // Create a new Realm instance for the background thread
//            autoreleasepool {
//                do {
//                    let realm = try Realm()
//                    if let mv = realm.findByField(ManagedView.self, value: self.viewId) {
//                        try realm.write {
//                            // Modify the object
//                            mv.x = x ?? self.position.x
//                            mv.y = y ?? self.position.y
//                            mv.rotation = self.lifeRotation
//                            mv.toolType = self.lifeToolType
//                            mv.width = Int(self.lifeWidth)
//                            mv.height = Int(self.lifeHeight)
//                            mv.colorRed = self.lifeColorRed
//                            mv.colorGreen = self.lifeColorGreen
//                            mv.colorBlue = self.lifeColorBlue
//                            mv.colorAlpha = self.lifeColorAlpha
//                            mv.isLocked = self.lifeIsLocked
//                            mv.lastUserId = self.currentUserId
//                            // TODO: Firebase Users ONLY
//                            self.MVS.updateFirebase(mv: mv)
//                        }
//                    }
//                } catch {
//                    // Handle error
//                    print("Realm error: \(error)")
//                }
//            }
//        }
//    }
//    
//    
//    func updateRealmPos(x:Double?=nil, y:Double?=nil) {
//        DispatchQueue.global(qos: .background).async {
//            autoreleasepool {
//                do {
//                    let realm = try Realm()
//                    if let mv = realm.findByField(ManagedView.self, value: self.viewId) {
//                        try realm.write {
//                            mv.x = x ?? self.position.x
//                            mv.y = y ?? self.position.y
//                            mv.lastUserId = self.currentUserId
//                        }
//                        self.MVS.updateFirebase(mv: mv)
//                    }
//                } catch {
//                    print("Realm error: \(error)")
//                }
//            }
//        }
//    }
//    
//    // Animations
//    func animateToNextCoordinate() {
//        guard !coordinateStack.isEmpty else { return }
//        
//        if self.isDragging {
//            coordinateStack.removeAll()
//            return
//        }
//        
//        let nextCoordinate = coordinateStack.removeFirst()
//        withAnimation { self.position = nextCoordinate }
//
//        // Schedule the next animation after a delay
//        DispatchQueue.main.asyncAfter(deadline: .now()) {
//            if !self.coordinateStack.isEmpty {
//                self.animateToNextCoordinate()
//            }
//        }
//    }
//    
////    // Your other view model properties and methods
////    func moveView(id: String, to newPosition: CGPoint) {
////        let command = MoveViewCommand(id: id, newPosition: newPosition)
////        commandManager.executeCommand(command)
////    }
////
////    func changeViewColor(id: String, to newColor: Color) {
////        let command = ChangeColorCommand(id: id, newColor: newColor)
////        commandManager.executeCommand(command)
////    }
////
////    func undoLastAction() {
////        commandManager.undoLastCommand()
////    }
//}
//
//class CommandManager {
//    private var commandHistory = [Command]()
//
//    func executeCommand(_ command: Command) {
//        command.execute()
//        commandHistory.append(command)
//    }
//
//    func undoLastCommand() {
//        guard let lastCommand = commandHistory.popLast() else { return }
//        lastCommand.undo()
//    }
//}
//
//
//
//class MoveViewCommand: Command {
//    
//    private var id: String
//    private var newPosition: CGPoint
//    private var previousPosition: CGPoint = (CGPoint(x: 0.0, y: 0.0))
//
//    var realmInstance: Realm = realm()
//    
//    init(id: String, newPosition: CGPoint) {
//        self.id = id
//        self.newPosition = newPosition
//        self.previousPosition = newPosition
//    }
//
//    func execute() {
//        if let obj = realmInstance.findByField(ManagedView.self, value: self.id) {
//            realmInstance.safeWrite { r in
//                obj.x = self.newPosition.x
//                obj.y = self.newPosition.y
//            }
//        }
//    }
//
//    func undo() {
//        if let obj = realmInstance.findByField(ManagedView.self, value: self.id) {
//            realmInstance.safeWrite { r in
//                obj.x = self.previousPosition.x
//                obj.y = self.previousPosition.y
//            }
//        }
//    }
//}
//
//class ChangeColorCommand: Command {
//    private var id: String
//    private var previousColor: Color
//    private var newColor: Color
//    
//    var realmInstance: Realm = realm()
//
//    init(id: String, newColor: Color) {
//        self.id = id
////        self.previousColor = colorFromRGBA(red: view.colorRed, green: view.colorGreen, blue: view.colorBlue, alpha: view.colorAlpha)
//        self.newColor = newColor
//        self.previousColor = newColor
//    }
//
//    func execute() {
//        if let obj = realmInstance.findByField(ManagedView.self, value: self.id) {
//            realmInstance.safeWrite { r in
//                let rgb = self.newColor.toRGBA()
//                obj.colorRed = Double(rgb?.red ?? 0.0)
//                obj.colorGreen = Double(rgb?.green ?? 0.0)
//                obj.colorBlue = Double(rgb?.blue ?? 0.0)
//                obj.colorAlpha = Double(rgb?.alpha ?? 0.0)
//            }
//        }
//        
//    }
//
//    func undo() {
//        if let obj = realmInstance.findByField(ManagedView.self, value: self.id) {
//            realmInstance.safeWrite { r in
//                let rgb = self.previousColor.toRGBA()
//                obj.colorRed = Double(rgb?.red ?? 0.0)
//                obj.colorGreen = Double(rgb?.green ?? 0.0)
//                obj.colorBlue = Double(rgb?.blue ?? 0.0)
//                obj.colorAlpha = Double(rgb?.alpha ?? 0.0)
//            }
//        }
//        
//    }
//}
