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

            #if DEBUG
            print("BoardEngineView onAppear")
            #endif
            self.BEO.ensureDefaultActivityPlan()
            self.BEO.loadBoardSettings()
            // RD-2 / TASK-003: DEBUG hook to preview a registry board background
            // headlessly (e.g. REDESIGN_BG="Soccer Redesign Full View"). No-op
            // in release and when unset.
            #if DEBUG
            if let bg = ProcessInfo.processInfo.environment["REDESIGN_BG"], !bg.isEmpty {
                self.BEO.boardBgName = bg
            }
            #endif
            // RD-2 / TASK-013: the redesign board pins its background via an
            // override applied AFTER the saved plan loads (parent onAppear runs
            // before this, so a direct set would be overwritten here).
            if let override = self.BEO.boardBgOverride, !override.isEmpty {
                self.BEO.boardBgName = override
            }
            #if DEBUG
            seedRedesignToolsIfRequested()
            seedSmartToolsIfRequested()
            #endif
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
    

    #if DEBUG
    // RD-5 / TASK-011: seed a board roster (home + away) once.
    private func seedRosterIfNeeded(boardId: String) {
        guard self.BEO.realmInstance.objects(RosterPlayer.self).filter("boardId == %@", boardId).isEmpty
        else { return }
        let roster: [(Int, String, String, String)] = [
            (9, "M. Reed", "ST", "home"), (7, "L. Okafor", "RW", "home"),
            (8, "D. Silva", "CM", "home"), (1, "A. Stone", "GK", "home"),
            (10, "J. Vidal", "AM", "home"),
            (4, "T. Bauer", "CB", "away"), (6, "N. Costa", "DM", "away"),
        ]
        self.BEO.realmInstance.safeWrite { r in
            for (i, p) in roster.enumerated() {
                let rp = RosterPlayer()
                rp.boardId = boardId; rp.number = p.0; rp.name = p.1
                rp.position = p.2; rp.teamSide = p.3; rp.orderIndex = i
                r.create(RosterPlayer.self, value: rp, update: .all)
            }
        }
    }

    // Smart Tools: seed a grid of every tactical tool to verify the render path
    // (REDESIGN_SMART=1). Independent of REDESIGN_SEED. Idempotent per board.
    private func seedSmartToolsIfRequested() {
        guard ProcessInfo.processInfo.environment["REDESIGN_SMART"] == "1" else { return }
        let boardId = self.BEO.currentActivityId
        guard self.BEO.realmInstance.objects(ManagedView.self)
            .filter("boardId == %@ AND toolType == %@", boardId, "tactic").isEmpty else { return }
        let subs = ["tactic_pass_arrow", "tactic_run_arrow", "tactic_dribble_arrow",
                    "tactic_curve_arrow", "tactic_overlap_run", "tactic_zone_rect",
                    "tactic_distance_tool", "tactic_offside_line", "tactic_angle_tool",
                    "tactic_spotlight", "tactic_focus_ring", "tactic_agility_ladder",
                    "tactic_stat_badge"]
        self.BEO.realmInstance.safeWrite { r in
            for (i, sub) in subs.enumerated() {
                let col = i % 4, row = i / 4
                let cx = 1400.0 + Double(col) * 1050.0
                let cy = 1600.0 + Double(row) * 1250.0
                // Shared factory (TASK-018) so the seed can't drift from the live paths.
                let mv = RedesignToolCatalog.makeSmartTool(sub, boardId: boardId, center: CGPoint(x: cx, y: cy))
                r.create(ManagedView.self, value: mv, update: .all)
            }
        }
        self.BEO.refreshBoard()
        // Verify smart-tool selection → Properties headlessly (TASK-015/016).
        if ProcessInfo.processInfo.environment["REDESIGN_SMART_SELECT"] == "1",
           let first = self.BEO.realmInstance.objects(ManagedView.self)
               .filter("boardId == %@ AND toolType == %@", boardId, "tactic").first {
            UserDefaults.standard.set(first.id, forKey: "selectedManagedViewId")
        }
    }

    // RD-2 / TASK-013: seed a few real soccer-jersey ManagedView tools so the
    // engine-connected redesign board has something to render/select before the
    // rail/library create tools (TASK-006/010). Idempotent per board.
    private func seedRedesignToolsIfRequested() {
        guard ProcessInfo.processInfo.environment["REDESIGN_SEED"] == "1" else { return }
        let boardId = self.BEO.currentActivityId
        let existing = self.BEO.realmInstance.objects(ManagedView.self)
            .filter("boardId == %@ AND toolType == %@", boardId, "soccer")
        if existing.isEmpty {
            // RD-5: seed a real roster and place a few players linked to it, so
            // the discs show real numbers and the Squad panel has data.
            seedRosterIfNeeded(boardId: boardId)
            // (number, name, side, x, y)
            let lineup: [(Int, String, String, Double, Double)] = [
                (9, "M. Reed",   "home", 1900, 2300),
                (7, "L. Okafor", "home", 2500, 2300),
                (8, "D. Silva",  "home", 3100, 2300),
                (4, "T. Bauer",  "away", 2200, 2950),
                (6, "N. Costa",  "away", 2800, 2950),
                (10, "J. Vidal", "home", 2500, 3500),
            ]
            self.BEO.realmInstance.safeWrite { r in
                for p in lineup {
                    let player = self.BEO.realmInstance.objects(RosterPlayer.self)
                        .filter("boardId == %@ AND number == %d AND teamSide == %@", boardId, p.0, p.2).first
                    let mv = ManagedView()
                    mv.boardId = boardId
                    mv.sport = "tool"
                    mv.toolType = "soccer"
                    mv.subToolType = "tools_soccer_jersey"
                    mv.x = p.3; mv.y = p.4
                    mv.width = 200; mv.height = 200
                    mv.jerseyNumber = p.0
                    mv.teamSide = p.2
                    mv.playerId = player?.id ?? ""
                    mv.dateUpdated = Int(Date().timeIntervalSince1970)
                    r.create(ManagedView.self, value: mv, update: .all)
                }
                // A lime "run" (solid) and a dashed "build-up" (curved) to verify
                // the redesign line styling (TASK-005).
                func lime(_ mv: ManagedView) {
                    mv.boardId = boardId; mv.sport = "tool"; mv.toolType = "shape"
                    mv.width = 34; mv.toolColor = "Lime"
                    mv.colorRed = 0.796; mv.colorGreen = 0.859; mv.colorBlue = 0.165; mv.colorAlpha = 1.0
                    mv.dateUpdated = Int(Date().timeIntervalSince1970)
                }
                let run = ManagedView()
                lime(run); run.subToolType = "line_straight"; run.lineDash = 1
                run.startX = 2500; run.startY = 2950; run.endX = 3400; run.endY = 2950
                run.x = 2500; run.y = 2950; run.centerX = 2950; run.centerY = 2950
                r.create(ManagedView.self, value: run, update: .all)
                let build = ManagedView()
                lime(build); build.subToolType = "line_curved"; build.lineDash = 10
                build.startX = 1500; build.startY = 2950; build.endX = 2300; build.endY = 2950
                build.x = 1500; build.y = 2950; build.centerX = 1900; build.centerY = 2650
                r.create(ManagedView.self, value: build, update: .all)
            }
            self.BEO.refreshBoard()
        }
        // Verify the selection bridge headlessly: select the first soccer tool
        // (mimics a tap), which should open the Properties panel.
        if ProcessInfo.processInfo.environment["REDESIGN_SELECT"] == "1",
           let first = self.BEO.realmInstance.objects(ManagedView.self)
               .filter("boardId == %@ AND toolType == %@", boardId, "soccer").first {
            UserDefaults.standard.set(first.id, forKey: "selectedManagedViewId")
        }
        // Verify the Library add-tool path headlessly (TASK-010): create the
        // mapped equipment tool, as a library tap/drag would.
        if let add = ProcessInfo.processInfo.environment["REDESIGN_LIBADD"],
           let sub = RedesignToolCatalog.equipmentSubtype[add] {
            self.BEO.realmInstance.safeWrite { r in
                let mv = ManagedView()
                mv.boardId = boardId
                mv.sport = "tool"; mv.toolType = "soccer"; mv.subToolType = sub
                mv.x = 3300; mv.y = 2400; mv.width = 240; mv.height = 240
                mv.dateUpdated = Int(Date().timeIntervalSince1970)
                r.create(ManagedView.self, value: mv, update: .all)
            }
            self.BEO.refreshBoard()
        }
    }
    #endif

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
            // Redesign run: lime, thick enough to read at the ~0.1 canvas scale.
            line.width = 34
            line.toolColor = "Lime"
            line.colorRed = 0.796   // #CBDB2A brand lime
            line.colorGreen = 0.859
            line.colorBlue = 0.165
            line.colorAlpha = 1.0
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

