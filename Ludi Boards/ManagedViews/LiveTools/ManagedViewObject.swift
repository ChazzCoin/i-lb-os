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
import CoreEngine

class ManagedViewObject: ObservableObject {
    
    @StateObject var MVS: SingleManagedViewService = SingleManagedViewService()
    
    @Published public var lifeViewId: String = ""
    @Published public var lifeActivityId: String = ""
    @Published public var lifeToolType = "LINE"
    @Published public var lifeSubToolType = "Curved"
    
    @AppStorage("currentUserId") public var currentUserId: String = ""
    @AppStorage("isPlayingAnimation") public var isPlayingAnimation: Bool = false
    @AppStorage("toolBarCurrentViewId") public var toolBarCurrentViewId: String = ""
    @AppStorage("toolSettingsIsShowing") public var toolSettingsIsShowing: Bool = false
    @AppStorage("ignoreUpdates") public var ignoreUpdates: Bool = false
    
    @Published public var isDisabled = false
//    @Published public var isDeleted = false -> Managed by MVS (managed view service)
    @Published public var lifeIsLocked = false
    @Published public var lifeDateUpdated = Int(Date().timeIntervalSince1970)
    @Published public var lifeLastUserId = ""
    
    @Published public var lifeHeadIsEnabled = true
    @Published public var lifeCenterPoint = CGPoint.zero
    @Published public var lifeStartX: CGFloat = 0.0
    @Published public var lifeStartY: CGFloat = 0.0
    @Published public var lifeEndX: CGFloat = 0.0
    @Published public var lifeEndY: CGFloat = 0.0
    
    @Published public var lifeLineLength = 0.0
    @Published public var lifeWidthTouch = 300.0
    @Published public var lifeHeightTouch = 300.0
    
    @Published public var lifeWidth: Double = 10.0
    @Published public var lifeHeight = 75.0
    @Published public var lifeColor = Color.red
    
    @Published public var lifeColorRed = 0.0
    @Published public var lifeColorGreen = 0.0
    @Published public var lifeColorBlue = 0.0
    @Published public var lifeColorAlpha = 1.0
    @Published public var lifeLineDash = 0.0
    @Published public var lifeRotation: Angle = Angle.zero
    
    @Published public var lifeBorderColor = Color.AIMYellow
    
    @Published public var popUpIsVisible = false
    @Published public var anchorsAreVisible = false
    
    @Published public var offset = CGSize.zero
    @Published public var position = CGPoint(x: 0, y: 0)
    @GestureState public var dragOffset = CGSize.zero
    @Published public var isDragging = false
    @Published public var useOriginal = true
    @Published public var originalLifeStart = CGPoint.zero
    @Published public var originalLifeEnd = CGPoint.zero
    
    public let realmInstance: Realm = newRealm()
    @Published public var objectNotificationToken: NotificationToken? = nil
    @Published public var managedViewNotificationToken: NotificationToken? = nil
    @Published public var cancellables = Set<AnyCancellable>()
    
    @Published public var coordinateStackBasic: [CGPoint] = []
    @Published public var coordinateStack: [[String:CGPoint]] = []
    
    @MainActor
    func initializeWithViewId(viewId: String) {
        main {
            self.lifeViewId = viewId
            self.loadFromRealm(viewId: viewId)
            self.MVS.initialize(realm: self.realmInstance, activityId: self.lifeActivityId, viewId: viewId)
            self.observeFromRealm()
            self.MVS.startFirebaseObserver()
            self.receiveOnSessionChange()
        }
    }
    
    @MainActor
    func receiveOnSessionChange() {
        CodiChannel.SESSION_ON_ID_CHANGE.receive(on: RunLoop.main) { sc in
            let temp = sc as! ActivityChange
            if self.lifeActivityId == temp.activityId {
                self.isDisabled = false
            } else {
                self.isDisabled = true
            }
        }.store(in: &cancellables)
    }
    
