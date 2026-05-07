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
    @ObservedObject public var MVEngine: ManagedViewEngine = ManagedViewEngine()

    @AppStorage("currentBoardId") var currentBoardId: String = ""
    
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

        .sheet(isPresented: $showCreateActivitySheet, content: {
            ActivityDetailsView(activityId: "new", isShowing: $showCreateActivitySheet)
        })
        .onAppear {
           
            print("BoardEngineView onAppear")
            onSessionIdChange()
            onToolCreated()
            onToolDeleted()
            
        }
    }
    
    @MainActor
    func onSessionIdChange() {
        CodiChannel.SESSION_ON_ID_CHANGE.receive(on: RunLoop.main) { sc in
            let temp = sc as! String
            self.currentBoardId = temp
            
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
    

    // TODO: MOVE TO CENTRAL BOARD OBJECT
    // Line/Drawing
    private func saveLineData(start: CGPoint, end: CGPoint) {
        FusedTools.fusedCreator(ManagedView.self)  { r in
            let line = ManagedView()
            line.boardId = self.currentBoardId
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

            // History
            let history = ManagedViewAction()
            history.absorb(from: line)
            r.create(ManagedViewAction.self, value: history, update: .all)
            return line
        }
    }
}

