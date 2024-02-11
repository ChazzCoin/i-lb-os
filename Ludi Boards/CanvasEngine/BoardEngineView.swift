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

    @ObservedResults(SessionPlan.self) var allSessionPlans
    @ObservedResults(ActivityPlan.self) var allActivityPlans
    @ObservedResults(ManagedView.self) var allTools
    @ObservedResults(ManagedViewAction.self) var allToolActions
    var currentToolActionIndex: Int?
    var sortedFilteredActions: Results<ManagedViewAction>?

    func setupToolActions() {
        sortedFilteredActions = allToolActions
            .filter("boardId == %@", self.currentActivityId)
            .sorted(byKeyPath: "dateCreated", ascending: false)
        resetHistoryIndex()
    }

    func resetHistoryIndex() {
        guard let actions = sortedFilteredActions else { return }
        self.currentToolActionIndex = actions.count > 0 ? actions.count - 1 : nil
    }

    func undoLastToolAction() {
        guard let index = currentToolActionIndex, let actions = sortedFilteredActions, index >= 0 else {
            resetHistoryIndex()
            return
        }
        let lastAction = actions[index]
        self.realmInstance.safeFindByField(ManagedView.self, value: lastAction.viewId) { obj in
            obj.absorbAction(from: lastAction, saveRealm: self.realmInstance)
        }
        self.currentToolActionIndex = index > 0 ? index - 1 : nil
    }
    
    
    func loadToolAction(viewId:String, actionId:String) {
        if let action = self.realmInstance.findByField(ManagedViewAction.self, value: actionId) {
            self.realmInstance.safeFindByField(ManagedView.self, value: viewId) { obj in
                obj.absorbAction(from: action, saveRealm: self.realmInstance)
            }
        }
    }
    
    let realmInstance = realm()
    let boards = Sports()
    @Published var guideModeIsEnabled = true
    @Published var boardRefreshFlag = true
    
    @Published var globalWindowsIndex = 3.0
    @Published var windowIsOpen: Bool = false
    @Published var gesturesAreLocked: Bool = false
    @Published var isShowingPopUp: Bool = false
    
    // Current User
    @Published var isLoggedIn: Bool = true
    @Published var userId: String? = nil
    @Published var userName: String? = nil
    
    // Current Board
    @Published var showTipViewStatic: Bool = false
    @Published var isDraw: Bool = false
    @Published var drawType: String = "LINE"
    @Published var isLoading: Bool = true
    
    // Shared
    @Published var isSharedBoard = false
    @Published var isShared: Bool = false
    @Published var isHost: Bool = true
    
    // Canvas Settings
    @Published var canvasWidth: CGFloat = 8000.0
    @Published var canvasHeight: CGFloat = 8000.0
    @Published var canvasOffset = CGPoint.zero
    @Published var canvasScale: CGFloat = 0.1
    @Published var canvasRotation: CGFloat = 0.0
    @GestureState var gestureScale: CGFloat = 1.0
    @Published var lastScaleValue: CGFloat = 1.0
    @Published var dropPosition = CGPoint.zero
    @Published var dropDelegate: CustomDropDelegate?
    
    @Published var boardSettingsIsShowing = false
    @Published var menuSettingsIsShowing = false
    @Published var toolSettingsIsShowing = false
    @Published var toolBarIsShowing = false
    @Published var toolBarCurrentViewId = ""
    
    init() {
        dropDelegate = CustomDropDelegate(
            BEO: .constant(self),
            updatePosition: { position in
                self.dropPosition = position
            }
        )
    }
    
    // Board Settings
    @Published var boardWidth: CGFloat = 5000.0
    @Published var boardHeight: CGFloat = 6000.0
    @Published var boardStartPosX: CGFloat = 0.0
    @Published var boardStartPosY: CGFloat = 1000.0
    @Published var boardBgColor: Color = Color.secondaryBackground
    @Published var boardBgName: String = "Sol"
    @Published var boardBgRed: Double = 48.0
    @Published var boardBgGreen: Double = 128.0
    @Published var boardBgBlue: Double = 20.0
    @Published var boardBgAlpha: Double = 0.75
    @Published var boardFieldLineColor: Color = Color.white
    @Published var boardFieldLineRed: Double = 48.0
    @Published var boardFieldLineGreen: Double = 128.0
    @Published var boardFieldLineBlue: Double = 20.0
    @Published var boardFieldLineAlpha: Double = 0.75
    @Published var boardFeildLineStroke: Double = 10
    @Published var boardFeildRotation: Double = 0
    
    // Device Config
    @Published var deviceScreenBounds = UIScreen.main.bounds
    @Published var deviceType = UIDevice.current.userInterfaceIdiom
    func deviceIsPhone() -> Bool { return self.deviceType == .phone }
    func deviceIsPad() -> Bool { return self.deviceType == .pad }
    
    @Published var doSnapshot = false
    
    // Current Session/Activity
    @Published var sessions: [SessionPlan] = []
    @Published var activities: [ActivityPlan] = []
    @Published var basicTools: [ManagedView] = []
    @Published var lineTools: [ManagedView] = []
    
    @Published var isLiveSession: Bool = false
    @Published var currentSessionId: String = ""
    @Published var currentActivityId: String = ""
    func changeSession(sessionId:String) { self.currentSessionId = sessionId }
    func changeActivity(activityId:String) {
        if activityId.isEmpty { return }
        if activityId != self.currentActivityId {
            FirebaseRoomService.leaveRoom(roomId: self.currentActivityId)
            self.currentActivityId = activityId
            FirebaseRoomService.enterRoom(roomId: activityId)
            self.setupToolActions()
        }
    }
    
    func loadUser() {
        self.isLoggedIn = userIsVerifiedToProceed()
        self.realmInstance.getCurrentSolUser { su in
            self.userId = su.userId
            self.userName = su.userName
        }
    }
    
    func screenIsActiveAndLocked() -> Bool {
        return self.isRecording && self.isPlayingAnimation
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
  
    func setBoardBgView(boardName: String) { boardBgName = boardName }
    func boardBgView() -> AnyView { AnyView(SoccerFieldFullView(isMini: false)) }
    func foregroundColor() -> Color { return Color.primaryBackground }
    func backgroundColor() -> Color { return Color.secondaryBackground }
    
    func refreshBoard() {
        self.boardRefreshFlag = false
        self.boardRefreshFlag = true
    }
    
    // Managed Views/Tools
    func resetTools() {
        self.basicTools.removeAll()
        self.basicTools = []
    }
    
    func deleteAllTools() {
        let results = self.realmInstance.objects(ManagedView.self).filter("boardId == %@", self.currentActivityId)
        if results.isEmpty { return }
        for tool in results {
            self.realmInstance.safeWrite { _ in
                tool.isDeleted = true
            }
        }
        self.refreshBoard()
    }
    
    // Recording
    @ObservedResults(Recording.self) var allRecordings
    @ObservedResults(RecordingAction.self) var allRecordingActions
    var recordingsByActivityInInitialState: Results<RecordingAction> {
        return allRecordingActions
            .filter("boardId == %@ AND isInitialState == %@", self.currentActivityId, true)
    }
    var recordingsByActivity: Results<RecordingAction> {
        return allRecordingActions
            .filter("boardId == %@ AND isInitialState == %@", self.currentActivityId, false)
            .sorted(byKeyPath: "orderIndex", ascending: true)
    }
    var recordingsByRecordingIdInInitState: Results<RecordingAction> {
        return allRecordingActions
            .filter("recordingId == %@ AND isInitialState == %@", self.playbackRecordingId, true)
    }
    var recordingsByRecordingId: Results<RecordingAction> {
        return allRecordingActions
            .filter("recordingId == %@ AND isInitialState == %@", self.playbackRecordingId, false)
            .sorted(byKeyPath: "orderIndex", ascending: true)
    }
    @Published var playbackRecordingId: String = ""
    @Published var isPlayingAnimation: Bool = false
    @Published var currentRecordingId: String = ""
    @Published var currentRecordingIndex: Int = 0
    @Published var isRecording: Bool = false
    @Published var startTime: DispatchTime?
    @Published var endTime: DispatchTime?
    @Published var recordingDuration: Double = 0.0
    @Published var recordingNotificationToken: NotificationToken? = nil
    @Published var ignoreUpdates: Bool = false
    
    func playAnimationRecording() {
        isPlayingAnimation = true
        runAnimation()
    }
    func stopAnimationRecording() {
        isPlayingAnimation = false
    }
    
    private func runAnimation() {
        guard !recordingsByRecordingId.isEmpty else { return }
        let dispatchGroup = DispatchGroup()
        let initialDelay = 1.0 // Start with a delay of 1 second
        var currentDelay = initialDelay
        if !self.isPlayingAnimation { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            for item in self.recordingsByRecordingIdInInitState {
                if !self.isPlayingAnimation { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if !self.isPlayingAnimation { return }
                    dispatchGroup.enter()  // Enter the group for each async task

                    self.realmInstance.safeFindByField(ManagedView.self, value: item.toolId) { obj in
                        obj.absorbRecordingAction(from: item, saveRealm: self.realmInstance)
                        dispatchGroup.leave()  // Leave the group when the task is done
                    }
                }
                currentDelay += 1.0 // Increase the delay for the next task
            }
            
            // Notify when all tasks in the first loop are done
            if !self.isPlayingAnimation { return }
            dispatchGroup.notify(queue: .main) {
                var nextDelay = initialDelay

                // Now start the second loop
                var count = 0
                var total = self.recordingsByRecordingId.count
                for item in self.recordingsByRecordingId {
                    if !self.isPlayingAnimation { return }
                    if item.orderIndex == 0 { continue }
                    count = count + 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + nextDelay) {
                        if !self.isPlayingAnimation { return }
                        self.realmInstance.safeFindByField(ManagedView.self, value: item.toolId) { obj in
                            obj.absorbRecordingAction(from: item, saveRealm: self.realmInstance)
                        }
                        
                        if count >= total {
                            DispatchQueue.main.asyncAfter(deadline: .now() + nextDelay + 3.0) {
                                self.isPlayingAnimation = false
                            }
                        }
                    }
                    nextDelay += 1.0 // Increase the delay for the next task
                }
                
            }
            
        }
        
    }


    func startRecording() {
        print("Starting Recording")
        let newRecording = Recording()
        self.currentRecordingId = newRecording.id
        newRecording.boardId = self.currentActivityId
        
        self.realmInstance.safeWrite { r in
            r.create(Recording.self, value: newRecording, update: .all)
            // TODO: FIREBASE
        }
        
        isRecording = true
        startTimer()
        startRecordingObserver()
        print("Recording Started.")
    }
    
    func stopRecording() {
        print("Stopping Recording")
        isRecording = false
        stopTimer()
        stopRecordingObserver()
        print("Recording Stopped.")
    }
    
    private func startTimer() { startTime = DispatchTime.now() }
    private func stopTimer() {
        guard let startTime = startTime else { return }
        endTime = DispatchTime.now()
        guard let endTime = endTime else { return }
        self.recordingDuration = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000 // Convert to seconds
        print("Recording duration: \(self.recordingDuration) seconds.")
        if let obj = self.realmInstance.findByField(Recording.self, value: self.currentRecordingId) {
            self.realmInstance.safeWrite { _ in
                obj.duration = self.recordingDuration
                // TODO: FIREBASE
            }
        }
    }
    
    private func stopRecordingObserver() {
        self.recordingNotificationToken?.invalidate()
        self.recordingNotificationToken = nil
    }
    
    private func startRecordingObserver() {
        if self.currentActivityId.isEmpty { return }
        // Realm
        let umvs = self.realmInstance.findAllByField(ManagedView.self, field: "boardId", value: self.currentActivityId)
        
        self.realmInstance.executeWithRetry {
            print("Starting Recording Listener")
            self.recordingNotificationToken = umvs?.observe { (changes: RealmCollectionChange) in
                DispatchQueue.main.async {
                    switch changes {
                        case .initial(let results):
                            print("Recording Listener: initial")
                            for i in results {
                                if i.isInvalidated {continue}
                                // Initial State
                                let newAction = RecordingAction()
                                newAction.recordingId = self.currentRecordingId
                                newAction.isInitialState = true
                                newAction.absorb(from: i)
                                self.realmInstance.safeWrite { r in
                                    r.create(RecordingAction.self, value: newAction, update: .all)
                                }
                            }
                        case .update(let results, _, _, let modifications):
                            if self.ignoreUpdates { return }
                            print("Recording Listener: update")
                            for index in modifications {
                                let modifiedObject = results[index]
                                self.currentRecordingIndex = self.currentRecordingIndex + 1
                                print("NEW ACTION: \(modifiedObject): \(self.currentRecordingIndex)")
                                let newAction = RecordingAction()
                                newAction.recordingId = self.currentRecordingId
                                newAction.isInitialState = false
                                newAction.orderIndex = self.currentRecordingIndex
                                newAction.absorb(from: modifiedObject)
                                self.realmInstance.safeWrite { r in
                                    r.create(RecordingAction.self, value: newAction, update: .all)
                                }
                            }
                        case .error(let error):
                            print("Recording Listener: \(error)")
                            self.recordingNotificationToken?.invalidate()
                            self.recordingNotificationToken = nil
                    }
                }
                
            }
        }
    }
    
}

