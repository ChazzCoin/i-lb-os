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
    // Filter rendered tools by the same key every creation path writes.
    @StateObject public var MVEngine: ManagedViewEngine = ManagedViewEngine(idKey: "currentActivityId")

    @State var cancellables = Set<AnyCancellable>()

    @State private var drawingStartPoint: CGPoint = .zero
    @State private var drawingEndPoint: CGPoint = .zero
    @State private var resetTools = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                 
                 // Board Tools
                MVEngine.Display(reset: self.$resetTools)

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
                // Board-sized, center-aligned: the field background must share
                // the tools' coordinate space or spawned tools miss the field.
                FieldOverlayView(width: self.BEO.boardWidth, height: self.BEO.boardHeight, background: {self.BEO.boardBgColor},
                    overlay: {
                        if let CurrentBoardBackground = self.BEO.boards.getAllBoards()[self.BEO.boardBgName] {
                            CurrentBoardBackground()
                                .zIndex(2.0)
                                .environmentObject(self.BEO)
                                // Rotate the field uniformly here so EVERY
                                // background honors rotation, not just the
                                // vector soccer views.
                                .rotationEffect(.degrees(self.BEO.boardFeildRotation))
                                .animation(.easeInOut, value: self.BEO.boardFeildRotation)
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

        .onAppear {

            print("BoardEngineView onAppear")
            self.BEO.ensureDefaultActivityPlan()
            self.BEO.loadBoardSettings()
            onSessionIdChange()
            onToolCreated()
            onToolDeleted()

        }
    }

    @MainActor
    func onSessionIdChange() {
        CodiChannel.SESSION_ON_ID_CHANGE.receive(on: RunLoop.main) { sc in
            // Payload is a String activityId or an ActivityChange wrapper.
            let newId: String
            if let s = sc as? String {
                newId = s
            } else if let ac = sc as? ActivityChange, let aId = ac.activityId {
                newId = aId
            } else {
                return
            }
            self.BEO.changeActivity(activityId: newId)
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
            // ToolListItem sends the new tool's id as a String; the legacy
            // drag toolbar sends a ManagedTool. Refresh for either.
            if tool is String || tool is ManagedTool {
                self.BEO.refreshBoard()
            }
        }.store(in: &cancellables)
    }
    

    // Line/Drawing
    private func saveLineData(start: CGPoint, end: CGPoint) {
        FusedTools.fusedCreator(ManagedView.self)  { r in
            let line = ManagedView()
            line.boardId = self.BEO.currentActivityId
            line.lastUserId = UserTools.currentUserId ?? ""
            line.startX = Double(start.x)
            line.startY = Double(start.y)
            line.endX = Double(end.x)
            line.endY = Double(end.y)
            // Curved lines render centerX/Y as the curve's control point;
            // start at the midpoint so a fresh curve begins straight.
            line.centerX = Double((start.x + end.x) / 2)
            line.centerY = Double((start.y + end.y) / 2)
            line.x = Double(start.x)
            line.y = Double(start.y)
            line.width = 10
            line.toolColor = "Black"
            // Genre routing: ViewEngine.GenreBuilder switches on
            // sport ("tool") -> toolType ("shape") -> subToolType (ShapeTool raw value).
            line.sport = ViewEngine.Tool.ShapeTool.line_straight.genre
            line.toolType = ViewEngine.Tool.ShapeTool.line_straight.type
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

