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
    
    // TODO: -> Move to Central Board Object
    @State private var reference: DatabaseReference = Database.database().reference()
    @State private var observerHandleOne: DatabaseHandle?
    @State private var observerHandleTwo: DatabaseHandle?
    @State private var observerHandleThree: DatabaseHandle?
    @State private var sessionNotificationToken: NotificationToken? = nil
    @State private var activityNotificationToken: NotificationToken? = nil
    @State private var managedViewNotificationToken: NotificationToken? = nil
    
    @State private var drawingStartPoint: CGPoint = .zero
    @State private var drawingEndPoint: CGPoint = .zero
    @State private var currentSessionWasLoaded = false
    
    @State private var showCreateActivitySheet = false
    
    var body: some View {
         ZStack() {
             
             // Board Tools
             if self.BEO.boardRefreshFlag {
                 ForEach(self.BEO.basicTools) { item in
                     if !item.isDeleted {
                         
                         // Main Tool Management Functionality
                         ManagedViewToolFactory(toolType: item.toolType, viewId: item.id, activityId: item.boardId)
                             .zIndex(20.0)
                             .environmentObject(self.BEO)
                         
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
        .modifier(SnapshotViewModifier(takeSnapshot: self.$BEO.doSnapshot) { image in
            // Do something with the image, like saving it to the photo album
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        })
        .onDrop(of: [.text], delegate: self.BEO.dropDelegate!)
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
        .onChange(of: self.BEO.doSnapshot) { snap in
            if self.BEO.doSnapshot {
                takeSnapshot()
            }
        }
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
        .onChange(of: showCreateActivitySheet) { value in
            if !self.showCreateActivitySheet {
                threeLoadActivityPlan()
            }
        }
        .sheet(isPresented: $showCreateActivitySheet, content: {
            ActivityDetailsView(activityId: "new", isShowing: $showCreateActivitySheet)
        })
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
            
            SPS = SessionPlanService(realm: self.BEO.realmInstance)
            APS = ActivityPlanService(realm: self.BEO.realmInstance)
            MVS = AllManagedViewsService(realm: self.BEO.realmInstance)
            
            self.threeLoadActivityPlan()
            
            onSessionIdChange()
            onToolCreated()
            onToolDeleted()
            
            // todo: TESTING ONLY
            createSolaOrg()
            createSolaTeam()
        }
    }
    
    @MainActor
    func onSessionIdChange() {
        CodiChannel.SESSION_ON_ID_CHANGE.receive(on: RunLoop.main) { sc in
            let temp = sc as! ActivityChange
            handleBoardChange(temp: temp)
        }.store(in: &cancellables)
    }
    
    @MainActor
    func onToolDeleted() {
        CodiChannel.TOOL_ON_DELETE.receive(on: RunLoop.main) { viewId in
            self.BEO.refreshBoard()
        }.store(in: &cancellables)
    }
    
    @MainActor
    func onToolCreated() {
        CodiChannel.TOOL_ON_CREATE.receive(on: RunLoop.main) { tool in
            let newTool = ManagedView()
            newTool.toolType = tool as! String
            newTool.boardId = self.BEO.currentActivityId
            newTool.x = 0.0
            newTool.y = 0.0
            self.BEO.realmInstance.safeWrite { r in
                r.create(ManagedView.self, value: newTool, update: .all)
            }
            createHistoricalSnapShotAtStart(tool: newTool)
            if userIsVerifiedToProceed() {
                newTool.fireSave(parentId: self.BEO.currentActivityId, id: newTool.id)
            }
            
        }.store(in: &cancellables)
    }
    
//    func oneLoadAllSessionPlans() {
//        
//        if self.currentSessionWasLoaded {
//            // TWO
//            twoLoadSessionPlan()
//            return
//        }
//        
//        if self.BEO.allSessionPlans.isEmpty {
//            createNewSessionPlan()
//        } else {
//            let temp = self.BEO.allSessionPlans.first
//            if temp?.id != nil && !temp!.id.isEmpty {
//                self.BEO.changeSession(sessionId: temp?.id ?? "SOL")
//            }
//            for i in self.BEO.allSessionPlans {
//                self.BEO.sessions.append(i)
//            }
//        }
//        // TWO
//        twoLoadSessionPlan()
//    }
    
//    func twoLoadSessionPlan() {
//        
//        //TODO: GET ALL SESSIONS && SHARED SESSIONS
//        fireGetLiveDemoAsync(realm: self.BEO.realmInstance)
//        FirebaseSessionPlanService.runFullFetchProcess(realm: self.BEO.realmInstance)
//        
//        if let obj = self.BEO.realmInstance.findByField(SessionPlan.self, field: "id", value: self.BEO.currentSessionId) {
//            self.BEO.changeSession(sessionId: self.BEO.currentSessionId)
//            self.BEO.isLiveSession = obj.isLive
//            self.sessionObserver.stop()
//            self.sessionObserver.observe(object: obj, onChange: { newObj in
//                self.BEO.isLiveSession = newObj.isLive
//            })
//            // THREE
//            threeLoadActivityPlan()
//        }
//    }
    
    func threeLoadActivityPlan() {
        self.BEO.resetTools()
        
        // LOAD SINGLE ACTIVITY
        if !self.BEO.currentActivityId.isEmpty {
                       
            if let act = self.BEO.realmInstance.findByField(ActivityPlan.self, field: "id", value: self.BEO.currentActivityId) {
                
                self.BEO.changeActivity(activityId: act.id)
                self.BEO.setColor(red: act.backgroundRed, green: act.backgroundGreen, blue: act.backgroundBlue, alpha: act.backgroundAlpha)
                self.BEO.setFieldLineColor(colorIn: Color(red: act.backgroundLineRed, green: act.backgroundLineGreen, blue: act.backgroundLineBlue).opacity(act.backgroundLineAlpha))
                self.BEO.boardBgName = act.backgroundView
                self.BEO.boardFeildRotation = act.backgroundRotation
                self.BEO.boardFeildLineStroke = act.backgroundLineStroke
                self.BEO.activities.append(act)
                
                // Realm
                self.activityObserver.observe(object: act, onChange: { temp in
                    self.BEO.setColor(red: temp.backgroundRed, green: temp.backgroundGreen, blue: temp.backgroundBlue, alpha: temp.backgroundAlpha)
                    self.BEO.setFieldLineColor(colorIn: Color(red: temp.backgroundLineRed, green: temp.backgroundLineGreen, blue: temp.backgroundLineBlue).opacity(temp.backgroundLineAlpha))
                    self.BEO.boardBgName = temp.backgroundView
                    self.BEO.boardFeildRotation = temp.backgroundRotation
                    self.BEO.boardFeildLineStroke = temp.backgroundLineStroke
                })
                
                // Firebase
                if self.BEO.isLiveSession {
                    APS?.startObserving(activityId: self.BEO.currentActivityId)
                } else {
                    APS?.stopObserving()
                }
                
            }
            fourLoadManagedViewTools()
            return
        }
        
        createNewActivityPlan()

        threeLoadActivityPlan()
//        showCreateActivitySheet = true

    }
    
    // TODO: MOVE TO CENTRAL BOARD OBJECT
    func fourLoadManagedViewTools() {
        if self.BEO.currentActivityId.isEmpty { return }
        // Realm
        let umvs = self.BEO.realmInstance.findAllByField(ManagedView.self, field: "boardId", value: self.BEO.currentActivityId)
        
        self.BEO.realmInstance.executeWithRetry {
            self.managedViewNotificationToken = umvs?.observe { (changes: RealmCollectionChange) in
                DispatchQueue.main.async {
                    switch changes {
                        case .initial(let results):
                            print("Realm Listener: initial")
                            for i in results {
                                if i.isInvalidated {continue}
                                self.BEO.basicTools.safeAddManagedView(i)
                            }
                        case .update(let results, let de, _, _):
                            print("Realm Listener: update")
                            
                            for d in de {
                                self.BEO.basicTools.remove(at: d)
                            }
                            
                            for i in results {
                                if i.isInvalidated {continue}
                                self.BEO.basicTools.safeAddManagedView(i)
                            }
                        case .error(let error):
                            print("Realm Listener: \(error)")
                            self.managedViewNotificationToken?.invalidate()
                            self.managedViewNotificationToken = nil
                    }
                }
            }
        }
        
        fiveStartObservingManagedViews()
        sixSavePlansToFirebase()
    }
    
    // TODO: MOVE TO CENTRAL BOARD OBJECT
    func fiveStartObservingManagedViews() {
        if self.BEO.currentActivityId.isEmpty { return }
        if !BEO.isLoggedIn { return }
        observerHandleOne = reference
            .child(DatabasePaths.managedViews.rawValue)
            .child(self.BEO.currentActivityId)
            .observe(.childAdded, with: { snapshot in
                if let temp = snapshot.value as? [String:Any] {
                    let mv = ManagedView(dictionary: temp)
                    if self.BEO.basicTools.hasView(mv) {
                        return
                    }
                    self.BEO.realmInstance.safeWrite { r in
                        r.create(ManagedView.self, value: mv, update: .all)
                    }
//                    createHistoricalSnapShotAtStart(tool: mv)
                    self.BEO.basicTools.safeAddManagedView(mv)
                }
            })
        
        observerHandleTwo = reference
            .child(DatabasePaths.managedViews.rawValue)
            .child(self.BEO.currentActivityId)
            .observe(.childRemoved, with: { snapshot in
                let temp = snapshot.toHashMap()
                if let tempId = temp["id"] as? String {
                    self.BEO.basicTools.safeRemoveById(tempId)
                }
            })
    }
    
    func createHistoricalSnapShotAtStart(tool: ManagedView) {
        let toolHistory = ManagedViewAction()
        toolHistory.absorb(from: tool)
        toolHistory.isStart = true
        BEO.realmInstance.safeWrite { r in
            r.create(ManagedViewAction.self, value: toolHistory, update: .all)
        }
    }
    
    // TODO: MOVE TO CENTRAL BOARD OBJECT
    func sixSavePlansToFirebase() {
        if !self.BEO.isLoggedIn { return }
//        if self.BEO.currentSessionId == "SOL" || self.BEO.currentSessionId.isEmpty {return}
//        if let sessionPlan = self.BEO.realmInstance.findByField(SessionPlan.self, field: "id", value: self.BEO.currentSessionId) {
//            if sessionPlan.id == "SOL" {return}
//            sessionPlan.fireSave(id: sessionPlan.id)
//        }
        if self.BEO.currentActivityId == "SOL" || self.BEO.currentActivityId.isEmpty {return}
        if let activityPlan = self.BEO.realmInstance.findByField(ActivityPlan.self, field: "id", value: self.BEO.currentActivityId) {
            if activityPlan.id == "SOL" {return}
            activityPlan.fireSave(id: activityPlan.id)
        }
    }
    
    func takeSnapshot() {
        
        self.captureAsImage(with: self.BEO) { capturedImage in
            if let image = capturedImage {
                // Do something with the image (e.g., save it to the photo library)
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
        
//        if let image = snapshot(with: self.BEO) { // A4 size
//            if let pdfData = createPDF(image: image, pageSize: CGSize(width: 595, height: 842)) {
////                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
////                let pdfPath = documentsPath.appendingPathComponent("yourView.pdf")
//                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//                let pdfPath = documentsPath.appendingPathComponent("yourView.pdf")
//                
//                do {
//                    try pdfData.write(to: pdfPath)
//                    print("PDF file saved to: \(pdfPath)")
//                } catch {
//                    print("Could not save PDF: \(error)")
//                }
//            }
//            
//            
//        }
    }
    
    // TODO: MOVE TO CENTRAL BOARD OBJECT
    func stopObserving() {
        guard let handleOne = observerHandleOne, let handleTwo = observerHandleTwo else { return }
        reference.removeObserver(withHandle: handleOne)
        reference.removeObserver(withHandle: handleTwo)
        observerHandleOne = nil
        observerHandleTwo = nil
    }
    
    func handleBoardChange(temp: ActivityChange) {
        
        // TODO: ONLY WORRY ABOUT ACTIVITY CHANGES!
        
        self.BEO.runCanvasLoading()
        APS?.stopObserving()
        MVS?.stopObserving()
        stopObserving()
        
        if let newAID = temp.activityId {
            if self.BEO.currentActivityId != newAID && !newAID.isEmpty {
                self.BEO.changeActivity(activityId: newAID)
            }
        }
        
        self.threeLoadActivityPlan()
    }
    
//    func createNewSessionPlan() {
//        
//        let results = self.BEO.realmInstance.objects(SessionPlan.self)
//        if !results.isEmpty {
//            if let temp = results.first {
//                self.BEO.changeSession(sessionId: temp.id)
//                return
//            }
//        }
//        
//        self.BEO.realmInstance.safeWrite { r in
//            let newSession = SessionPlan()
//            newSession.title = "Session: \(TimeProvider.getMonthDayYearTime())"
//            newSession.ownerId = getFirebaseUserId() ?? CURRENT_USER_ID
//            self.BEO.changeSession(sessionId: newSession.id)
//            r.add(newSession)
//        }
//    }
    
    func createSolaOrg() {
        if let _ = self.BEO.realmInstance.findByField(Organization.self, field: "name", value: "SOL Academy") {
            return
        }
        let newOrg = Organization()
        newOrg.name = "SOL Academy"
        newOrg.descriptionText = "Private Training Academy for the Selected."
        newOrg.founded = "2024"
        newOrg.location = "Birmingham, AL"
        newOrg.members = 2
        self.BEO.realmInstance.safeWrite { r in
            r.create(Organization.self, value: newOrg, update: .all)
        }
        
        OrganizationManager(realm: self.BEO.realmInstance).addUserToOrganization(userId: self.BEO.currentUserId, organizationId: newOrg.id) {
            print("Failed to Create Connection to Organization.")
        }
    }
    
    func createSolaTeam() {
        if let _ = self.BEO.realmInstance.findByField(Team.self, field: "name", value: "SOLA") {
            return
        }
        let newTeam = Team()
        newTeam.name = "SOLA"
        newTeam.coachName = "Selim T."
        newTeam.sportType = "Soccer"
        newTeam.foundedYear = "2024"
        newTeam.homeCity = "Birmingham, AL"
        newTeam.league = "Private Training"
        newTeam.manager = "Charles Romeo"
        self.BEO.realmInstance.safeWrite { r in
            r.create(Team.self, value: newTeam, update: .all)
        }
        TeamManager().addUserToTeam(userId: self.BEO.currentUserId, teamId: newTeam.id) { e in
            print("Failed to Create Connection to Team.")
        }
    }
    
    func createNewActivityPlan() {
        
        let newActivity = ActivityPlan()
        self.BEO.changeActivity(activityId: newActivity.id)
        
        newActivity.title = "Auto Generated Activity"
        newActivity.subTitle = "Initial Setup for Testing"
        
        newActivity.ownerId = getFirebaseUserId() ?? CURRENT_USER_ID
        newActivity.sessionId = self.BEO.currentSessionId
        
        let rgbb = Color.secondaryBackground.toRGBA()
        newActivity.backgroundRed = rgbb?.red == nil ? newActivity.backgroundRed : rgbb?.red ?? 0.0
        newActivity.backgroundBlue = rgbb?.blue == nil ? newActivity.backgroundBlue : rgbb?.blue ?? 0.0
        newActivity.backgroundGreen = rgbb?.green == nil ? newActivity.backgroundGreen : rgbb?.green ?? 0.0
        
        self.BEO.setColor(colorIn: Color.secondaryBackground)
        
        self.BEO.setFieldLineColor(colorIn: Color(red: newActivity.backgroundRed, green: newActivity.backgroundGreen, blue: newActivity.backgroundBlue))
        
        self.BEO.setBoardBgView(boardName: newActivity.backgroundView)
        
        self.BEO.activities.append(newActivity)
        
        self.BEO.realmInstance.safeWrite { r in
            r.create(ActivityPlan.self, value: newActivity, update: .all)
        }
    }
    
    // TODO: MOVE TO CENTRAL BOARD OBJECT
    // Line/Drawing
    private func saveLineData(start: CGPoint, end: CGPoint) {
        self.BEO.realmInstance.safeWrite { r in
            let line = ManagedView()
            line.boardId = self.BEO.currentActivityId
            line.lastUserId = getFirebaseUserIdOrCurrentLocalId()
            line.startX = Double(start.x)
            line.startY = Double(start.y)
            line.endX = Double(end.x)
            line.endY = Double(end.y)
            line.x = Double(start.x)
            line.y = Double(start.y)
            line.width = 10
            line.toolColor = "Black"
            line.toolType = self.BEO.drawType
            line.lineDash = 1
            line.dateUpdated = Int(Date().timeIntervalSince1970)
            r.create(ManagedView.self, value: line, update: .all)
            line.fireSave(id: line.id)
            // History
            let history = ManagedViewAction()
            history.absorb(from: line)
            r.create(ManagedViewAction.self, value: history, update: .all)
        }
    }
}

