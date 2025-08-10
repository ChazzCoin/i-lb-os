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
                
                PoolBallManagedView(viewId: "test", activityId: self.BEO.currentActivityId, ballType: .eightBall)
                
                PoolBallManagedView(viewId: "test1", activityId: self.BEO.currentActivityId, ballType: .solid1)
                PoolBallManagedView(viewId: "test2", activityId: self.BEO.currentActivityId, ballType: .stripe9)
                
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
                FieldOverlayView(width: self.BEO.canvasWidth, height: self.BEO.canvasHeight, background: {self.BEO.boardBgColor},
                    overlay: {
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
            let temp = sc as! String
            self.currentActivityId = temp
            threeLoadActivityPlan()
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
        self.resetTools = true
        self.resetTools = false
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

