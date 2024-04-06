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
import CoreEngine


// Tool Bar Picker Icon View
struct ManagedViewBoardToolIcon: View {
    let toolType: String
    
    @State private var color: Color = .black
    @State private var rotation = 0.0

    var body: some View {
        Image(toolType)
            .resizable()
    }
}


// Main Board Tool View
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

extension View {
    func enableMVT(viewId: String, activityId: String) -> some View {
        self.modifier(enableManagedViewTool(viewId: viewId, activityId: activityId))
    }
}

struct enableManagedViewTool : ViewModifier {
    
    @State var viewId: String
    @State var activityId: String
    
//    @EnvironmentObject var BEO: BoardEngineObject
//    @State var MVS: SingleManagedViewService = SingleManagedViewService()
    @StateObject var MVO: ManagedViewObject = ManagedViewObject()
    
    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
        }
        .zIndex(MVO.isDisabled || MVO.lifeIsLocked ? 3.0 : 5.0)
        .frame(width: MVO.lifeWidth * 2, height: MVO.lifeHeight * 2)
        .rotationEffect(MVO.lifeRotation)
        .border(MVO.popUpIsVisible ? MVO.lifeBorderColor : Color.clear, width: 10) // Border modifier
        .position(x: MVO.position.x + (MVO.isDragging ? MVO.dragOffset.width : 0) + (MVO.lifeWidth),
                  y: MVO.position.y + (MVO.isDragging ? MVO.dragOffset.height : 0) + (MVO.lifeHeight))
        .simultaneousGesture(gestureDragBasicTool())
        .opacity(!MVO.isDisabledChecker() && !MVO.isDeletedChecker() ? 1 : 0.0)
        .onChange(of: self.MVO.toolBarCurrentViewId, perform: { _ in
            if self.MVO.toolBarCurrentViewId != self.viewId { MVO.popUpIsVisible = false }
        })
        .onChange(of: self.MVO.toolSettingsIsShowing, perform: { _ in
            if !self.MVO.toolSettingsIsShowing { MVO.popUpIsVisible = false }
        })
        .onAppear {
            self.MVO.initializeWithViewId(viewId: viewId)
        }
    }
    
    func gestureDragBasicTool() -> some Gesture {
        DragGesture()
            .updating(MVO.$dragOffset, body: { (value, state, transaction) in
                DispatchQueue.main.async { self.MVO.ignoreUpdates = true }
                if MVO.lifeIsLocked { return }
                state = value.translation
            })
            .onChanged { drag in
                DispatchQueue.main.async { self.MVO.ignoreUpdates = true }
                if MVO.lifeIsLocked { return }
                MVO.isDragging = true
                if MVO.useOriginal {
                    self.MVO.originalPosition = MVO.position
                    self.MVO.useOriginal = false
                }
                let translation = drag.translation
                MVO.position = CGPoint(x: MVO.originalPosition.x + translation.width,
                                       y: MVO.originalPosition.y + translation.height)
                self.updateRealmPos(x: MVO.originalPosition.x + translation.width,
                                              y: MVO.originalPosition.y + translation.height)
//                self.sendXY(width: translation.width, height: translation.height)
            }
            .onEnded { drag in
                DispatchQueue.main.async { self.MVO.ignoreUpdates = false }
                if MVO.lifeIsLocked { return }
                MVO.isDragging = false
                let translation = drag.translation
                MVO.position = CGPoint(
                    x: MVO.originalPosition.x + translation.width,
                    y: MVO.originalPosition.y + translation.height
                )
                self.updateRealm()
                self.MVO.useOriginal = true
            }.simultaneously(with: TapGesture(count: 2)
                .onEnded { _ in
                    print("Tapped")
                    MVO.popUpIsVisible = !MVO.popUpIsVisible
                    self.MVO.toggleMenuWindow()
                    if MVO.popUpIsVisible {
//                        self.sendToolAttributes()
                    }
                }
            )
        
    }
    
    func updateRealm(x:Double?=nil, y:Double?=nil) {
        if MVO.isDisabledChecker() || MVO.isDeletedChecker() {return}
        DispatchQueue.global(qos: .background).async {
            // Create a new Realm instance for the background thread
            autoreleasepool {
                do {
                    let realm = try Realm()
                    if let mv = realm.findByField(ManagedView.self, value: self.viewId) {
                        try realm.write {
                            // Modify the object
                            mv.x = x ?? MVO.position.x
                            mv.y = y ?? MVO.position.y
                            mv.rotation = MVO.lifeRotation.degrees
                            mv.toolType = MVO.lifeToolType
                            mv.width = Int(MVO.lifeWidth)
                            mv.height = Int(MVO.lifeHeight)
                            mv.colorRed = MVO.lifeColorRed
                            mv.colorGreen = MVO.lifeColorGreen
                            mv.colorBlue = MVO.lifeColorBlue
                            mv.colorAlpha = MVO.lifeColorAlpha
                            mv.isLocked = MVO.lifeIsLocked
                            mv.lastUserId = MVO.currentUserId
                            self.MVO.updateFirebase(mv: mv)
                            // save historical copy
                            self.saveSnapshotToHistoryInRealm()
                        }
                    }
                } catch {
                    print("Realm error: \(error)")
                }
            }
        }
    }
    
    func saveSnapshotToHistoryInRealm() {
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                do {
                    let history = ManagedViewAction()
                    history.viewId = self.viewId
                    history.boardId = self.activityId
                    history.x = MVO.position.x
                    history.y = MVO.position.y
                    history.rotation = MVO.lifeRotation.degrees
                    history.toolType = MVO.lifeToolType
                    history.width = Int(MVO.lifeWidth)
                    history.height = Int(MVO.lifeHeight)
                    history.colorRed = MVO.lifeColorRed
                    history.colorGreen = MVO.lifeColorGreen
                    history.colorBlue = MVO.lifeColorBlue
                    history.colorAlpha = MVO.lifeColorAlpha
                    history.isLocked = MVO.lifeIsLocked
                    history.lastUserId = MVO.currentUserId
                    let realm = try Realm()
                    realm.safeWrite { r in
                        r.create(ManagedViewAction.self, value: history, update: .all)
                    }
                    
                } catch {
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
                            mv.x = x ?? MVO.position.x
                            mv.y = y ?? MVO.position.y
                            mv.lastUserId = MVO.currentUserId
                        }
                        self.MVO.updateFirebase(mv: mv)
                    }
                } catch {
                    print("Realm error: \(error)")
                }
            }
        }
    }
    
}
