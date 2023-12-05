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

class BoardEngineObject : ObservableObject {
    static let shared = BoardEngineObject()
    @Environment(\.colorScheme) var colorScheme
    // Current Board
    @Published var currentSessionId: String = ""
    @Published var currentActivityId: String = ""
    // Board Settings
    @Published var boardWidth: CGFloat = 3000.0
    @Published var boardHeight: CGFloat = 4000.0
    @Published var boardStartPosX: CGFloat = 3000.0 / 2
    @Published var boardStartPosY: CGFloat = 4000.0 / 2
    @Published var boardBgColor: Color = Color.green.opacity(0.75)
    
    @Published var boardBgName: String = "SoccerFieldFullView"
    @Published private var boardBgRed: Double = 48.0
    @Published private var boardBgGreen: Double = 128.0
    @Published private var boardBgBlue: Double = 20.0
    @Published var boardBgAlpha: Double = 0.75
    
    @Published var boardFieldLineColor: Color = Color.white
    @Published var boardFieldLineRed: Double = 48.0
    @Published var boardFieldLineGreen: Double = 128.0
    @Published var boardFieldLineBlue: Double = 20.0
    @Published var boardFieldLineAlpha: Double = 0.75
    @Published var boardFeildLineStroke: Double = 10
    @Published var boardFeildRotation: Double = -90
    
    func getColor() -> Color {
        return Color(red: boardBgRed, green: boardBgGreen, blue: boardBgBlue, opacity: boardBgAlpha)
    }
    
    func getFieldLineColor() -> Color {
        return Color(red: boardFieldLineRed, green: boardFieldLineGreen, blue: boardFieldLineBlue, opacity: boardFieldLineAlpha)
    }
    
    func setColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        boardBgRed = red
        boardBgGreen = green
        boardBgBlue = blue
        boardBgAlpha = alpha
        boardBgColor = getColor()
    }
    
    func setColor(colorIn:Color) {
        if let cIn = colorIn.toRGBA() {
            boardBgRed = cIn.red
            boardBgGreen = cIn.green
            boardBgBlue = cIn.blue
            boardBgAlpha = cIn.alpha
            boardBgColor = getColor()
        }
    }
    
    func setFieldLineColor(colorIn:Color) {
        if let cIn = colorIn.toRGBA() {
            boardFieldLineRed = cIn.red
            boardFieldLineGreen = cIn.green
            boardFieldLineBlue = cIn.blue
            boardFieldLineAlpha = cIn.alpha
            boardFieldLineColor = getFieldLineColor()
        }
    }
    @Published var boardBgViewItems: [String: () -> AnyView] = [
        "SoccerFieldFullView": { AnyView(SoccerFieldFullView(isMini: false)) },
        "SoccerFieldHalfView": { AnyView(SoccerFieldHalfView(isMini: false)) },
        "BasicSquareView": {AnyView(BasicSquareView(isMini: false))}
    ]
    
    @Published var boardBgViewSettingItems: [String: () -> AnyView] = [
        "SoccerFieldFullView": { AnyView(SoccerFieldFullView(isMini: true)) },
        "SoccerFieldHalfView": { AnyView(SoccerFieldHalfView(isMini: true)) },
        "BasicSquareView": {AnyView(BasicSquareView(isMini: true))}
    ]
    func setBoardBgView(boardName: String) {
        boardBgName = boardName
    }

    func boardBgView() -> AnyView {
        AnyView(SoccerFieldFullView(isMini: false))
    }
    
    func foregroundColor() -> Color { return foregroundColorForScheme(colorScheme) }
    func backgroundColor() -> Color { return backgroundColorForScheme(colorScheme) }

    private init() {}
}

struct BoardEngine: View {
    @Binding var isDraw: Bool
    @EnvironmentObject var BEO: BoardEngineObject
    @State var cancellables = Set<AnyCancellable>()
    
    let realmIntance = realm()
    @State private var sessionNotificationToken: NotificationToken? = nil
    @State private var activityNotificationToken: NotificationToken? = nil
    @State private var managedViewNotificationToken: NotificationToken? = nil
    let firebaseService = FirebaseService(reference: Database
        .database()
        .reference()
        .child(DatabasePaths.managedViews.rawValue))
    
    @State private var drawingStartPoint: CGPoint = .zero
    @State private var drawingEndPoint: CGPoint = .zero
    
