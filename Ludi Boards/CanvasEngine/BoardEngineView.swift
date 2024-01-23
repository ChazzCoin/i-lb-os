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

//    @Environment(\.colorScheme) var colorScheme

    @ObservedResults(SessionPlan.self) var allSessionPlans
    @ObservedResults(ActivityPlan.self) var allActivityPlans
    
//    @ObservedObject var roomFireService = FirebaseRoomService()
    
    let realmInstance = realm()
    @Published var boards = Sports()
    @Published var boardRefreshFlag = true
    
    @Published var globalWindowsIndex = 3.0
    @Published var windowIsOpen: Bool = false
    @Published var gesturesAreLocked: Bool = false
    @Published var isShowingPopUp: Bool = false
    
    @Published var isSharedBoard = false
    @Published var isLoggedIn: Bool = true
    @Published var userId: String? = nil
    @Published var userName: String? = nil
    // Current Board
    @Published var showTipViewStatic: Bool = false
    @Published var isDraw: Bool = false
    @Published var isDrawing: String = "LINE"
    @Published var isLoading: Bool = true
    
    @Published var currentSessionId: String = ""
    @Published var currentActivityId: String = ""
    
    @Published var canvasOffset = CGPoint.zero
    @Published var canvasScale: CGFloat = 0.1
    @Published var canvasRotation: CGFloat = 0.0
    @GestureState var gestureScale: CGFloat = 1.0
    @Published var lastScaleValue: CGFloat = 1.0

    // Shared
    @Published var isShared: Bool = false
    @Published var isHost: Bool = true
    
    @Published var canvasWidth: CGFloat = 8000.0
    @Published var canvasHeight: CGFloat = 8000.0
    // Board Settings
    @Published var boardWidth: CGFloat = 5000.0
    @Published var boardHeight: CGFloat = 6000.0
    @Published var boardStartPosX: CGFloat = 0.0
    @Published var boardStartPosY: CGFloat = 1000.0
    @Published var boardBgColor: Color = Color.secondaryBackground
    
    @Published var boardBgName: String = "Sol"
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
    @Published var boardFeildRotation: Double = 0
    
    @Published var deviceScreenBounds = UIScreen.main.bounds
    @Published var deviceType = UIDevice.current.userInterfaceIdiom
    
    func deviceIsPhone() -> Bool {
        return self.deviceType == .phone
    }
    func deviceIsPad() -> Bool {
        return self.deviceType == .pad
    }
    
    // Current Session / Activity
    func changeSession(sessionId:String) {
        self.currentSessionId = sessionId
    }
    
    func changeActivity(activityId:String) {
        if activityId.isEmpty { return }
        if activityId != self.currentActivityId {
            FirebaseRoomService.leaveRoom(roomId: self.currentActivityId)
            self.currentActivityId = activityId
            FirebaseRoomService.enterRoom(roomId: activityId)
        }
    }
    
    func runCanvasLoading() {
        self.gesturesAreLocked = true
        self.isLoading = true
        DispatchQueue.executeAfter(seconds: 5, action: {
            self.isLoading = false
            self.gesturesAreLocked = false
        })
    }
    
    // Navigation
    
    func navRight() {
        let adjustedOffset = calculateAdjustedOffset(angle: canvasRotation, x: -100, y: 0)
        self.canvasOffset.x += adjustedOffset.dx
        self.canvasOffset.y += adjustedOffset.dy
    }

    func navLeft() {
        let adjustedOffset = calculateAdjustedOffset(angle: canvasRotation, x: 100, y: 0)
        self.canvasOffset.x += adjustedOffset.dx
        self.canvasOffset.y += adjustedOffset.dy
    }

    func navDown() {
        let adjustedOffset = calculateAdjustedOffset(angle: canvasRotation, x: 0, y: -100)
        self.canvasOffset.x += adjustedOffset.dx
        self.canvasOffset.y += adjustedOffset.dy
    }

    func navUp() {
        let adjustedOffset = calculateAdjustedOffset(angle: canvasRotation, x: 0, y: 100)
        self.canvasOffset.x += adjustedOffset.dx
        self.canvasOffset.y += adjustedOffset.dy
    }

    private func calculateAdjustedOffset(angle: CGFloat, x: CGFloat, y: CGFloat) -> CGVector {
        let dx = x * cos(angle) - y * sin(angle)
        let dy = x * sin(angle) + y * cos(angle)
        return CGVector(dx: dx, dy: dy)
    }
    func loadUser() {
        self.isLoggedIn = userIsVerifiedToProceed()
        self.realmInstance.getCurrentSolUser { su in
            self.userId = su.userId
            self.userName = su.userName
        }
    }
    
    func fullScreen() {
        canvasScale = 0.2
        canvasOffset = CGPoint.zero
        canvasRotation = 0.0
    }
    
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
  
    func setBoardBgView(boardName: String) {
        boardBgName = boardName
    }

    func boardBgView() -> AnyView {
        AnyView(SoccerFieldFullView(isMini: false))
    }
    
    func foregroundColor() -> Color { return Color.primaryBackground }
    func backgroundColor() -> Color { return Color.secondaryBackground }
    
    func deleteAllTools() {
        let results = self.realmInstance.objects(ManagedView.self).filter("boardId == %@", self.currentActivityId)
        if results.isEmpty { return }
        for tool in results {
            self.realmInstance.safeWrite { _ in
                tool.isDeleted = true
            }
        }
    }
    
}

