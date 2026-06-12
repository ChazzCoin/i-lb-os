//
//  CanvasMenuView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 8/7/24.
//

import Foundation
import SwiftUI
import CoreEngine


public struct CanvasMenuView: View {

    @EnvironmentObject var GPS: GlobalPositioningSystem
    @EnvironmentObject var BEO: BoardEngineObject

    public init() {}

    @AppStorage("currentActivityId") var currentActivityId: String = ""
    @State var currentSize: Double = UIScreen.main.bounds.height
    @State var CanvasMenuHeightFull: Double = UIScreen.main.bounds.height

    @State var showBoardSettings: Bool = false
    @State var showTools: Bool = true
    @State var showSize: String = "hide"

    // Tap-to-add tools spawn at the center of the board so they land in view.
    var spawnX: Double { self.BEO.boardWidth / 2 }
    var spawnY: Double { self.BEO.boardHeight / 2 }

    // Lines are created by drawing on the board (the pencil buttons), not by
    // tap-to-add — a tapped-in line would have zero length.
    let shapeTools: [ViewEngine.Tool.ShapeTool] = [.circle, .square, .triangle]

    func isDrawing(_ subType: ViewEngine.Tool.ShapeTool) -> Bool {
        return self.BEO.isDraw && self.BEO.shapeSubType == subType.rawValue
    }

    func toggleDraw(_ subType: ViewEngine.Tool.ShapeTool) {
        self.BEO.toggleDrawingMode(subType: subType.rawValue)
        if self.BEO.isDraw {
            // Drop the drawer out of the way so the board is drawable.
            withAnimation { self.showSize = "hide" }
        }
    }

    public var body: some View {

        VStack {

            HStack {

                SwitchFullHalfHide() { state in
                    if state == "full" {
                        self.currentSize = self.CanvasMenuHeightFull
                    }
                    else if state == "half" {
                        self.currentSize = self.CanvasMenuHeightFull * 0.5
                    }
                    else if state == "hide" {
                        self.currentSize = self.CanvasMenuHeightFull
                    }
                    withAnimation {
                        self.showSize = state
                    }
                }
                .padding(.leading)
                .padding(.trailing)

                // Draw: straight line
                SolIconButton(
                    systemName: "pencil",
                    width: 30.0,
                    height: 30.0,
                    fontColor: isDrawing(.line_straight) ? Color.red : Color.primary,
                    onTap: { toggleDraw(.line_straight) }
                )
                .padding(.trailing)

                // Draw: curved line
                SolIconButton(
                    systemName: "scribble",
                    width: 30.0,
                    height: 30.0,
                    fontColor: isDrawing(.line_curved) ? Color.red : Color.primary,
                    onTap: { toggleDraw(.line_curved) }
                )
                .padding(.trailing)

                SolIconButton(
                    systemName: self.BEO.gesturesAreLocked ? "lock.fill" : "lock.open",
                    width: 30.0,
                    height: 30.0,
                    fontColor: Color.red,
                    onTap: {
                        withAnimation {
                            // Draw mode owns the gesture lock; unlocking
                            // mid-draw would make one drag both draw and pan.
                            if self.BEO.isDraw {
                                self.BEO.disableDrawing()
                            } else {
                                self.BEO.gesturesAreLocked = !self.BEO.gesturesAreLocked
                            }
                        }
                    }
                )
                .padding(.trailing)

                // Zoom out / in / reset — wired to BEO.canvasScale, which the
                // canvas reads via .scaleEffect.
                SolIconButton(
                    systemName: "minus.magnifyingglass",
                    width: 30.0,
                    height: 30.0,
                    onTap: { withAnimation { self.BEO.zoomOut() } }
                )
                .padding(.trailing)

                SolIconButton(
                    systemName: "plus.magnifyingglass",
                    width: 30.0,
                    height: 30.0,
                    onTap: { withAnimation { self.BEO.zoomIn() } }
                )
                .padding(.trailing)

                SolIconButton(
                    systemName: "arrow.counterclockwise",
                    width: 30.0,
                    height: 30.0,
                    onTap: { withAnimation { self.BEO.resetZoom() } }
                )
                .padding(.trailing)

                SolIconConfirmButton(
                    systemName: "trash",
                    title: "Delete All Tools",
                    message: "Are you sure you want to delete all tools?",
                    width: 30.0,
                    height: 30.0,
                    onTap: {
                        self.BEO.deleteAllTools()
                    }
                )
                .padding(.trailing)

                // Home dashboard (sessions, activities, teams)
                SolIconButton(
                    systemName: "house",
                    width: 30.0,
                    height: 30.0,
                    onTap: {
                        BroadcastTools.send(.NavStackMessage, value: NavStackMessage(
                            navAction: .toggle,
                            viewName: MenuBarProvider.home.tool.title,
                            viewAction: .toggle
                        ))
                    }
                )
                .padding(.trailing)

                Spacer()

            }.frame(height: 50)

            ScrollView(.vertical) {
                LazyVStack {

                    CustomDisclosureGroup(isExpanded: $showBoardSettings, title: "Board Settings") {
                        BoardSettingsBar()
                    }

                    CustomDisclosureGroup(isExpanded: $showTools, title: "Tools") {
                        ToolList(title: "Shapes", forEachContent: {
                            ForEach(shapeTools, id: \.self) { tool in
                                ToolListItem(currentActivityId, tool: tool, spawnX: spawnX, spawnY: spawnY)
                            }
                        })
                        ToolList(title: "Soccer", forEachContent: {
                            ForEach(ViewEngine.Tool.SoccerTool.allCases, id: \.self) { tool in
                                ToolListItem(currentActivityId, tool: tool, spawnX: spawnX, spawnY: spawnY)
                            }
                        })
                        ToolList(title: "Billiards", forEachContent: {
                            ForEach(ViewEngine.Tool.PoolBallTool.allCases, id: \.self) { tool in
                                ToolListItem(currentActivityId, tool: tool, spawnX: spawnX, spawnY: spawnY)
                            }
                        })
                        ToolList(title: "General", forEachContent: {
                            ForEach(ViewEngine.Tool.GeneralTool.allCases, id: \.self) { tool in
                                ToolListItem(currentActivityId, tool: tool, spawnX: spawnX, spawnY: spawnY)
                            }
                        })
                    }

                    Spacer()
                }
                .padding(.bottom, 50)
            }

        }
        .frame(width: UIScreen.main.bounds.width * 0.92, height: currentSize)
        .solBackground()
        .toggleFromBelow($showSize, using: GPS, viewHeight: $currentSize, offsetY: 50)
    }
}

struct CustomDisclosureGroup<Content: View>: View {
    @Binding var isExpanded: Bool
    let title: String
    let content: Content

    init(isExpanded: Binding<Bool>, title: String, @ViewBuilder content: () -> Content) {
        self._isExpanded = isExpanded
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.primary)
                    .rotationEffect(Angle(degrees: isExpanded ? 180 : 0))
                    .animation(.easeInOut, value: isExpanded)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }

            if isExpanded {
                content
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.systemGray6))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}
