//
//  ManagedViewObject.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/5/24.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift
import FirebaseDatabase

// Curved
public func quadBezierPoint(start: CGPoint, end: CGPoint, control: CGPoint) -> CGPoint {
    let t: CGFloat = 0.5
    let x = pow(1-t, 2) * start.x + 2*(1-t)*t*control.x + pow(t, 2) * end.x
    let y = pow(1-t, 2) * start.y + 2*(1-t)*t*control.y + pow(t, 2) * end.y
    return CGPoint(x: x, y: y)
}
// Curved
public func calculateAngle(startX: CGFloat, startY: CGFloat, endX: CGFloat, endY: CGFloat) -> Double {
    let deltaX = endX - startX
    let deltaY = endY - startY
    let angle = atan2(deltaY, deltaX) * 180 / .pi
    return Double(angle) + 90
}
// Line
public func rotationAngleOfLine(from startPoint: CGPoint, to endPoint: CGPoint) -> Angle {
    let deltaY = endPoint.y - startPoint.y
    let deltaX = endPoint.x - startPoint.x

    let angleInRadians = atan2(deltaY, deltaX)
    return Angle(radians: Double(angleInRadians))
}
// Line
public func getCenterOfLine(start: CGPoint, end: CGPoint) -> CGPoint {
    let midX = (start.x + end.x) / 2
    let midY = (start.y + end.y) / 2
    return CGPoint(x: midX, y: midY)
}
// Line
public func getWidthAndHeightOfLine(start: CGPoint, end: CGPoint) -> (width: CGFloat, height: CGFloat) {
    let width = abs(end.x - start.x)
    let height = abs(end.y - start.y)
    return (width, height)
}
// Line
public func boundingRect(start: CGPoint, end: CGPoint) -> CGRect {
    let minX = min(start.x, end.x)
    let minY = min(start.y, end.y)
    let width = abs(end.x - start.x)
    let height = abs(end.y - start.y)
    return CGRect(x: minX, y: minY, width: width, height: height)
}

public class ManagedViewObject: ObservableObject {
    
    public init() {}
    @Published public var isNew: Bool = false
    
    @Published public var lifeViewId: String = ""
    @Published public var lifeActivityId: String = ""
    @Published public var lifeToolType = "LINE"
    @Published public var lifeSubToolType = "Curved"
    
    @AppStorage("isLoggedIn") public var isLoggedIn: Bool = false
    @AppStorage("currentUserId") public var currentUserId: String = ""
    @AppStorage("isPlayingAnimation") public var isPlayingAnimation: Bool = false
    @AppStorage("toolBarCurrentViewId") public var toolBarCurrentViewId: String = ""
    @AppStorage("toolSettingsIsShowing") public var toolSettingsIsShowing: Bool = false
    @AppStorage("ignoreUpdates") public var ignoreUpdates: Bool = false
    @AppStorage("selectedManagedViewId") public var selectedManagedViewId: String = ""
    
    @Published public var showDeleteAlert = false
    @Published public var isDisabled = false
    @Published public var isDeleted = false
    @Published public var lifeIsLocked = false
    @Published public var lifeDateUpdated = Int(Date().timeIntervalSince1970)
    @Published public var lifeLastUserId = ""
    
    @Published public var lifeHeadIsEnabled = true
    @Published public var lifeCenterPoint = CGPoint.zero
    @Published public var lifeX: CGFloat = 0.0
    @Published public var lifeY: CGFloat = 0.0
    @Published public var lifeStartX: CGFloat = 100.0
    @Published public var lifeStartY: CGFloat = 100.0
    @Published public var lifeCenterX: CGFloat = 200.0
    @Published public var lifeCenterY: CGFloat = 200.0
    @Published public var lifeEndX: CGFloat = 300.0
    @Published public var lifeEndY: CGFloat = 300.0
    
    @Published public var lifeLineLength = 0.0
    @Published public var lifeWidthTouch = 300.0
    @Published public var lifeHeightTouch = 300.0
    