struct BoardEngine: View {
    @Environment(\.scenePhase) var deviceState
    @EnvironmentObject var BEO: BoardEngineObject
    @StateObject var PMO = PopupMenuObject()
    
    //
    @State var MVS: AllManagedViewsService? = nil
    @State var SPS: SessionPlanService? = nil
    @State var APS: ActivityPlanService? = nil
    @State var cancellables = Set<AnyCancellable>()
    
    // NEW
    @State private var sessionObserver = RealmChangeListener<SessionPlan>()
    @State private var activityObserver = RealmChangeListener<ActivityPlan>()
    @State private var managedViewsObserver = RealmChangeListener<ManagedView>()
    @State private var boardSessionObserver = BoardSessionObserver()
    
    // TODO: -> Move to Single
    @State private var realmIntance = realm()
    @State private var reference: DatabaseReference = Database.database().reference()
    @State private var observerHandleOne: DatabaseHandle?
    @State private var observerHandleTwo: DatabaseHandle?
    @State private var observerHandleThree: DatabaseHandle?
    @State private var sessionNotificationToken: NotificationToken? = nil
    @State private var activityNotificationToken: NotificationToken? = nil
    @State private var managedViewNotificationToken: NotificationToken? = nil
    let firebaseService = FirebaseService(reference: Database
        .database()
        .reference()
        .child(DatabasePaths.managedViews.rawValue))
    //
    
    @State private var drawingStartPoint: CGPoint = .zero
    @State private var drawingEndPoint: CGPoint = .zero
    
    @State private var currentSessionWasLoaded = false
    
    @State private var sessions: [SessionPlan] = []
    @State private var activities: [ActivityPlan] = []
    @State private var basicTools: [ManagedView] = []
    @State private var lineTools: [ManagedView] = []
    
    @State private var isLiveSession: Bool = false
    
    func refreshBoard() {
        self.BEO.boardRefreshFlag = false
        self.BEO.boardRefreshFlag = true
    }
    
