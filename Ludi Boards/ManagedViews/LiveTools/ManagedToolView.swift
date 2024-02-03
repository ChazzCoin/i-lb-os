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


struct ManagedViewBoardTool: View {
    let viewId: String
    let activityId: String
    let toolType: String
    @EnvironmentObject var BEO: BoardEngineObject
    
    @State private var color: Color = .black
    @State private var rotation = 0.0
    
    @State private var position = CGPoint(x: 100, y: 100)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false

    var body: some View {
        Image(toolType)
            .resizable()
            .enableMVT(viewId: viewId, activityId: activityId)
    }
}


struct enableManagedViewTool : ViewModifier {
    
    @State var viewId: String
    @State var activityId: String
    @EnvironmentObject var BEO: BoardEngineObject
    @State var MVS: SingleManagedViewService = SingleManagedViewService()
    @GestureState var dragOffset = CGSize.zero
    let menuWindowId = "mv_settings"
    
    @State var coordinateStack: [CGPoint] = []
    @State var popUpIsVisible = false
    @State var currentUserId: String = getFirebaseUserIdOrCurrentLocalId()
    
    @State var isDisabled = false
    @State var lifeIsLocked = false
    @State var lifeLastUserId = ""
    @State var lifeUpdatedAt: Int = 0 // Using Double for time representation
    @State var lifeBorderColor = Color.AIMYellow
    @State var lifeColor = ColorProvider.black // SwiftUI color representation
    @State var lifeWidth = 75.0 // CGFloat in SwiftUI
    @State var lifeHeight = 75.0 // CGFloat in SwiftUI
    @State var lifeScale = 1.0 // CGFloat for scale
    @State var lifeRotation = 0.0 // Angle in degrees, represented by Double in SwiftUI
    @State var lifeToolType = SoccerToolProvider.playerDummy.tool.image // Assuming 'toolType' is an enum or similar
    @State var toolType = "Basic"
    @State var lifeColorRed = 0.0
    @State var lifeColorGreen = 0.0
    @State var lifeColorBlue = 0.0
    @State var lifeColorAlpha = 1.0
    