    @Published public var lifeToolSize: Double = 500.0
    @Published public var lifeWidth: Double = 10.0
    @Published public var lifeHeight = 75.0
    @Published public var lifeColor = Color.red
    
    @Published public var lifeColorRed = 0.0
    @Published public var lifeColorGreen = 0.0
    @Published public var lifeColorBlue = 0.0
    @Published public var lifeColorAlpha = 1.0
    @Published public var lifeLineDash = 0.0
    @Published public var lifeRotation: Angle = Angle.zero
    
    @Published public var lifeBorderColor = Color.blue
    
    @Published public var popUpIsVisible = false
    @Published public var anchorsAreVisible = false
    
    @Published public var offset = CGSize.zero
    @Published public var position = CGPoint(x: 0, y: 0)
    @Published public var isDragging = false
    @Published public var useOriginal = true
    @Published public var originalPosition = CGPoint(x: 0, y: 0)
    @Published public var originalLifeStart = CGPoint.zero
    @Published public var originalLifeCenter = CGPoint.zero
    @Published public var originalLifeEnd = CGPoint.zero
    
    public let realmInstance: Realm = newRealm()
    @Published public var objectNotificationToken: NotificationToken? = nil
    @Published public var managedViewNotificationToken: NotificationToken? = nil
    @Published public var cancellables = Set<AnyCancellable>()
    @Published public var cancel = Set<AnyCancellable>()
    
    @Published public var coordinateStackBasic: [CGPoint] = []
    @Published public var coordinateStack: [[String:CGPoint]] = []
    
    // Firebase
    @Published public var reference: DatabaseReference = Database
        .database()
        .reference()
        .child(DatabasePaths.managedViews.rawValue)
    @Published public var observerHandle: DatabaseHandle?
    @Published public var isObserving = false
    @Published public var isWriting: Bool = false
    @Published public var nofityToken: NotificationToken? = nil
    @Published public var firebaseNotificationToken: NotificationToken? = nil
    
    @Published public var hasBeenRetried = false
    @Published public var toolType: ViewEngine.Tool.ShapeTool = .line_straight
    
    @MainActor
    public func initializeWithViewId(viewId: String, activityId: String="", toolType: ViewEngine.Tool.ShapeTool = .line_straight) {
        main {
            self.lifeViewId = viewId
            self.lifeActivityId = activityId
            self.toolType = toolType
            self.loadFromRealm()
            self.observeFromRealm()
            self.receiveOnSessionChange()
            // Firebase
            self.startFirebaseObserver()
        }
    }
    
    @MainActor
    public func receiveOnSessionChange() {
        CodiChannel.SESSION_ON_ID_CHANGE.receive(on: RunLoop.main) { sc in
            // Payload is a String activityId or an ActivityChange wrapper.
            let temp: String
            if let s = sc as? String {
                temp = s
            } else if let ac = sc as? ActivityChange, let aId = ac.activityId {
                temp = aId
            } else {
                return
            }
            if self.lifeActivityId == temp {
                self.isDisabled = false
            } else {
                self.isDisabled = true
            }
        }.store(in: &cancellables)
    }
    
    /// Idempotent single-tap select (TASK-021): always writes the selection, no
    /// toggle. Used by the redesign so a single tap selects a tool and opens
    /// Properties (vs the legacy double-tap toggle in `toggleMenuWindow`).
    public func selectTool() {
        self.anchorsAreVisible = true
        self.toolBarCurrentViewId = self.lifeViewId
        self.selectedManagedViewId = self.lifeViewId
        self.toolSettingsIsShowing = true
        BroadcastTools.send(.NavStackMessage, value: NavStackMessage(viewName: "mvSettings", viewAction: WindowAction.open))
    }

