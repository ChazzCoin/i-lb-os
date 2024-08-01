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
import CoreEngine

struct BoardEngine: View {
    
    @Environment(\.scenePhase) var deviceState
    @EnvironmentObject var BEO: BoardEngineObject
    @EnvironmentObject var managedWindowsObject: NavWindowController
    @StateObject var PMO = PopupMenuObject()
    @ObservedObject public var MVEngine: ManagedViewEngine = ManagedViewEngine()

    @AppStorage("currentActivityId") var currentActivityId: String = ""
    
    @State var cancellables = Set<AnyCancellable>()

    @State private var drawingStartPoint: CGPoint = .zero
    @State private var drawingEndPoint: CGPoint = .zero
    @State private var showCreateActivitySheet = false
    @State private var resetTools = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                 
                 // Board Tools
                MVEngine.Display(reset: self.$resetTools)
                 
//                ResizableTriangle()
//                ShapeToolManaged(viewId: "quad1", activityId: "SOL", isQuad: true)
                
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
            )
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
        }
        .onChange(of: currentActivityId) {
            threeLoadActivityPlan()
        }
        .onChange(of: showCreateActivitySheet) {
            if !self.showCreateActivitySheet {
                threeLoadActivityPlan()
            }
        }
        .sheet(isPresented: $showCreateActivitySheet, content: {
            ActivityDetailsView(activityId: "new", isShowing: $showCreateActivitySheet)
        })
        .onAppear {
           
            print("BoardEngineView onAppear")
            if self.BEO.currentActivityId == "" {
                self.BEO.currentActivityId = "SOL"
                // Create Activity
                createNewActivityPlan()
            }
            
            self.threeLoadActivityPlan()
            onSessionIdChange()
            onToolCreated()
            onToolDeleted()
            
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
            if let _ = tool as? ManagedTool {
                self.resetTools = true
                self.resetTools = false
            }
        }.store(in: &cancellables)
    }
    
    func threeLoadActivityPlan() {
        self.BEO.resetTools()
        
        // LOAD SINGLE ACTIVITY
        if !self.currentActivityId.isEmpty {
                       
            if let act = self.BEO.realmInstance.findByField(ActivityPlan.self, field: "id", value: self.currentActivityId) {
                
                self.BEO.changeActivity(activityId: act.id)
                self.BEO.setColor(red: act.backgroundRed, green: act.backgroundGreen, blue: act.backgroundBlue, alpha: act.backgroundAlpha)
                self.BEO.setFieldLineColor(colorIn: Color(red: act.backgroundLineRed, green: act.backgroundLineGreen, blue: act.backgroundLineBlue).opacity(act.backgroundLineAlpha))
                self.BEO.boardBgName = act.backgroundView
                self.BEO.boardFeildRotation = act.backgroundRotation
                self.BEO.boardFeildLineStroke = act.backgroundLineStroke
                self.BEO.activities.append(act)
                
            }
            return
        }
        
        createNewActivityPlan()
        threeLoadActivityPlan()
//        showCreateActivitySheet = true
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
        if self.currentActivityId == "SOL" || self.currentActivityId.isEmpty {return}
        if let activityPlan = self.BEO.realmInstance.findByField(ActivityPlan.self, field: "id", value: self.currentActivityId) {
            if activityPlan.id == "SOL" {return}
//            activityPlan.fireSave(id: activityPlan.id)
        }
    }
    
    func takeSnapshot() {
        
        self.captureAsImage(with: self.BEO) { capturedImage in
            if let image = capturedImage {
                // Do something with the image (e.g., save it to the photo library)
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
        
    }

    func handleBoardChange(temp: ActivityChange) {
        
        // TODO: ONLY WORRY ABOUT ACTIVITY CHANGES!
        
        self.BEO.runCanvasLoading()
        
        if let newAID = temp.activityId {
            if self.currentActivityId != newAID && !newAID.isEmpty {
                self.BEO.changeActivity(activityId: newAID)
            }
        }
        
        self.threeLoadActivityPlan()
    }
    
    func createSolaOrg() {
        if let _ = self.BEO.realmInstance.findByField(Organization.self, field: "name", value: "SOL Academy") {
            return
        }
        let newOrg = Organization()
        newOrg.name = "SOL Academy"
        newOrg.descriptionText = "Private Training Academy for the Selected."
        newOrg.founded = "2024"
        newOrg.location = "Birmingham, AL"
        newOrg.memberCount = 2
        FusedTools.fusedCreator(Organization.self) { _ in
            return newOrg
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
        FusedTools.fusedCreator(Team.self) { _ in
            return newTeam
        }
        TeamManager().addUserToTeam(userId: self.BEO.currentUserId, teamId: newTeam.id) { e in
            print("Failed to Create Connection to Team.")
        }
    }
    
    func createNewActivityPlan() {
        
        if !self.BEO.realmInstance.objects(ActivityPlan.self).isEmpty {
            return
        }
        
        let newActivity = ActivityPlan()
        self.currentActivityId = newActivity.id
        self.BEO.changeActivity(activityId: newActivity.id)
        
        newActivity.title = "Auto Generated Activity"
        newActivity.subTitle = "Initial Setup for Testing"
        
        newActivity.ownerId = UserTools.currentUserId ?? ""
        newActivity.sessionId = self.BEO.currentSessionId
        
        let rgbb = Color.secondaryBackground.toRGBA()
        newActivity.backgroundRed = rgbb?.red == nil ? newActivity.backgroundRed : rgbb?.red ?? 0.0
        newActivity.backgroundBlue = rgbb?.blue == nil ? newActivity.backgroundBlue : rgbb?.blue ?? 0.0
        newActivity.backgroundGreen = rgbb?.green == nil ? newActivity.backgroundGreen : rgbb?.green ?? 0.0
        
        self.BEO.setColor(colorIn: Color.secondaryBackground)
        self.BEO.setFieldLineColor(colorIn: Color(red: newActivity.backgroundRed, green: newActivity.backgroundGreen, blue: newActivity.backgroundBlue))
        self.BEO.setBoardBgView(boardName: newActivity.backgroundView)
        self.BEO.realmInstance.safeWrite { r in
            r.create(ActivityPlan.self, value: newActivity, update: .all)
        }
        FusedTools.fusedCreator(ActivityPlan.self) { _ in
            return newActivity
        }
    }
    
    // TODO: MOVE TO CENTRAL BOARD OBJECT
    // Line/Drawing
    private func saveLineData(start: CGPoint, end: CGPoint) {
        FusedTools.fusedCreator(ManagedView.self)  { r in
            let line = ManagedView()
            line.boardId = self.currentActivityId
            line.lastUserId = UserTools.currentUserId ?? ""
            line.startX = Double(start.x)
            line.startY = Double(start.y)
            line.endX = Double(end.x)
            line.endY = Double(end.y)
            line.x = Double(start.x)
            line.y = Double(start.y)
            line.width = 10
            line.toolColor = "Black"
            line.sport = self.BEO.defaultSport
            line.toolType = ShapeToolProvider.type
            line.subToolType = self.BEO.shapeSubType
            line.lineDash = 1
            line.dateUpdated = Int(Date().timeIntervalSince1970)
//            r.create(ManagedView.self, value: line, update: .all)
//            line.fireSave(id: line.id)
            // History
            let history = ManagedViewAction()
            history.absorb(from: line)
            r.create(ManagedViewAction.self, value: history, update: .all)
            return line
        }
    }
}