    var body: some View {
         ZStack() {
             
             if self.BEO.boardRefreshFlag {
                 ForEach(self.basicTools) { item in
                     if !item.isDeleted {
                         if item.toolType == "LINE" || item.toolType == "DOTTED-LINE" {
                             LineDrawingManaged(viewId: item.id, activityId: self.BEO.currentActivityId)
                                 .zIndex(20.0)
                                 .environmentObject(self.BEO)
                         }
                         else if item.toolType == "CURVED-LINE" {
                             CurvedLineDrawingManaged(viewId: item.id, activityId: self.BEO.currentActivityId)
                                 .zIndex(20.0)
                                 .environmentObject(self.BEO)
                         }
                         else {
                             if let temp = SoccerToolProvider.parseByTitle(title: item.toolType)?.tool.image {
                                 ManagedViewBoardTool(viewId: item.id, activityId: self.BEO.currentActivityId, toolType: temp)
                                     .zIndex(20.0)
                                     .environmentObject(self.BEO)
                             }
                         }
                     }
                     
                 }
             }
             
             // Temporary line being drawn
             if self.BEO.isDraw {
                 if drawingStartPoint != .zero {
                     Path { path in
                         path.move(to: drawingStartPoint)
                         path.addLine(to: drawingEndPoint)
                     }
                     .stroke(Color.red, style: StrokeStyle(lineWidth: 10, dash: [1]))
                 }
             }
            
        }
        .frame(width: self.BEO.boardWidth, height: self.BEO.boardHeight)
        .background(
            FieldOverlayView(width: self.BEO.canvasWidth, height: self.BEO.canvasHeight, background: {
                self.BEO.boardBgColor
            }, overlay: {
                if let CurrentBoardBackground = self.BEO.boards.getAllBoards()[self.BEO.boardBgName] {
                    CurrentBoardBackground()
                        .zIndex(2.0)
                        .environmentObject(self.BEO)
                }
            })
            .position(x: self.BEO.boardStartPosX, y: self.BEO.boardStartPosY).zIndex(2.0)
        )
        .onDrop(of: [.text], isTargeted: nil) { providers in
            providers.first?.loadObject(ofClass: NSString.self) { (droppedString, error) in
                DispatchQueue.main.async {
                    let newTool = ManagedView()
                    newTool.toolType = droppedString as! String
                    newTool.boardId = self.BEO.currentActivityId
                    realmIntance.safeWrite { r in
                        r.create(ManagedView.self, value: newTool, update: .all)
                    }
                    
                    // TODO: Firebase Users ONLY
                    firebaseDatabase(safeFlag: userIsVerifiedToProceed()) { fdb in
                        fdb.child(DatabasePaths.managedViews.rawValue)
                            .child(self.BEO.currentActivityId)
                            .child(newTool.id)
                            .setValue(newTool.toDict())
                    }
                }
            }
            return true
        }
        .simultaneousGesture( self.BEO.isDraw ?
            DragGesture()
                .onChanged { value in
                    if !self.BEO.isDraw {return}
                    self.drawingStartPoint = value.startLocation
                    self.drawingEndPoint = value.location
                }
                .onEnded { value in
                    if !self.BEO.isDraw {return}
                    self.drawingEndPoint = value.location
                    saveLineData(start: value.startLocation, end: value.location)
                } : nil
        )
        .onChange(of: self.deviceState) { newScenePhase in
            switch newScenePhase {
                case .active:
                    print("App is in foreground")
                    FirebaseRoomService.enterRoom(roomId: self.BEO.currentActivityId)
                case .inactive:
                    print("App is inactive")
                    FirebaseRoomService.awayRoom(roomId: self.BEO.currentActivityId)
                case .background:
                    print("App is in background")
                    FirebaseRoomService.leaveRoom(roomId: self.BEO.currentActivityId)
                @unknown default:
                    print("A new case was added that we're not handling")
                    FirebaseRoomService.leaveRoom(roomId: self.BEO.currentActivityId)
            }
        }
        .onDisappear() {
            SPS?.stopObserving()
            APS?.stopObserving()
            MVS?.stopObserving()
            stopObserving()
        }
        .onAppear {
           
            print("BoardEngineView onAppear")
            self.BEO.runCanvasLoading()
            
            self.BEO.loadUser()
            
            SPS = SessionPlanService(realm: self.realmIntance)
            APS = ActivityPlanService(realm: self.realmIntance)
            MVS = AllManagedViewsService(realm: self.realmIntance)
            
            self.oneLoadAllSessionPlans()
            
            onSessionIdChange()
            onToolCreated()
            onToolDeleted()
            
        }
    }
    
    @MainActor
    func onSessionIdChange() {
        CodiChannel.SESSION_ON_ID_CHANGE.receive(on: RunLoop.main) { sc in
            let temp = sc as! SessionChange
            handleBoardChange(temp: temp)
        }.store(in: &cancellables)
    }
    
