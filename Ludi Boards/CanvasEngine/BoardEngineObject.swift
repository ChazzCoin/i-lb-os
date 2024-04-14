//
//  BoardEngineObject.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/2/24.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift
import FirebaseDatabase
import CoreEngine

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
    
    @AppStorage("defaultSport") var defaultSport: String = "Soccer"
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("currentUserId") var currentUserId: String = ""
    @AppStorage("currentUserName") var currentUserName: String = ""
    @AppStorage("currentUserRole") var currentUserRole: String = ""
    @AppStorage("currentUserAuth") var currentUserAuth: String = ""
    @AppStorage("currentOrgId") var currentOrgId: String = "none"
    @AppStorage("currentOrgName") var currentOrgName: String = "none"
    @AppStorage("currentTeamId") var currentTeamId: String = "none"
    @AppStorage("currentSessionId") var currentSessionId: String = ""
    @AppStorage("currentActivityId") var currentActivityId: String = ""
    @AppStorage("currentChatId") var currentChatId: String = ""
    
    @AppStorage("isPlayingAnimation") public var isPlayingAnimation: Bool = false
    @AppStorage("toolBarCurrentViewId") public var toolBarCurrentViewId: String = ""
    @AppStorage("toolSettingsIsShowing") public var toolSettingsIsShowing: Bool = false
    @AppStorage("ignoreUpdates") public var ignoreUpdates: Bool = false
    
    let realmInstance = realm()
    let boards = Sports()
    @Published var guideModeIsEnabled = true
    @Published var boardRefreshFlag = true
    
    @Published var globalWindowsIndex = 3.0
    @Published var windowIsOpen: Bool = false
    @Published var gesturesAreLocked: Bool = false
    @Published var isShowingPopUp: Bool = false
    
    // Current User
//    @Published var isLoggedIn: Bool = true
    @Published var userId: String? = nil
    @Published var userName: String? = nil
    
    // Current Board
    @Published var showTipViewStatic: Bool = false
    @Published var isDraw: Bool = false
    @Published var shapeSubType: String = "LINE"
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
//    @Published var toolSettingsIsShowing = false
    @Published var toolBarIsShowing = false
//    @Published var toolBarCurrentViewId = ""
    
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
//    @Published var currentSessionId: String = ""
//    @Published var currentActivityId: String = ""
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
//        self.isLoggedIn = userIsVerifiedToProceed()
//        self.realmInstance.getCurrentSolUser { su in
//            self.userId = su.userId
//            self.userName = su.userName
//        }
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
//    @Published var isPlayingAnimation: Bool = false
    @Published var currentRecordingId: String = ""
    @Published var currentRecordingIndex: Int = 0
    @Published var isRecording: Bool = false
    @Published var startTime: DispatchTime?
    @Published var endTime: DispatchTime?
    @Published var recordingDuration: Double = 0.0
    @Published var recordingNotificationToken: NotificationToken? = nil
//    @Published var ignoreUpdates: Bool = false
    
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
//                firebaseDatabase(safeFlag: UserTools.userIsVerifiedToProceed()) { fdb in
//                    fdb.child(DatabasePaths.managedViews.rawValue)
//                        .child(BEO.currentActivityId)
//                        .child(newTool.id)
//                        .setValue(newTool.toDict())
//                }

                // Update the position
                updatePosition(dropLocation)
            }
        }
        return true
    }
}
