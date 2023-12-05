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
    @State private var isDeleted = false
    @State private var isDisabled = false
    @State private var lifeUpdatedAt: Int = 0 // Using Double for time representation
    @State private var lifeBorderColor = Color.AIMYellow
    @State private var lifeColor = ColorProvider.black // SwiftUI color representation
    @State private var lifeOffsetX: Double = 0.0 // CGFloat in SwiftUI
    @State private var lifeOffsetY: Double = 0.0 // CGFloat in SwiftUI
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
    
    // Firebase
    let reference = Database.database().reference().child(DatabasePaths.managedViews.rawValue)
    
    @State var cancellables = Set<AnyCancellable>()
    
    // Functions
    func isDisabledChecker() -> Bool { return isDisabled }
    func isDeletedChecker() -> Bool { return isDeleted }
    func minSizeCheck() {
        if lifeWidth < minSizeWH { lifeWidth = minSizeWH }
        if lifeHeight < minSizeWH { lifeHeight = minSizeWH }
    }
    
    func loadFromRealm(managedView: ManagedView?=nil) {
        if isDisabledChecker() {return}
        var mv = managedView
        if mv == nil {mv = realmInstance.object(ofType: ManagedView.self, forPrimaryKey: viewId)}
        guard let umv = mv else { return }
        // set attributes
        activityId = umv.boardId
        lifeOffsetX = umv.x
        lifeOffsetY = umv.y
        lifeUpdatedAt = umv.dateUpdated
        self.position = CGPoint(x: lifeOffsetX, y: lifeOffsetY)
        print("\(viewId) x: [ \(lifeOffsetX) ] y: [ \(lifeOffsetY) ]")
        lifeWidth = Double(umv.width)
        lifeHeight = Double(umv.height)
        lifeRotation = umv.rotation
        lifeToolType = umv.toolType
        lifeColorRed = umv.colorRed
        lifeColorGreen = umv.colorGreen
        lifeColorBlue = umv.colorBlue
        lifeColorAlpha = umv.colorAlpha
        minSizeCheck()
    }
    func updateRealm() {
        print("!!!! Updating Realm!")
        if isDisabledChecker() {return}
        let mv = realmInstance.findByField(ManagedView.self, value: viewId)
        if mv == nil { return }
        realmInstance.safeWrite { r in
            lifeUpdatedAt = Int(Date().timeIntervalSince1970)
            mv?.dateUpdated = lifeUpdatedAt
            mv?.x = self.position.x
            mv?.y = self.position.y
            mv?.rotation = lifeRotation
            mv?.toolType = lifeToolType
            mv?.width = Int(lifeWidth)
            mv?.height = Int(lifeHeight)
            mv?.colorRed = lifeColorRed
            mv?.colorGreen = lifeColorGreen
            mv?.colorBlue = lifeColorBlue
            mv?.colorAlpha = lifeColorAlpha
            guard let tMV = mv else { return }
            r.create(ManagedView.self, value: tMV, update: .all)
            
            // TODO: Firebase Users ONLY
            if self.activityId.isEmpty || self.viewId.isEmpty {return}
            firebaseDatabase { fdb in
                fdb.child(DatabasePaths.managedViews.rawValue)
                    .child(self.activityId)
                    .child(self.viewId)
                    .setValue(mv?.toDict())
            }
        }
    }
    
    func body(content: Content) -> some View {
            content
                .frame(width: lifeWidth * 2, height: lifeHeight * 2)
//                .colorMultiply(lifeColor.colorValue)
                .rotationEffect(.degrees(lifeRotation))
                .border(popUpIsVisible ? lifeBorderColor : Color.clear, width: 10) // Border modifier
                .position(x: position.x + (isDragging ? dragOffset.width : 0) + (self.lifeWidth),
                          y: position.y + (isDragging ? dragOffset.height : 0) + (self.lifeHeight))
                .gesture(
                    LongPressGesture(minimumDuration: 0.01)
                        .onEnded { _ in
                            self.isDragging = true
                            //onMoveStarted()
                        }
                        .sequenced(before: DragGesture())
                        .updating($dragOffset, body: { (value, state, transaction) in
                            switch value {
                                case .second(true, let drag):
                                    state = drag?.translation ?? .zero
                                default:
                                    break
                            }
                        })
                        .onEnded { value in
                            if case .second(true, let drag?) = value {
                                self.position = CGPoint(x: self.position.x + drag.translation.width, y: self.position.y + drag.translation.height)
                                print("!!!! X: [ \(self.position.x) ] Y: [ \(self.position.y) ]")
                                self.isDragging = false
                                //onMoveComplete()
                                updateRealm()
                            }
                        }.simultaneously(with: TapGesture(count: 2)
                            .onEnded { _ in
                                print("Tapped")
                                popUpIsVisible = !popUpIsVisible
                                CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: "mv_settings", stateAction: popUpIsVisible ? "open" : "close", viewId: viewId))
                                if popUpIsVisible {
                                    CodiChannel.TOOL_ATTRIBUTES.send(value: ViewAtts(
                                        viewId: viewId,
                                        size: lifeWidth,
                                        rotation: lifeRotation,
                                        level: ToolLevels.LINE.rawValue
                                    ))
                                }
                            }
                        )
                )
                .opacity(!isDisabledChecker() && !isDeletedChecker() ? 1 : 0.0)
                .onAppear {
                    isDisabled = false
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
                        if viewId != inVA.viewId { return }
                        if let inColor = inVA.color { lifeColor = ColorProvider.fromColor(inColor) }
                        if let inRotation = inVA.rotation { lifeRotation = inRotation }
                        if let inSize = inVA.size {
                            lifeWidth = inSize
                            lifeHeight = inSize
                        }
                        if inVA.isDeleted {
                            isDeleted = true
                            isDisabled = true
                            
                            // TODO: Firebase Users ONLY
                            firebaseDatabase { fdb in
                                fdb.child(DatabasePaths.managedViews.rawValue)
                                    .child(self.activityId)
                                    .child(self.viewId)
                                    .removeValue()
                            }
                            return
                        }
                        //TODO : Check if anything changed?
                        updateRealm()
                    }.store(in: &cancellables)
                }
        }
}