    @MainActor
    func onToolDeleted() {
        CodiChannel.TOOL_ON_DELETE.receive(on: RunLoop.main) { viewId in
            self.refreshBoard()
        }.store(in: &cancellables)
    }
    
    @MainActor
    func onToolCreated() {
        CodiChannel.TOOL_ON_CREATE.receive(on: RunLoop.main) { tool in
            let newTool = ManagedView()
            newTool.toolType = tool as! String
            newTool.boardId = self.BEO.currentActivityId
            realmIntance.safeWrite { r in
                r.create(ManagedView.self, value: newTool, update: .all)
            }
            
            if userIsVerifiedToProceed() {
                newTool.fireSave(parentId: self.BEO.currentActivityId, id: newTool.id)
            }
            
        }.store(in: &cancellables)
    }
    
    func oneLoadAllSessionPlans() {
        
        if self.currentSessionWasLoaded {
            // TWO
            twoLoadSessionPlan()
            return
        }
        
        if self.BEO.allSessionPlans.isEmpty {
            createNewSessionPlan()
        } else {
            let temp = self.BEO.allSessionPlans.first
            if temp?.id != nil && !temp!.id.isEmpty {
                self.BEO.changeSession(sessionId: temp?.id ?? "SOL")
            }
            for i in self.BEO.allSessionPlans {
                self.sessions.append(i)
            }
        }
        // TWO
        twoLoadSessionPlan()
    }
    
    func twoLoadSessionPlan() {
        
        //TODO: GET ALL SESSIONS && SHARED SESSIONS
        fireGetLiveDemoAsync(realm: self.realmIntance)
        FirebaseSessionPlanService.runFullFetchProcess(realm: self.realmIntance)
        
        if let obj = self.realmIntance.findByField(SessionPlan.self, field: "id", value: self.BEO.currentSessionId) {
            self.BEO.changeSession(sessionId: self.BEO.currentSessionId)
            self.isLiveSession = obj.isLive
            self.sessionObserver.stop()
            self.sessionObserver.observe(object: obj, onChange: { newObj in
                self.isLiveSession = newObj.isLive
            })
            // THREE
            threeLoadActivityPlan()
        }
    }
    
    func threeLoadActivityPlan() {
        resetTools()
        
        // LOAD SINGLE ACTIVITY
        if !self.BEO.currentActivityId.isEmpty {
                       
            if let act = self.realmIntance.findByField(ActivityPlan.self, field: "id", value: self.BEO.currentActivityId) {
                
                self.BEO.changeActivity(activityId: act.id)
                self.BEO.setColor(red: act.backgroundRed, green: act.backgroundGreen, blue: act.backgroundBlue, alpha: act.backgroundAlpha)
                self.BEO.setFieldLineColor(colorIn: Color(red: act.backgroundLineRed, green: act.backgroundLineGreen, blue: act.backgroundLineBlue).opacity(act.backgroundLineAlpha))
                self.BEO.boardBgName = act.backgroundView
                self.BEO.boardFeildRotation = act.backgroundRotation
                self.BEO.boardFeildLineStroke = act.backgroundLineStroke
                self.activities.append(act)
                
                // Realm
                self.activityObserver.observe(object: act, onChange: { temp in
                    self.BEO.setColor(red: temp.backgroundRed, green: temp.backgroundGreen, blue: temp.backgroundBlue, alpha: temp.backgroundAlpha)
                    self.BEO.setFieldLineColor(colorIn: Color(red: temp.backgroundLineRed, green: temp.backgroundLineGreen, blue: temp.backgroundLineBlue).opacity(temp.backgroundLineAlpha))
                    self.BEO.boardBgName = temp.backgroundView
                    self.BEO.boardFeildRotation = temp.backgroundRotation
                    self.BEO.boardFeildLineStroke = temp.backgroundLineStroke
                })
                
                // Firebase
                if self.isLiveSession {
                    APS?.startObserving(activityId: self.BEO.currentActivityId)
                } else {
                    APS?.stopObserving()
                }
                
            }
            fourLoadManagedViewTools()
            return
        }
        
        // LOAD ALL ACTIVITIES
        if let acts = self.realmIntance.findAllByField(ActivityPlan.self, field: "sessionId", value: self.BEO.currentSessionId) {
            if !acts.isEmpty {
                var hasBeenSet = false
                for i in acts {
                    if !hasBeenSet {
                        self.BEO.changeActivity(activityId: i.id)
                        self.BEO.setColor(red: i.backgroundRed, green: i.backgroundGreen, blue: i.backgroundBlue, alpha: i.backgroundAlpha)
                        self.BEO.setFieldLineColor(colorIn: Color(red: i.backgroundLineRed, green: i.backgroundLineGreen, blue: i.backgroundLineBlue))
                        self.BEO.boardBgName = i.backgroundView
                        self.BEO.boardFeildRotation = i.backgroundRotation
                        self.BEO.boardFeildLineStroke = i.backgroundLineStroke
                        hasBeenSet = true
                    }
                    self.activities.append(i)
                }
                fourLoadManagedViewTools()
                return
            }
        }
        
        // TODO: CREATE NEW ACTIVITY
        createNewActivityPlan()
        fourLoadManagedViewTools()
    }
    