    @State var position = CGPoint(x: 100, y: 100)
    @State var isDragging = false
    //
    @State var cancellables = Set<AnyCancellable>()
    @State var managedViewNotificationToken: NotificationToken? = nil
    
    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
        }
        .zIndex(5.0)
        .frame(width: self.lifeWidth * 2, height: self.lifeHeight * 2)
        .rotationEffect(.degrees(self.lifeRotation))
        .border(self.popUpIsVisible ? self.lifeBorderColor : Color.clear, width: 10) // Border modifier
        .position(x: self.position.x + (self.isDragging ? self.dragOffset.width : 0) + (self.lifeWidth),
                  y: self.position.y + (self.isDragging ? self.dragOffset.height : 0) + (self.lifeHeight))
        .simultaneousGesture(gestureDragBasicTool())
        .opacity(!self.isDisabledChecker() && !self.isDeletedChecker() ? 1 : 0.0)
        .onChange(of: self.BEO.toolBarCurrentViewId, perform: { value in
            if self.BEO.toolBarCurrentViewId != self.viewId {
                self.popUpIsVisible = false
            }
        })
        .onAppear {
            DispatchQueue.main.async {
                self.initChannels()
                safeFirebaseUserId() { userId in
                    self.currentUserId = userId
                }
                self.MVS.initialize(realm: self.BEO.realmInstance, activityId: self.activityId, viewId: self.viewId)
                self.observeFromRealm()
                self.MVS.startFirebaseObserver()
            }
            // Load View State
            loadFromRealm()
        }
    }
    
    func gestureDragBasicTool() -> some Gesture {
        DragGesture()
            .updating($dragOffset, body: { (value, state, transaction) in
                if self.lifeIsLocked { return }
                self.BEO.ignoreUpdates = true
                state = value.translation
            })
            .onChanged { drag in
                if self.lifeIsLocked { return }
                self.BEO.ignoreUpdates = true
                self.isDragging = true
                let translation = drag.translation
                self.updateRealmPos(x: self.position.x + translation.width,
                                              y: self.position.y + translation.height)
                self.sendXY(width: translation.width, height: translation.height)
            }
            .onEnded { drag in
                if self.lifeIsLocked { return }
                self.BEO.ignoreUpdates = false
                self.isDragging = false
                let translation = drag.translation
                self.position = CGPoint(x: self.position.x + translation.width,
                                                  y: self.position.y + translation.height)
                self.updateRealm()
            }.simultaneously(with: TapGesture(count: 2)
                .onEnded { _ in
                    print("Tapped")
                    self.popUpIsVisible = !self.popUpIsVisible
                    self.toggleMenuWindow()
                    if self.popUpIsVisible {
                        self.sendToolAttributes()
                    }
                }
            )
        
    }

    func isDisabledChecker() -> Bool { return isDisabled }
    func isDeletedChecker() -> Bool { return self.MVS.isDeleted }
    
    func minSizeCheck() {
        if self.lifeWidth < 50 {
            self.lifeWidth = 100
        }
        if self.lifeHeight < 50 {
            self.lifeHeight = 100
        }
    }
    
    @MainActor
    func initChannels() {
        receiveOnSessionChange()
    }
    
    @MainActor
    func receiveOnSessionChange() {
        CodiChannel.SESSION_ON_ID_CHANGE.receive(on: RunLoop.main) { sc in
            let temp = sc as! SessionChange
            if self.activityId == temp.activityId {
                self.isDisabled = false
            } else {
                self.isDisabled = true
            }
        }.store(in: &cancellables)
    }
    func toggleMenuWindow() {
        
        if self.popUpIsVisible {
            self.BEO.toolBarCurrentViewId = self.viewId
            self.BEO.toolSettingsIsShowing = true
        } else {
            self.BEO.toolSettingsIsShowing = false
        }

    }
    
    @MainActor
    func sendToolAttributes() {
        CodiChannel.TOOL_ATTRIBUTES.send(value: ViewAtts(
            viewId: self.viewId,
            size: self.lifeWidth,
            rotation: self.lifeRotation,
            position: self.position,
            toolType: self.toolType,
            isLocked: self.lifeIsLocked
        ))
    }
    
    func sendXY(width:CGFloat, height:CGFloat) {
        CodiChannel.TOOL_ON_FOLLOW.send(value: ViewFollowing(
            viewId: self.viewId,
            x: self.position.x + width,
            y: self.position.y + height
        ))
    }
    
    // Realm / Firebase
    func loadFromRealm(managedView: ManagedView?=nil) {
        if isDisabledChecker() || isDeletedChecker() {return}
        var mv = managedView
        if mv == nil {mv = realm().object(ofType: ManagedView.self, forPrimaryKey: self.viewId)}
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
        lifeLastUserId = umv.lastUserId
        minSizeCheck()
    }
    
    // Observe From Realm
    func observeFromRealm() {
        if isDisabledChecker() || isDeletedChecker() {return}
        MVS.observeRealmManagedView() { temp in
            self.isDisabled = false
            if self.isDragging {return}
            
            DispatchQueue.main.async {
                if self.isDragging {return}
                
                if self.BEO.isPlayingAnimation {
                    withAnimation {
                        position = CGPoint(x: temp.x, y: temp.y)
                    }
                } else {
                    if temp.lastUserId != self.currentUserId {
                        let newPosition = CGPoint(x: temp.x, y: temp.y)
                        self.coordinateStack.append(newPosition)
                        self.animateToNextCoordinate()
                    }
                }
                
                if self.activityId != temp.boardId {self.activityId = temp.boardId}
                
                if self.lifeWidth != Double(temp.width) {self.lifeWidth = Double(temp.width)}
                if self.lifeHeight != Double(temp.height) { self.lifeHeight = Double(temp.height)}
                if self.lifeRotation != temp.rotation { self.lifeRotation = temp.rotation}
                if self.lifeToolType != temp.toolType { self.lifeToolType = temp.toolType}
                if self.lifeColorRed != temp.colorRed {self.lifeColorRed = temp.colorRed}
                if self.lifeColorGreen != temp.colorGreen { self.lifeColorGreen = temp.colorGreen}
                if self.lifeColorBlue != temp.colorBlue {self.lifeColorBlue = temp.colorBlue}
                if self.lifeColorAlpha != temp.colorAlpha { self.lifeColorAlpha = temp.colorAlpha}
                
                if self.lifeIsLocked != temp.isLocked { self.lifeIsLocked = temp.isLocked}
                self.lifeLastUserId = temp.lastUserId
                self.MVS.isDeleted = temp.isDeleted
                self.minSizeCheck()
            }
        }
        
    }
    
    func updateRealm(x:Double?=nil, y:Double?=nil) {
        if isDisabledChecker() || isDeletedChecker() {return}
        DispatchQueue.global(qos: .background).async {
            // Create a new Realm instance for the background thread
            autoreleasepool {
                do {
                    let realm = try Realm()
                    if let mv = realm.findByField(ManagedView.self, value: self.viewId) {
                        try realm.write {
                            // Modify the object
                            mv.x = x ?? self.position.x
                            mv.y = y ?? self.position.y
                            mv.rotation = self.lifeRotation
                            mv.toolType = self.lifeToolType
                            mv.width = Int(self.lifeWidth)
                            mv.height = Int(self.lifeHeight)
                            mv.colorRed = self.lifeColorRed
                            mv.colorGreen = self.lifeColorGreen
                            mv.colorBlue = self.lifeColorBlue
                            mv.colorAlpha = self.lifeColorAlpha
                            mv.isLocked = self.lifeIsLocked
                            mv.lastUserId = self.currentUserId
                            // TODO: Firebase Users ONLY
                            self.MVS.updateFirebase(mv: mv)
                        }
                    }
                } catch {
                    // Handle error
                    print("Realm error: \(error)")
                }
            }
        }
    }
    
    
    func updateRealmPos(x:Double?=nil, y:Double?=nil) {
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    if let mv = realm.findByField(ManagedView.self, value: self.viewId) {
                        try realm.write {
                            mv.x = x ?? self.position.x
                            mv.y = y ?? self.position.y
                            mv.lastUserId = self.currentUserId
                        }
                        self.MVS.updateFirebase(mv: mv)
                    }
                } catch {
                    print("Realm error: \(error)")
                }
            }
        }
    }
    
    // Animations
    func animateToNextCoordinate() {
        guard !coordinateStack.isEmpty else { return }
        
        if self.isDragging {
            coordinateStack.removeAll()
            return
        }
        
        let nextCoordinate = coordinateStack.removeFirst()
        withAnimation { self.position = nextCoordinate }

        // Schedule the next animation after a delay
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if !self.coordinateStack.isEmpty {
                self.animateToNextCoordinate()
            }
        }
    }
    
   

}