    public func toggleMenuWindow() {
        if anchorsAreVisible {
            self.toolBarCurrentViewId = self.lifeViewId
            self.toolSettingsIsShowing = true
            self.selectedManagedViewId = self.lifeViewId
            BroadcastTools.send(.NavStackMessage, value: NavStackMessage(viewName: "mvSettings", viewAction: WindowAction.open))
        } else {
            self.toolSettingsIsShowing = false
            self.selectedManagedViewId = ""
            BroadcastTools.send(.NavStackMessage, value: NavStackMessage(viewName: "mvSettings", viewAction: WindowAction.close))
        }
    }
    
    @MainActor
    func listenForSettings() {
        BroadcastTools.listenForWindowCalls(storeIn: &cancel, onEvent: { id, action in
            print("ID!!!!! \(id)")
            if id != "mvsettings" { return }
            if action == WindowAction.open {
                if self.anchorsAreVisible {
                    self.anchorsAreVisible = false
                    self.popUpIsVisible = false
                }
            }
            else if action == WindowAction.close {
                if self.anchorsAreVisible {
                    self.anchorsAreVisible = false
                    self.popUpIsVisible = false
                }
            }
            else if action == WindowAction.toggle {
                return
            }
        })
    }
    
    public func deleteTool() {
        isDeleted = true
        isDisabled = true
        updateRealm()
    }
    
    // Functions
    public func isDisabledChecker() -> Bool { return isDisabled }
    public func isDeletedChecker() -> Bool { return isDeleted }
    
    // Line/Curved
    public var lineLength: CGFloat {
        sqrt(pow(lifeEndX - lifeStartX, 2) + pow(lifeEndY - lifeStartY, 2))-100
    }
    
    // Curved
    public func calculateAngleAtEndPointOfQuadCurve() -> Double {
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
    
    public func loadRotationOfLine() {
        let lineStart = CGPoint(x: lifeStartX, y: lifeStartY)
        let lineEnd = CGPoint(x: lifeEndX, y: lifeEndY)
        lifeRotation = rotationAngleOfLine(from: lineStart, to: lineEnd)
        print(lifeRotation)
    }
    
    public func loadWidthAndHeight() {
        let lineStart = CGPoint(x: lifeStartX, y: lifeStartY)
        let lineEnd = CGPoint(x: lifeEndX, y: lifeEndY)
        let (lineWidth, lineHeight) = getWidthAndHeightOfLine(start: lineStart, end: lineEnd)
        lifeWidthTouch = Double(lineWidth).bound(to: 100...200)
        lifeHeightTouch = Double(lineHeight).bound(to: 100...200)
    }
    
    public func loadControlAnchor() {
        let t: CGFloat = 0.5
        lifeCenterX = (pow(1-t, 2) * lifeStartX + 2*(1-t)*t*lifeCenterX + pow(t, 2) * lifeEndX)
        lifeCenterY = (pow(1-t, 2) * lifeStartY + 2*(1-t)*t*lifeCenterY + pow(t, 2) * lifeEndY)
    }
    
    public func loadCenterPoint() {
        let lineStart = CGPoint(x: lifeStartX, y: lifeStartY)
        let lineEnd = CGPoint(x: lifeEndX, y: lifeEndY)
        lifeCenterPoint = getCenterOfLine(start: lineStart, end: lineEnd)
    }

    public func lengthOfLine(start: CGPoint, end: CGPoint) -> CGFloat {
        let deltaX = end.x - start.x
        let deltaY = end.y - start.y
        return sqrt(deltaX * deltaX + deltaY * deltaY)
    }
    
    public func boundedLength(start: CGPoint, end: CGPoint) -> CGFloat {
        let length = lengthOfLine(start: start, end: end)
        return length.bounded(byMin: 1.0, andMax: length - 400.0)
    }
    
    public func calculateAngle(startX: CGFloat, startY: CGFloat, endX: CGFloat, endY: CGFloat) -> Double {
        let deltaX = endX - startX
        let deltaY = endY - startY
        let angle = atan2(deltaY, deltaX) * 180 / .pi
        return Double(angle) + 90
    }
    
    public func minSizeCheck() {
        if lifeWidth < 50 { lifeWidth = 100 }
        if lifeHeight < 50 { lifeHeight = 100 }
    }
    
    //
    public func animateToNextCoordinateBasic() {
        guard !coordinateStackBasic.isEmpty else { return }
        if isDragging {
            coordinateStackBasic.removeAll()
            return
        }
        let nextCoordinate = coordinateStackBasic.removeFirst()
        mainAnimation { self.position = nextCoordinate }
        // Schedule the next animation after a delay
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if !self.coordinateStackBasic.isEmpty {
                self.animateToNextCoordinateBasic()
            }
        }
    }
    