    func fourLoadManagedViewTools() {
        if self.BEO.currentActivityId.isEmpty { return }
        // Realm
        let umvs = realmIntance.findAllByField(ManagedView.self, field: "boardId", value: self.BEO.currentActivityId)
        
        self.realmIntance.executeWithRetry {
            self.managedViewNotificationToken = umvs?.observe { (changes: RealmCollectionChange) in
                switch changes {
                    case .initial(let results):
                        print("Realm Listener: initial")
                        for i in results {
                            if i.isInvalidated {continue}
                            self.basicTools.safeAddManagedView(i)
                        }
                    case .update(let results, let de, _, _):
                        print("Realm Listener: update")
                        
                        for d in de {
                            self.basicTools.remove(at: d)
                        }
                        
                        for i in results {
                            if i.isInvalidated {continue}
                            self.basicTools.safeAddManagedView(i)
                        }
                    case .error(let error):
                        print("Realm Listener: \(error)")
                        self.managedViewNotificationToken?.invalidate()
                        self.managedViewNotificationToken = nil
                }
            }
        }
        
        fiveStartObservingManagedViews()
        sixSavePlansToFirebase()
    }
    
    func fiveStartObservingManagedViews() {
        if self.BEO.currentActivityId.isEmpty { return }
        if !BEO.isLoggedIn { return }
        observerHandleOne = reference
            .child(DatabasePaths.managedViews.rawValue)
            .child(self.BEO.currentActivityId)
            .observe(.childAdded, with: { snapshot in
                
                if let temp = snapshot.value as? [String:Any] {
                    let mv = ManagedView(dictionary: temp)
                    if basicTools.hasView(mv) {
                        return
                    }
                    self.realmIntance.safeWrite { r in
                        r.create(ManagedView.self, value: mv, update: .all)
                    }
                    basicTools.safeAddManagedView(mv)
                }
                
            })
        
        observerHandleTwo = reference
            .child(DatabasePaths.managedViews.rawValue)
            .child(self.BEO.currentActivityId)
            .observe(.childRemoved, with: { snapshot in
                let temp = snapshot.toHashMap()
                if let tempId = temp["id"] as? String {
                    basicTools.safeRemoveById(tempId)
                }
            })
    }
    
    func sixSavePlansToFirebase() {
        if !self.BEO.isLoggedIn { return }
        if self.BEO.currentSessionId == "SOL" || self.BEO.currentSessionId.isEmpty {return}
        if let sessionPlan = self.realmIntance.findByField(SessionPlan.self, field: "id", value: self.BEO.currentSessionId) {
            if sessionPlan.id == "SOL" {return}
            sessionPlan.fireSave(id: sessionPlan.id)
        }
        if self.BEO.currentActivityId == "SOL" || self.BEO.currentActivityId.isEmpty {return}
        if let activityPlan = self.realmIntance.findByField(ActivityPlan.self, field: "id", value: self.BEO.currentActivityId) {
            if activityPlan.id == "SOL" {return}
            activityPlan.fireSave(id: activityPlan.id)
        }
    }
    