struct CustomDropDelegate: DropDelegate {
    @Binding var BEO: BoardEngineObject // Replace with your actual type
    @State var updatePosition: (CGPoint) -> Void

    func performDrop(info: DropInfo) -> Bool {
        let dropLocation = info.location
        
        // Handle the drop and get the dropped content
        guard let itemProvider = info.itemProviders(for: [.text]).first else {
            return false
        }
        itemProvider.loadObject(ofClass: NSString.self) { (droppedString, error) in
            DispatchQueue.main.async {
                let newTool = ManagedView()
                newTool.toolType = droppedString as! String
                newTool.boardId = BEO.currentActivityId
                newTool.x = dropLocation.x
                newTool.y = dropLocation.y
                BEO.realmInstance.safeWrite { r in
                    r.create(ManagedView.self, value: newTool, update: .all)
                }
                
                let toolHistory = ManagedViewAction()
                toolHistory.absorb(from: newTool)
                toolHistory.isStart = true
                BEO.realmInstance.safeWrite { r in
                    r.create(ManagedViewAction.self, value: toolHistory, update: .all)
                }
                
                // TODO: Firebase Users ONLY
                firebaseDatabase(safeFlag: userIsVerifiedToProceed()) { fdb in
                    fdb.child(DatabasePaths.managedViews.rawValue)
                        .child(BEO.currentActivityId)
                        .child(newTool.id)
                        .setValue(newTool.toDict())
                }

                // Update the position
                updatePosition(dropLocation)
            }
        }
        return true
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
                self.BEO.sessions.append(i)
            }
        }
        // TWO
        twoLoadSessionPlan()
    }
    
    func twoLoadSessionPlan() {
        
        //TODO: GET ALL SESSIONS && SHARED SESSIONS
        fireGetLiveDemoAsync(realm: self.BEO.realmInstance)
        FirebaseSessionPlanService.runFullFetchProcess(realm: self.BEO.realmInstance)
        
        if let obj = self.BEO.realmInstance.findByField(SessionPlan.self, field: "id", value: self.BEO.currentSessionId) {
            self.BEO.changeSession(sessionId: self.BEO.currentSessionId)
            self.BEO.isLiveSession = obj.isLive
            self.sessionObserver.stop()
            self.sessionObserver.observe(object: obj, onChange: { newObj in
                self.BEO.isLiveSession = newObj.isLive
            })
            // THREE
            threeLoadActivityPlan()
        }
    }
    
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
        
        // LOAD ALL ACTIVITIES
        if let acts = self.BEO.realmInstance.findAllByField(ActivityPlan.self, field: "sessionId", value: self.BEO.currentSessionId) {
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
                    self.BEO.activities.append(i)
                }
                fourLoadManagedViewTools()
                return
            }
        }
        
        createNewActivityPlan()
        fourLoadManagedViewTools()
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
        if self.BEO.currentSessionId == "SOL" || self.BEO.currentSessionId.isEmpty {return}
        if let sessionPlan = self.BEO.realmInstance.findByField(SessionPlan.self, field: "id", value: self.BEO.currentSessionId) {
            if sessionPlan.id == "SOL" {return}
            sessionPlan.fireSave(id: sessionPlan.id)
        }
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
        
        let results = self.BEO.realmInstance.objects(SessionPlan.self)
        if !results.isEmpty {
            if let temp = results.first {
                self.BEO.changeSession(sessionId: temp.id)
                return
            }
        }
        
        self.BEO.realmInstance.safeWrite { r in
            let newSession = SessionPlan()
            newSession.title = "Session: \(TimeProvider.getMonthDayYearTime())"
            newSession.ownerId = getFirebaseUserId() ?? CURRENT_USER_ID
            self.BEO.changeSession(sessionId: newSession.id)
            r.add(newSession)
        }
    }
    
    func createNewActivityPlan() {
        
        let results = self.BEO.realmInstance.objects(ActivityPlan.self).filter("sessionId == %@", self.BEO.currentSessionId)
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

