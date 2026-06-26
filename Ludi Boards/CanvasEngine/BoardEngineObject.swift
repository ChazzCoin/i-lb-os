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

public class BoardEngineObject : ObservableObject {

    @ObservedResults(SessionPlan.self) public var allSessionPlans
    @ObservedResults(ActivityPlan.self) public var allActivityPlans
    @ObservedResults(ManagedView.self) public var allTools
    @ObservedResults(ManagedViewAction.self) public var allToolActions
    
    public var currentToolActionIndex: Int?
    public var sortedFilteredActions: Results<ManagedViewAction>?

    public func setupToolActions() {
        sortedFilteredActions = allToolActions
            .filter("boardId == %@", self.currentActivityId)
            .sorted(byKeyPath: "dateCreated", ascending: false)
        resetHistoryIndex()
    }

    public func resetHistoryIndex() {
        guard let actions = sortedFilteredActions else { return }
        self.currentToolActionIndex = actions.count > 0 ? actions.count - 1 : nil
    }

    public func undoLastToolAction() {
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
    
    
    public func loadToolAction(viewId:String, actionId:String) {
        if let action = self.realmInstance.findByField(ManagedViewAction.self, value: actionId) {
            self.realmInstance.safeFindByField(ManagedView.self, value: viewId) { obj in
                obj.absorbAction(from: action, saveRealm: self.realmInstance)
            }
        }
    }
    
    @AppStorage("defaultSport") public var defaultSport: String = "Soccer"
    @AppStorage("isLoggedIn") public var isLoggedIn: Bool = false
    @AppStorage("currentUserId") public var currentUserId: String = ""
    @AppStorage("currentUserName") public var currentUserName: String = ""
    @AppStorage("currentUserRole") public var currentUserRole: String = ""
    @AppStorage("currentUserAuth") public var currentUserAuth: String = ""
    @AppStorage("currentOrgId") public var currentOrgId: String = "none"
    @AppStorage("currentOrgName") public var currentOrgName: String = "none"
    @AppStorage("currentTeamId") public var currentTeamId: String = "none"
    @AppStorage("currentSessionId") public var currentSessionId: String = ""
    @AppStorage("currentActivityId") public var currentActivityId: String = ""
    @AppStorage("currentChatId") public var currentChatId: String = ""
    
    @AppStorage("isPlayingAnimation") public var isPlayingAnimation: Bool = false
    @AppStorage("toolBarCurrentViewId") public var toolBarCurrentViewId: String = ""
    @AppStorage("toolSettingsIsShowing") public var toolSettingsIsShowing: Bool = false
    @AppStorage("ignoreUpdates") public var ignoreUpdates: Bool = false
    
    public let realmInstance = realm()
    public let boards = Sports()
    @Published public var guideModeIsEnabled = true
    @Published public var boardRefreshFlag = true
    
    @Published public var globalWindowsIndex = 3.0
    @Published public var windowIsOpen: Bool = false
    @Published public var gesturesAreLocked: Bool = false
    @Published public var isShowingPopUp: Bool = false
    
    // Current User
//    @Published var isLoggedIn: Bool = true
    @Published var userId: String? = nil
    @Published var userName: String? = nil
    
    // Current Board
    @Published var showTipViewStatic: Bool = false
    @Published var isDraw: Bool = false
    @Published var shapeSubType: String = ViewEngine.Tool.ShapeTool.line_straight.rawValue
    @Published var isLoading: Bool = true

    // Drawing mode: while drawing, canvas pan/zoom is locked so the
    // drag gesture draws lines instead of moving the board.
    func enableDrawing(subType: String = ViewEngine.Tool.ShapeTool.line_straight.rawValue) {
        shapeSubType = subType
        isDraw = true
        gesturesAreLocked = true
    }

    func disableDrawing() {
        isDraw = false
        gesturesAreLocked = false
    }

    func toggleDrawingMode(subType: String = ViewEngine.Tool.ShapeTool.line_straight.rawValue) {
        // Re-tapping the active line type exits draw mode; tapping the other
        // line type switches to it without leaving draw mode.
        if isDraw && shapeSubType == subType {
            disableDrawing()
        } else {
            enableDrawing(subType: subType)
        }
    }
    
    // Shared
    @Published var isSharedBoard = false
    @Published var isShared: Bool = false
    @Published var isHost: Bool = true
    
    // Canvas Settings
    @Published var canvasWidth: CGFloat = 8000.0
    @Published var canvasHeight: CGFloat = 8000.0
    @Published var canvasOffset = CGPoint(x: 6000, y: 6000)
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
    
    public init() {
        dropDelegate = CustomDropDelegate(
            BEO: .constant(self),
            updatePosition: { position in
                self.dropPosition = position
            }
        )
    }
    
    // Board Settings
    // Color components are 0-1 scale (what SwiftUI Color expects);
    // loadBoardSettings normalizes legacy 0-255 rows on the way in.
    // Defaults match the ActivityPlan model so the pre-load frame and a
    // freshly created default plan render identically.
    @Published var boardWidth: CGFloat = 5000.0
    @Published var boardHeight: CGFloat = 6000.0
    @Published var boardBgName: String = "Sol"
    // When set, forces the board background after `loadBoardSettings` (used by
    // the redesign board to pin the vector pitch regardless of the saved plan).
    @Published var boardBgOverride: String? = nil
    @Published var boardBgRed: Double = 0.2
    @Published var boardBgGreen: Double = 0.78
    @Published var boardBgBlue: Double = 0.34
    @Published var boardBgAlpha: Double = 0.75
    @Published var boardBgColor: Color = Color(red: 0.2, green: 0.78, blue: 0.34, opacity: 0.75)
    @Published var boardFieldLineColor: Color = Color.white
    @Published var boardFieldLineRed: Double = 1.0
    @Published var boardFieldLineGreen: Double = 1.0
    @Published var boardFieldLineBlue: Double = 1.0
    @Published var boardFieldLineAlpha: Double = 1.0
    @Published var boardFeildLineStroke: Double = 10
    @Published var boardFeildRotation: Double = 0

    // Device Config
    @Published var deviceType = UIDevice.current.userInterfaceIdiom
    func deviceIsPhone() -> Bool { return self.deviceType == .phone }
    func deviceIsPad() -> Bool { return self.deviceType == .pad }
    
    @Published var doSnapshot = false
    
    // Current Session/Activity
    @Published var basicTools: [ManagedView] = []
    @Published var lineTools: [ManagedView] = []
    
    @Published var isLiveSession: Bool = false
//    @Published var currentSessionId: String = ""
//    @Published var currentActivityId: String = ""
    func changeSession(sessionId:String) { self.currentSessionId = sessionId }
    func changeActivity(activityId:String) {
        // "nil" guards against legacy senders that stringified a missing id.
        if activityId.isEmpty || activityId == "nil" { return }
        if activityId != self.currentActivityId {
            self.currentActivityId = activityId
            self.setupToolActions()
            self.loadBoardSettings()
            // currentActivityId is @AppStorage, which does not publish from an
            // ObservableObject — fire the change so the board re-filters.
            self.objectWillChange.send()
        }
    }

    // The free build's default board: guarantee an ActivityPlan row exists
    // so board settings always have somewhere to persist.
    static let defaultBoardId = "default-board"

    func ensureDefaultActivityPlan() {
        if currentActivityId.isEmpty {
            currentActivityId = Self.defaultBoardId
        }
        if realmInstance.findByField(ActivityPlan.self, value: currentActivityId) == nil {
            realmInstance.safeWrite { r in
                let plan = ActivityPlan()
                plan.id = self.currentActivityId
                plan.title = "My Board"
                plan.backgroundRotation = 0
                r.create(ActivityPlan.self, value: plan, update: .all)
            }
        }
        // Adopt any tools created before the default board had an id.
        let orphans = realmInstance.objects(ManagedView.self).filter("boardId == %@", "")
        if !orphans.isEmpty {
            realmInstance.safeWrite { _ in
                for tool in orphans { tool.boardId = self.currentActivityId }
            }
        }
        setupToolActions()
    }

    // Apply persisted board settings to the live board. Legacy rows may
    // store 0-255 color components; normalize to SwiftUI's 0-1 scale.
    func loadBoardSettings() {
        guard let plan = realmInstance.findByField(ActivityPlan.self, value: currentActivityId) else { return }
        func norm(_ v: Double) -> Double { v > 1.0 ? v / 255.0 : v }
        boardBgRed = norm(plan.backgroundRed)
        boardBgGreen = norm(plan.backgroundGreen)
        boardBgBlue = norm(plan.backgroundBlue)
        boardBgAlpha = norm(plan.backgroundAlpha)
        boardBgColor = getColor()
        boardFieldLineRed = norm(plan.backgroundLineRed)
        boardFieldLineGreen = norm(plan.backgroundLineGreen)
        boardFieldLineBlue = norm(plan.backgroundLineBlue)
        boardFieldLineAlpha = norm(plan.backgroundLineAlpha)
        boardFieldLineColor = getFieldLineColor()
        boardFeildLineStroke = plan.backgroundLineStroke
        boardFeildRotation = plan.backgroundRotation
        if !plan.backgroundView.isEmpty {
            boardBgName = plan.backgroundView
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

    // Canvas zoom — multiplicative steps clamped to the same range as the
    // pinch gesture (CanvasEngine.scaleGestures). Touches only canvasScale,
    // so it never desyncs the pan gesture's lastOffset.
    static let minCanvasScale: CGFloat = 0.03
    static let maxCanvasScale: CGFloat = 1.5
    static let defaultCanvasScale: CGFloat = 0.1

    func zoomIn() {
        canvasScale = min(canvasScale * 1.2, Self.maxCanvasScale)
    }
    func zoomOut() {
        canvasScale = max(canvasScale / 1.2, Self.minCanvasScale)
    }
    func resetZoom() {
        canvasScale = Self.defaultCanvasScale
    }
    
    func getColor() -> Color {
        return Color(red: boardBgRed, green: boardBgGreen, blue: boardBgBlue, opacity: boardBgAlpha)
    }
    
    func getFieldLineColor() -> Color {
        return Color(red: boardFieldLineRed, green: boardFieldLineGreen, blue: boardFieldLineBlue, opacity: boardFieldLineAlpha)
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
                guard let dropped = droppedString as? String else { return }

                let newTool = ManagedView()
                // Resolve the dragged payload against the tool catalog so the
                // ViewEngine builder can route it (sport -> toolType -> subToolType).
                var catalog: [any ToolCategory] = []
                catalog += ViewEngine.Tool.ShapeTool.allCases.map { $0 as any ToolCategory }
                catalog += ViewEngine.Tool.SoccerTool.allCases.map { $0 as any ToolCategory }
                catalog += ViewEngine.Tool.PoolBallTool.allCases.map { $0 as any ToolCategory }
                catalog += ViewEngine.Tool.GeneralTool.allCases.map { $0 as any ToolCategory }
                catalog += ViewEngine.Tool.SmartTool.allCases.map { $0 as any ToolCategory }
                if let match = catalog.first(where: { $0.name == dropped }) {
                    newTool.sport = match.genre
                    newTool.toolType = match.type
                    newTool.subToolType = match.name
                } else {
                    newTool.toolType = dropped
                }
                newTool.boardId = BEO.currentActivityId
                newTool.x = dropLocation.x
                newTool.y = dropLocation.y
                // Shared factory so drag/tap/seed defaults can't drift (TASK-018).
                if newTool.toolType == "tactic" {
                    RedesignToolCatalog.configureSmartTool(newTool, center: dropLocation)
                } else if newTool.toolType == "soccer" && !newTool.subToolType.isEmpty {
                    // Match the tap-add equipment size (was left at the model default 100).
                    newTool.width = RedesignToolCatalog.equipmentSize
                    newTool.height = RedesignToolCatalog.equipmentSize
                }
                BEO.realmInstance.safeWrite { r in
                    r.create(ManagedView.self, value: newTool, update: .all)
                }

                let toolHistory = ManagedViewAction()
                toolHistory.absorb(from: newTool)
                toolHistory.isStart = true
                BEO.realmInstance.safeWrite { r in
                    r.create(ManagedViewAction.self, value: toolHistory, update: .all)
                }

                // Update the position
                updatePosition(dropLocation)
            }
        }
        return true
    }
}