    func stopObserving() {
        guard let handleOne = observerHandleOne, let handleTwo = observerHandleTwo else { return }
        reference.removeObserver(withHandle: handleOne)
        reference.removeObserver(withHandle: handleTwo)
        observerHandleOne = nil
        observerHandleTwo = nil
    }
    
    func handleBoardChange(temp: SessionChange) {
        var sessionDidChange = false
        var activityDidChange = false
        
        self.BEO.runCanvasLoading()
        APS?.stopObserving()
        MVS?.stopObserving()
        stopObserving()
        
        if let newSID = temp.sessionId {
            if self.BEO.currentSessionId != newSID {
                SPS?.stopObserving()
                self.BEO.changeSession(sessionId: newSID)
                sessionDidChange = true
            }
        }
        
        if let newAID = temp.activityId {
            if self.BEO.currentActivityId != newAID && !newAID.isEmpty {
                self.BEO.changeActivity(activityId: newAID)
                activityDidChange = true
            }
        }
        
        if sessionDidChange {
            self.twoLoadSessionPlan()
        } else if activityDidChange {
            self.threeLoadActivityPlan()
        }
    }
    
    func createNewSessionPlan() {
        
        let results = self.realmIntance.objects(SessionPlan.self)
        if !results.isEmpty {
            if let temp = results.first {
                self.BEO.changeSession(sessionId: temp.id)
                return
            }
        }
        
        self.realmIntance.safeWrite { r in
            let newSession = SessionPlan()
            newSession.title = "Session: \(TimeProvider.getMonthDayYearTime())"
            newSession.ownerId = getFirebaseUserId() ?? CURRENT_USER_ID
            self.BEO.changeSession(sessionId: newSession.id)
            r.add(newSession)
        }
    }
    
    func createNewActivityPlan() {
        
        let results = self.realmIntance.objects(ActivityPlan.self).filter("sessionId == %@", self.BEO.currentSessionId)
        if !results.isEmpty {
            if let temp = results.first {
                self.BEO.changeActivity(activityId: temp.id)
                return
            }
        }
        
        let newActivity = ActivityPlan()
        self.BEO.changeActivity(activityId: newActivity.id)
        newActivity.ownerId = getFirebaseUserId() ?? CURRENT_USER_ID
        newActivity.sessionId = self.BEO.currentSessionId
        let rgbb = Color.secondaryBackground.toRGBA()
        newActivity.backgroundRed = rgbb?.red == nil ? newActivity.backgroundRed : rgbb?.red ?? 0.0
        newActivity.backgroundBlue = rgbb?.blue == nil ? newActivity.backgroundBlue : rgbb?.blue ?? 0.0
        newActivity.backgroundGreen = rgbb?.green == nil ? newActivity.backgroundGreen : rgbb?.green ?? 0.0
        self.BEO.setColor(colorIn: Color.secondaryBackground)
        self.BEO.setFieldLineColor(colorIn: Color(red: newActivity.backgroundRed, green: newActivity.backgroundGreen, blue: newActivity.backgroundBlue))
        self.BEO.setBoardBgView(boardName: newActivity.backgroundView)
        self.activities.append(newActivity)
        self.realmIntance.safeWrite { r in
            r.create(ActivityPlan.self, value: newActivity, update: .all)
        }
    }
    
    func resetTools() {
        basicTools.removeAll()
        basicTools = []
    }
    
    // Line/Drawing
    private func saveLineData(start: CGPoint, end: CGPoint) {
        realmIntance.safeWrite { r in
            let line = ManagedView()
            line.boardId = self.BEO.currentActivityId
            line.lastUserId = getFirebaseUserId() ?? CURRENT_USER_ID
            line.startX = Double(start.x)
            line.startY = Double(start.y)
            line.endX = Double(end.x)
            line.endY = Double(end.y)
            line.x = Double(start.x)
            line.y = Double(start.y)
            line.width = 10
            line.toolColor = "Black"
            line.toolType = self.BEO.isDrawing
            line.lineDash = 1
            line.dateUpdated = Int(Date().timeIntervalSince1970)
            r.create(ManagedView.self, value: line, update: .all)
            line.fireSave(id: line.id)
        }
    }
}

