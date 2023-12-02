//
//  BoardEngineView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift
import FirebaseDatabase

struct BoardEngine: View {
    @Binding var isDraw: Bool
    @State var cancellables = Set<AnyCancellable>()
    
    let realmIntance = realm()
    @State private var sessionNotificationToken: NotificationToken? = nil
    @State private var activityNotificationToken: NotificationToken? = nil
    @State private var managedViewNotificationToken: NotificationToken? = nil
    let firebaseService = FirebaseService(reference: Database
        .database()
        .reference()
        .child(DatabasePaths.managedViews.rawValue))
    
    //Board
    var width: CGFloat = 3000.0
    var height: CGFloat = 4000.0
    var startPosX: CGFloat = 3000.0 / 2
    var startPosY: CGFloat = 4000.0 / 2
    
    @State private var startPoint: CGPoint = .zero
    @State private var endPoint: CGPoint = .zero
    
    private let sessionDemoId = "SOL"
    @State private var sessionID: String = "SOL"
    @State private var activityID: String = "SOLDemo"
    @State private var boardBg = BoardBgProvider.soccerTwo.tool.image
    
    @State private var sessions: [SessionPlan] = []
    @State private var activities: [ActivityPlan] = []
    @State private var basicTools: [ManagedView] = []
    @State private var lineTools: [ManagedView] = []
    
    
    var body: some View {
         ZStack() {
             
             ForEach(self.basicTools) { item in
                 if item.toolType == "LINE" {
                     LineDrawingManaged(viewId: item.id, activityId: self.activityID)
                 } else {
                     if let temp = SoccerToolProvider.parseByTitle(title: item.toolType)?.tool.image {
                         ManagedViewBoardTool(viewId: item.id, activityId: self.activityID, toolType: temp)
                     }
                 }
             }
             
             // Temporary line being drawn
             if self.isDraw {
                 if startPoint != .zero {
                     Path { path in
                         path.move(to: startPoint)
                         path.addLine(to: endPoint)
                     }
                     .stroke(Color.red, lineWidth: 10)
                 }
             }
            
        }
        .frame(width: width, height: height)
        .background {
            FieldOverlayView(width: width, height: height, background: {
                Color.green.opacity(0.75)
            }, overlay: {
                SoccerFieldFullView(width: height, height: width)
            }).position(x: startPosX, y: startPosY)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !self.isDraw {return}
                    self.startPoint = value.startLocation
                    self.endPoint = value.location
                }
                .onEnded { value in
                    if !self.isDraw {return}
                    self.endPoint = value.location
                    saveLineData(start: value.startLocation, end: value.location)
                }
        ).onAppear {
            self.loadAllSessionPlans()
            
            CodiChannel.SESSION_ON_ID_CHANGE.receive(on: RunLoop.main) { sc in
                let temp = sc as! SessionChange
                
                var sessionDidChange = false
                if let sID = temp.sessionId {
                    if sID != self.sessionID {
                        self.sessionID = sID
                        sessionDidChange = true
                    }
                }
                
                if let aID = temp.activityId { self.activityID = aID }
                
                if sessionDidChange {
                    self.loadSessionPlan()
                } else {
                    self.loadActivityPlan()
                }
                
            }.store(in: &cancellables)
            
            CodiChannel.TOOL_ON_DELETE.receive(on: RunLoop.main) { viewId in
                self.deleteToolById(viewId: viewId as! String)
            }.store(in: &cancellables)
            
            CodiChannel.TOOL_ON_CREATE.receive(on: RunLoop.main) { tool in
                let newTool = ManagedView()
                newTool.toolType = tool as! String
                newTool.boardId = self.activityID
                realmIntance.safeWrite { r in
                    r.add(newTool)
                }
                
                // TODO: Firebase Users ONLY
                firebaseDatabase { fdb in
                    fdb.child(DatabasePaths.managedViews.rawValue)
                        .child(self.activityID)
                        .child(newTool.id)
                        .setValue(newTool.toDictionary())
                }
                
            }.store(in: &cancellables)
        }
    }
    
    func loadAllSessionPlans() {
        
        let sessionList = self.realmIntance.objects(SessionPlan.self)
        if sessionList.isEmpty {
            self.realmIntance.safeWrite { r in
                let newSession = SessionPlan()
                newSession.id = self.sessionID
                r.add(newSession)
            }
        } else {
            let temp = sessionList.first
            if temp?.id != nil && !temp!.id.isEmpty {
                self.sessionID = temp?.id ?? "SOL"
            }
            for i in sessionList {
                self.sessions.append(i)
            }
        }
        loadSessionPlan()
        print("BOARDS: initial load -> ${boardList.size}")
    }
    
    func resetTools() {
        basicTools.removeAll()
        basicTools = []
    }
    
    func loadSessionPlan() {
        let tempBoard = self.realmIntance.findByField(SessionPlan.self, field: "id", value: self.sessionID)
        if tempBoard == nil { return }
        loadActivityPlan()
        loadManagedViewTools()
    }
    
    func loadActivityPlan() {
        resetTools()
        if let acts = self.realmIntance.findAllByField(ActivityPlan.self, field: "sessionId", value: self.sessionID) {
            if !acts.isEmpty {
                var hasBeenSet = false
                for i in acts {
                    if !hasBeenSet {
                        self.activityID = i.id
                        hasBeenSet = true
                    }
                    self.activities.append(i)
                }
                return
            }
        }
        
        self.realmIntance.safeWrite { r in
            let newActivity = ActivityPlan()
            newActivity.id = self.activityID
            newActivity.sessionId = self.sessionID
            r.add(newActivity)
            self.activities.append(newActivity)
        }
    }
    
    func loadSessionPlans() {
        
        // TODO: Firebase Users ONLY
        fireSessionPlansAsync(sessionId: self.sessionID, realm: self.realmIntance)
        
        // FREE
        let umvs = realmIntance.objects(SessionPlan.self)
        sessionNotificationToken = umvs.observe { (changes: RealmCollectionChange) in
            switch changes {
                case .initial(let results):
                    print("Realm Listener: initial")
                    for i in results {
                        sessions.append(i)
                    }
                case .update(let results, let de, _, _):
                    print("Realm Listener: update")
                    for i in results {
                        sessions.append(i)
                    }
                    for d in de {
                        sessions.remove(at: d)
                    }
                case .error(let error):
                    print("Realm Listener: error")
                    fatalError("\(error)")  // Handle errors appropriately in production code
            }
        }
    }
    
    func loadManagedViewTools() {
        
        // TODO: Firebase Users ONLY
        fireManagedViewsAsync(activityId: self.activityID, realm: self.realmIntance)
        
        // FREE
        let umvs = realmIntance.findAllByField(ManagedView.self, field: "boardId", value: self.activityID)
        managedViewNotificationToken = umvs?.observe { (changes: RealmCollectionChange) in
            switch changes {
                case .initial(let results):
                    print("Realm Listener: initial")
                    for i in results {
                        basicTools.safeAdd(i)
                    }
                case .update(let results, let de, _, _):
                    print("Realm Listener: update")
                    for i in results {
                        basicTools.safeAdd(i)
                    }
                    for d in de {
                        basicTools.remove(at: d)
                    }
                case .error(let error):
                    print("Realm Listener: error")
                    fatalError("\(error)")  // Handle errors appropriately in production code
            }
        }
    }
    
    func deleteToolById(viewId:String) {
        self.realmIntance.safeWrite { r in
            let temp = r.findByField(ManagedView.self, field: "boardId", value: viewId)
            guard let t = temp else {return}
            r.delete(t)
        }
        
    }
    
    // Line/Drawing
    private func saveLineData(start: CGPoint, end: CGPoint) {
        realmIntance.safeWrite { r in
            let line = ManagedView()
            line.boardId = self.activityID
            line.startX = Double(start.x)
            line.startY = Double(start.y)
            line.endX = Double(end.x)
            line.endY = Double(end.y)
            line.x = Double(start.x)
            line.y = Double(start.y)
            line.width = 10
            line.toolColor = "Black"
            line.toolType = "LINE"
            line.dateUpdated = Int(Date().timeIntervalSince1970)
            r.add(line)
            
            // TODO: Firebase Users ONLY
            firebaseDatabase { fdb in
                fdb.child(DatabasePaths.managedViews.rawValue)
                    .child(self.activityID)
                    .child(line.id)
                    .setValue(line.toDictionary())
            }
        }
    }
}