    public func animateToNextCoordinate() {
        print("!!!COORDINATES COUNT: \(coordinateStack.count)")
        
        guard !coordinateStack.isEmpty || self.isDragging else {
            return
        }
        
        let nextCoordinate = coordinateStack.removeFirst()
        mainAnimation {
            self.position = nextCoordinate["position"] ?? self.position
            self.lifeX = nextCoordinate["position"]?.x ?? self.lifeX
            self.lifeY = nextCoordinate["position"]?.y ?? self.lifeY
            self.lifeStartX = nextCoordinate["start"]?.x ?? self.lifeStartX
            self.lifeStartY = nextCoordinate["start"]?.y ?? self.lifeStartY
            self.lifeEndX = nextCoordinate["end"]?.x ?? self.lifeEndX
            self.lifeEndY = nextCoordinate["end"]?.y ?? self.lifeEndY
            self.lifeCenterPoint = nextCoordinate["center"] ?? self.lifeCenterPoint
            self.lifeCenterX = self.lifeCenterPoint.x
            self.lifeCenterY = self.lifeCenterPoint.y
            if self.lifeToolType == "shape" {
                self.loadWidthAndHeight()
                self.loadRotationOfLine()
            }
            
        }

        // Schedule the next animation after a delay
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if !self.coordinateStack.isEmpty {
                self.animateToNextCoordinate()
            }
        }
    }
    
    //
    public func loadFromRealm() {
        if isDisabledChecker() {return}
        if let umv = self.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: self.lifeViewId) {
            // set attributes
            print("Pos: \(umv.x), \(umv.y).")
            self.lifeActivityId = umv.boardId
            self.lifeToolType = umv.toolType
            
            self.lifeIsLocked = umv.isLocked
            self.lifeLastUserId = umv.lastUserId
            self.isDeleted = umv.isDeleted
            
            self.lifeWidth = Double(umv.width)
            self.lifeHeight = Double(umv.height)
            self.lifeRotation = Angle(degrees: umv.rotation)
            
            // Tools created from the palette carry a spawn x/y but no shape
            // geometry — anchor the per-shape defaults at the spawn point.
            let geometryIsUnset = umv.startX == 0.0 && umv.startY == 0.0
                && umv.centerX == 0.0 && umv.centerY == 0.0
                && umv.endX == 0.0 && umv.endY == 0.0
            if geometryIsUnset {
                let ax = umv.x
                let ay = umv.y
                self.position = CGPoint(x: ax, y: ay)
                self.lifeX = ax
                self.lifeY = ay
                switch self.toolType {
                    case .line_straight, .line_dotted, .line_curved:
                        self.lifeStartX = ax
                        self.lifeStartY = ay
                        self.lifeCenterX = ax + 250.0
                        self.lifeCenterY = ay
                        self.lifeEndX = ax + 500.0
                        self.lifeEndY = ay
                    case .square:
                        self.lifeCenterX = ax + 500.0
                        self.lifeCenterY = ay - 500.0
                        self.lifeStartX = ax + 500.0
                        self.lifeStartY = ay
                        self.lifeEndX = ax
                        self.lifeEndY = ay - 500.0
                    case .triangle:
                        self.lifeX = ax + 250.0
                        self.lifeStartX = ax + 500.0
                        self.lifeStartY = ay - 500.0
                        self.lifeCenterX = ax
                        self.lifeCenterY = ay - 500.0
                    case .circle:
                        self.lifeToolSize = 1000.0
                        self.lifeWidth = 200.0
                }
            } else {
                self.position = CGPoint(x: umv.x, y: umv.y)
                self.lifeX = umv.x
                self.lifeY = umv.y
                self.lifeStartX = umv.startX
                self.lifeStartY = umv.startY
                self.lifeCenterX = umv.centerX
                self.lifeCenterY = umv.centerY
                self.lifeEndX = umv.endX
                self.lifeEndY = umv.endY
            }
        
            self.lifeLineDash = Double(umv.lineDash)
            self.lifeHeadIsEnabled = umv.headIsEnabled
            
            self.lifeColorRed = umv.colorRed
            self.lifeColorGreen = umv.colorGreen
            self.lifeColorBlue = umv.colorBlue
            self.lifeColorAlpha = umv.colorAlpha
            self.lifeColor = colorFromRGBA(red: self.lifeColorRed, green: self.lifeColorGreen, blue: self.lifeColorBlue, alpha: self.lifeColorAlpha)
            
            // Handle?
            if self.lifeToolType == "shape" {
                self.loadCenterPoint()
                self.loadWidthAndHeight()
                self.loadRotationOfLine()
            }
//            // -> Handle?
//            if self.lifeToolType == "general" || self.lifeToolType == "soccer" {
//                self.minSizeCheck()
//            }
            self.isNew = false
        } else {
            if self.hasBeenRetried { return }
            self.hasBeenRetried = true
            self.isNew = true
            ManagedViewEngine.createNewTool(viewId: lifeViewId, activityId: lifeActivityId, toolType: lifeToolType, subToolType: lifeToolType, sport: "")
            delayThenMain(1, mainBlock: { self.loadFromRealm() })
        }
    }
    
    //
    public func observeFromRealm() {
        if isDisabledChecker() {return}
        
        self.observeRealmManagedView() { temp in
            DispatchQueue.main.async {
                self.isDisabled = false
                if self.isDragging {return}
                
                if self.isPlayingAnimation {
                    withAnimation {
                        self.position = CGPoint(x: temp.x, y: temp.y)
                    }
                } else {
                    
                    if temp.lastUserId != self.currentUserId {
                        
                        if temp.startX == 0.0 && temp.startY == 0.0 { return }
                        if temp.endX == 0.0 && temp.endY == 0.0 { return }
                        
                        let newPosition = CGPoint(x: temp.x, y: temp.y)
                        let startPosition = CGPoint(x: temp.startX, y: temp.startY)
                        let endPosition = CGPoint(x: temp.endX, y: temp.endY)
                        var centerPosition: CGPoint
                        if self.lifeToolType == "shape" && self.lifeSubToolType == "line_curved" {
                             centerPosition = CGPoint(x: temp.centerX, y: temp.centerY)
                        } else {
                            centerPosition = getCenterOfLine(start: startPosition, end: endPosition)
                        }
                        
                        let coords = [
                            "position": newPosition,
                            "start":startPosition,
                            "end":endPosition,
                            "center":centerPosition
                        ]
                        
                        self.coordinateStack.append(coords)
                        self.animateToNextCoordinate()
                    }
                }
                
                if self.lifeActivityId != temp.boardId { self.lifeActivityId = temp.boardId }
                if self.lifeToolType != temp.toolType { self.lifeToolType = temp.toolType }
                
                // Adding withAnimation here just doesn't flow right. Didn't like it.
                if self.lifeToolSize != Double(temp.toolSize) { self.lifeToolSize = Double(temp.toolSize) ?? 500.0 }
                if self.lifeWidth != Double(temp.width) { self.lifeWidth = Double(temp.width) }
                if self.lifeHeight != Double(temp.height) { self.lifeHeight = Double(temp.height) }
                
                if self.lifeRotation != Angle(degrees: temp.rotation) { self.lifeRotation = Angle(degrees: temp.rotation) }
                
                withAnimation {
                    var colorHasChanged = false
                    if self.lifeColorRed != temp.colorRed { colorHasChanged = true; self.lifeColorRed = temp.colorRed}
                    if self.lifeColorGreen != temp.colorGreen { colorHasChanged = true; self.lifeColorGreen = temp.colorGreen}
                    if self.lifeColorBlue != temp.colorBlue { colorHasChanged = true; self.lifeColorBlue = temp.colorBlue }
                    if self.lifeColorAlpha != temp.colorAlpha { colorHasChanged = true; self.lifeColorAlpha = temp.colorAlpha }
                    if colorHasChanged {
                        self.lifeColor = colorFromRGBA(red: self.lifeColorRed, green: self.lifeColorGreen, blue: self.lifeColorBlue, alpha: self.lifeColorAlpha)
                    }
                }
                
                if self.lifeLineDash != Double(temp.lineDash) { self.lifeLineDash = Double(temp.lineDash) }
                self.lifeHeadIsEnabled = temp.headIsEnabled
                if self.lifeIsLocked != temp.isLocked { self.lifeIsLocked = temp.isLocked }
                self.lifeLastUserId = temp.lastUserId
                self.isDeleted = temp.isDeleted
//                self.minSizeCheck()
            }
        }
        
    }
    
    // Update
    public func updateRealm(start: CGPoint? = nil, end: CGPoint? = nil, x:Double?=nil, y:Double?=nil) {
        if self.isDisabledChecker() {return}
        if self.isDeletedChecker() {return}
        if let mv = self.realmInstance.findByField(ManagedView.self, value: self.lifeViewId) {
            self.realmInstance.safeWrite { r in
                
                // Modify the object
                mv.x = x ?? self.lifeX
                mv.y = y ?? self.lifeY
                
                mv.startX = Double(start?.x ?? CGFloat(self.lifeStartX))
                mv.startY = Double(start?.y ?? CGFloat(self.lifeStartY))
                // Center is its own point — never derive it from `start` (TASK-024).
                mv.centerX = Double(self.lifeCenterX)
                mv.centerY = Double(self.lifeCenterY)
                mv.endX = Double(end?.x ?? CGFloat(self.lifeEndX))
                mv.endY = Double(end?.y ?? CGFloat(self.lifeEndY))
                
                if let lc = self.lifeColor.toRGBA() {
                    mv.colorRed = lc.red
                    mv.colorGreen = lc.green
                    mv.colorBlue = lc.blue
                    mv.colorAlpha = lc.alpha
                }
                mv.isLocked = self.isDragging ? true : self.lifeIsLocked
                mv.isDeleted = self.isDeleted
                mv.toolType = self.lifeToolType
                mv.toolSize = String(self.lifeToolSize)
                mv.width = Int(self.lifeWidth)
                mv.height = Int(self.lifeHeight)
                mv.rotation = self.lifeRotation.degrees
                mv.lineDash = Int(self.lifeLineDash)
                mv.lastUserId = self.currentUserId
                mv.headIsEnabled = self.lifeHeadIsEnabled
//                self.updateFirebase(mv: mv)
//                self.saveSnapshotToHistoryInRealm()
                r.refresh()
                print("Updated Realm -> \(mv.x), \(mv.y)")
            }
        }
        
    }
    public func updateRealmPosition() {
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    if let mv = realm.findByField(ManagedView.self, value: self.lifeViewId) {
                        try realm.write {
                            mv.x = self.position.x
                            mv.y = self.position.y
                            mv.lastUserId = self.currentUserId
                            realm.refresh()
                            print("Updated Realm with new POS! 2 -> \(mv.x), \(mv.y)")
                        }
//                        self.updateFirebase(mv: mv)
                    }
                } catch {
                    print("Realm error: \(error)")
                }
            }
        }
    }
    public func updateRealmPos(start: CGPoint? = nil, end: CGPoint? = nil) {
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    if let mv = realm.findByField(ManagedView.self, value: self.lifeViewId) {
                        try realm.write {
                            mv.x = Double(start?.x ?? CGFloat(self.lifeX))
                            mv.y = Double(start?.y ?? CGFloat(self.lifeY))
                            mv.startX = Double(start?.x ?? CGFloat(self.lifeStartX))
                            mv.startY = Double(start?.y ?? CGFloat(self.lifeStartY))
                            mv.centerX = Double(start?.x ?? CGFloat(self.lifeCenterX))
                            mv.centerY = Double(start?.y ?? CGFloat(self.lifeCenterY))
                            mv.endX = Double(end?.x ?? CGFloat(self.lifeEndX))
                            mv.endY = Double(end?.y ?? CGFloat(self.lifeEndY))
                            mv.lastUserId = self.currentUserId
                            realm.refresh()
                            print("Updated Realm with new POS! 2 -> \(mv.x), \(mv.y)")
                        }
//                        self.updateFirebase(mv: mv)
                    }
                } catch {
                    print("Realm error: \(error)")
                }
            }
        }
    }
    // Firebase
    public func shouldDenyFirebaseWriteRequest() -> Bool {
        if self.isWriting {
            print("Denying MVS Request: Writing")
            return true
        }
        if !self.isLoggedIn {
            print("Denying MVS Request: Login")
            return true
        }
        print("Allowing MVS Request")
        return false
    }
    
    public func startFirebaseObserver() {
        
        if isObserving || self.lifeActivityId.isEmpty || self.lifeViewId.isEmpty {return}
//        if !self.realmInstance.isLiveSessionPlan(activityId: self.lifeActivityId) { return }
        
        observerHandle = reference.child(self.lifeActivityId).child(self.lifeViewId).observe(.value, with: { snapshot in
            let _ = snapshot.toCoreObjects(ManagedView.self, realm: self.realmInstance)
        })
        reference.child(self.lifeActivityId).child(self.lifeViewId).observe(.childRemoved, with: { snapshot in
           if let mv = self.realmInstance.findByField(ManagedView.self, value: self.lifeViewId) {
               if self.isDeleted {return}
               main {self.isDeleted = true}
               self.realmInstance.safeWrite { r in
                   mv.isDeleted = true
               }
           }
       })
        main {self.isObserving = true}
    }
    
    public func observeRealmManagedView(onDeleted: @escaping () -> Void={}, onChange: @escaping (ManagedView) -> Void) {
        if let mv = self.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: self.lifeViewId) {
            self.realmInstance.executeWithRetry {
                self.managedViewNotificationToken = mv.observe { change in
                    main {
                        switch change {
                            case .change(let obj, _):
                                if let temp = obj as? ManagedView {
                                    if temp.id == self.lifeViewId { onChange(temp) }
                                }
                            case .error(let error):
                                print("Error: \(error)")
                                self.managedViewNotificationToken?.invalidate()
                                self.managedViewNotificationToken = nil
                            case .deleted:
                                print("Object has been deleted.")
                                self.managedViewNotificationToken?.invalidate()
                                self.managedViewNotificationToken = nil
                                onDeleted()
                        }
                    }
                }
            }
            
        }

    }
    
    public func updateFirebase(mv: ManagedView?) {
        guard let mv = mv else { return }
        if mv.boardId == "SOL" { return }
        if shouldDenyFirebaseWriteRequest() { return }
        main {self.isWriting = true}
        if mv.boardId.isEmpty || mv.id.isEmpty { return }
        reference.child(mv.id).setValue(mv.toDict()) { (error: Error?, ref: DatabaseReference) in
            main {self.isWriting = false}
            if let error = error { print("Error updating Firebase: \(error)") }
        }
    }
    
    
    
}