    func toggleMenuWindow() {
        if popUpIsVisible {
            self.toolBarCurrentViewId = self.lifeViewId
            self.toolSettingsIsShowing = true
        } else {
            self.toolSettingsIsShowing = false
        }
    }
    
    // Functions
    func isDisabledChecker() -> Bool { return isDisabled }
    
    private var lineLength: CGFloat {
        sqrt(pow(lifeEndX - lifeStartX, 2) + pow(lifeEndY - lifeStartY, 2))-100
    }
    
    func loadRotationOfLine() {
        let lineStart = CGPoint(x: lifeStartX, y: lifeStartY)
        let lineEnd = CGPoint(x: lifeEndX, y: lifeEndY)
        let temp = rotationAngleOfLine(from: lineStart, to: lineEnd)
        if temp.radians == 0.0 { return }
        lifeRotation = temp
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
    
    func minSizeCheck() {
        if lifeWidth < 50 { lifeWidth = 100 }
        if lifeHeight < 50 { lifeHeight = 100 }
    }
    
    //
    func animateToNextCoordinateBasic() {
        guard !coordinateStackBasic.isEmpty else { return }
        if isDragging {
            coordinateStackBasic.removeAll()
            return
        }
        let nextCoordinate = coordinateStackBasic.removeFirst()
        withAnimation { position = nextCoordinate }
        // Schedule the next animation after a delay
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if !self.coordinateStackBasic.isEmpty {
                self.animateToNextCoordinateBasic()
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
            position = nextCoordinate["position"] ?? position
            lifeStartX = nextCoordinate["start"]?.x ?? lifeStartX
            lifeStartY = nextCoordinate["start"]?.y ?? lifeStartY
            lifeEndX = nextCoordinate["end"]?.x ?? lifeEndX
            lifeEndY = nextCoordinate["end"]?.y ?? lifeEndY
            lifeCenterPoint = nextCoordinate["center"] ?? lifeCenterPoint
            loadWidthAndHeight()
            loadRotationOfLine()
        }

        // Schedule the next animation after a delay
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if !self.coordinateStack.isEmpty {
                self.animateToNextCoordinate()
            }
        }
    }
    //
    
    func loadFromRealm(viewId: String) {
        if isDisabledChecker() {return}
//        self.viewId = viewId
        if let umv = self.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: viewId) {
            // set attributes
            print("Loading in ManagedView Tool.")
            lifeActivityId = umv.boardId
            lifeToolType = umv.toolType
            
            lifeIsLocked = umv.isLocked
            lifeLastUserId = umv.lastUserId
            
            position = CGPoint(x: umv.x, y: umv.y)
            lifeStartX = umv.startX
            lifeStartY = umv.startY
            lifeEndX = umv.endX
            lifeEndY = umv.endY
            
            lifeWidth = Double(umv.width)
            lifeHeight = Double(umv.height)
            lifeRotation = Angle(degrees: umv.rotation)
            
            lifeLineDash = Double(umv.lineDash)
            lifeHeadIsEnabled = umv.headIsEnabled
            
            lifeColorRed = umv.colorRed
            lifeColorGreen = umv.colorGreen
            lifeColorBlue = umv.colorBlue
            lifeColorAlpha = umv.colorAlpha
            lifeColor = colorFromRGBA(red: lifeColorRed, green: lifeColorGreen, blue: lifeColorBlue, alpha: lifeColorAlpha)
            
            // Handle?
            loadCenterPoint()
            loadWidthAndHeight()
            loadRotationOfLine()
            // -> Handle?
            if lifeToolType == "Basic" {
                minSizeCheck()
            }
            
        }
    }
    
    //
    func observeFromRealm() {
        if isDisabledChecker() {return}
        
        self.MVS.observeRealmManagedView() { temp in
            self.isDisabled = false
            if self.isDragging {return}
            
            DispatchQueue.main.async {
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
                        let centerPosition = getCenterOfLine(start: startPosition, end: endPosition)
                        
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
                self.MVS.isDeleted = temp.isDeleted
                self.minSizeCheck()
            }
        }
        
    }
    
    
    
    
    
    
    
}