    @State private var currentSessionWasLoaded = false
    @State private var sessionID: String = "SOL"
    @State private var activityID: String = ""
    
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
                 if drawingStartPoint != .zero {
                     Path { path in
                         path.move(to: drawingStartPoint)
                         path.addLine(to: drawingEndPoint)
                     }
                     .stroke(Color.red, lineWidth: 10)
                 }
             }
            
        }
        .frame(width: self.BEO.boardWidth, height: self.BEO.boardHeight)
        .background {
            FieldOverlayView(width: self.BEO.boardWidth, height: self.BEO.boardHeight, background: {
                self.BEO.boardBgColor
            }, overlay: {
                if let temp = self.BEO.boardBgViewItems[self.BEO.boardBgName] { temp().environmentObject(self.BEO) }
            }).position(x: self.BEO.boardStartPosX, y: self.BEO.boardStartPosY)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !self.isDraw {return}
                    self.drawingStartPoint = value.startLocation
                    self.drawingEndPoint = value.location
                }
                .onEnded { value in
                    if !self.isDraw {return}
                    self.drawingEndPoint = value.location
                    saveLineData(start: value.startLocation, end: value.location)
                }
        ).onAppear {
            self.loadAllSessionPlans()
            CodiChannel.SESSION_ON_ID_CHANGE.receive(on: RunLoop.main) { sc in
                let temp = sc as! SessionChange
                
                var sessionDidChange = false
                var activityDidChange = false
                
                if let newSID = temp.sessionId {
                    if self.sessionID != newSID {
                        self.sessionID = newSID
                        self.BEO.currentSessionId = newSID
                        sessionDidChange = true
                    }
                }
                
                if let newAID = temp.activityId {
                    if self.activityID != newAID && !newAID.isEmpty {
                        self.activityID = newAID
                        self.BEO.currentActivityId = newAID
                        activityDidChange = true
                    }
                }
                
                if sessionDidChange {
                    self.loadSessionPlan()
                } else {
                    if activityDidChange {
                        self.loadActivityPlan(planId: self.activityID)
                    }
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
                        .setValue(newTool.toDict())
                }
                
            }.store(in: &cancellables)
        }
    }
    
    func loadAllSessionPlans() {
        
        if self.currentSessionWasLoaded {
            loadSessionPlan()
            return
        }
        
        let sessionList = self.realmIntance.objects(SessionPlan.self)
        if sessionList.isEmpty {
            self.realmIntance.safeWrite { r in
                let newSession = SessionPlan()
                newSession.id = self.sessionID
                self.BEO.currentSessionId = self.sessionID
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
        
    }
    
    func resetTools() {
        basicTools.removeAll()
        basicTools = []
    }
    
    func loadFromCurrentSession() {
        if let temp = realmIntance.findByField(CurrentSession.self, value: "SOL") {
            self.sessionID = temp.sessionId
            self.activityID = temp.activityId
            currentSessionWasLoaded = true
        }
    }
    func createUpdateCurrentSession() {
        if let temp = realmIntance.findByField(CurrentSession.self, value: "SOL") {
            realmIntance.safeWrite { r in
                temp.sessionId = self.sessionID
                temp.activityId = self.activityID
                r.add(temp, update: .all)
            }
        } else {
            let newCS = CurrentSession()
            newCS.sessionId = self.sessionID
            newCS.activityId = self.activityID
            realmIntance.safeWrite { r in
                r.add(newCS)
            }
        }
    }
    
    func loadSessionPlan() {
        let tempBoard = self.realmIntance.findByField(SessionPlan.self, field: "id", value: self.sessionID)
        if tempBoard == nil { return }
        self.BEO.currentSessionId = self.sessionID
        loadActivityPlan()
    }
    
    func loadActivityPlan(planId:String?=nil) {
        resetTools()
        
        if planId != nil || !self.activityID.isEmpty {
            if let act = self.realmIntance.findByField(ActivityPlan.self, field: "id", value: self.activityID) {
                self.BEO.setColor(red: act.backgroundRed, green: act.backgroundGreen, blue: act.backgroundBlue, alpha: act.backgroundAlpha)
                self.BEO.boardBgName = act.backgroundView
                self.activities.append(act)
            }
            loadManagedViewTools()
            return
        }
        
        if let acts = self.realmIntance.findAllByField(ActivityPlan.self, field: "sessionId", value: self.sessionID) {
            if !acts.isEmpty {
                var hasBeenSet = false
                for i in acts {
                    if !hasBeenSet {
                        self.activityID = i.id
                        self.BEO.setColor(red: i.backgroundRed, green: i.backgroundGreen, blue: i.backgroundBlue, alpha: i.backgroundAlpha)
                        self.BEO.boardBgName = i.backgroundView
                        self.BEO.currentActivityId = self.activityID
                        hasBeenSet = true
                    }
                    self.activities.append(i)
                }
                loadManagedViewTools()
                return
            }
        }
        let newActivity = ActivityPlan()
        self.activityID = newActivity.id
        newActivity.sessionId = self.sessionID
        self.BEO.currentActivityId = self.activityID
        self.BEO.setColor(red: newActivity.backgroundRed, green: newActivity.backgroundGreen, blue: newActivity.backgroundBlue, alpha: newActivity.backgroundAlpha)
        self.activities.append(newActivity)
        self.realmIntance.safeWrite { r in
            r.add(newActivity)
        }
        loadManagedViewTools()
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
                        if i.isInvalidated {continue}
                        basicTools.safeAdd(i)
                    }
                case .update(let results, let de, _, _):
                    print("Realm Listener: update")
                    
                    for d in de {
                        basicTools.remove(at: d)
                    }
                    
                    for i in results {
                        if i.isInvalidated {continue}
                        basicTools.safeAdd(i)
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
                    .setValue(line.toDict())
            }
        }
    }
}

