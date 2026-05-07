//
//  CanvasMenuView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 8/7/24.
//

import Foundation
import SwiftUI



public struct CoreCanvasMenuView: View {
    
    public var onTapTop: () -> Void = {}
    @EnvironmentObject public var GPS: GlobalPositioningSystem
    
    public init(onTapTop: @escaping () -> Void = {}) {
        self.onTapTop = onTapTop
    }
    
    @StateObject public var CAP: ActivityPlanObject = ActivityPlanObject()
    @AppStorage("currentRoomId") public var currentRoomId: String = ""
    @AppStorage("gesturesAreLocked") public var gesturesAreLocked: Bool = false
    @State public var currentSize: Double = UIScreen.main.bounds.height
    @State public var CanvasMenuHeightFull: Double = UIScreen.main.bounds.height
    @State public var CanvasMenuHeightHalf: Double = UIScreen.main.bounds.height / 2
    
    @State public var isShowing: Bool = false
    @State public var showWindowViews: Bool = false
    @State public var showBoardSettings: Bool = false
    @State public var showTools: Bool = true
    @State public var showSize: String = "hide"

    let realmInstance = newRealm()
    
    public func getSize(stateIn: String) -> Double {
        if stateIn == "full" {
            return UIScreen.main.bounds.height
        }
        else if stateIn == "half" {
            return (UIScreen.main.bounds.height / 2)
        }
        else if stateIn == "hide" {
            return (UIScreen.main.bounds.height / 2)
        }
        return (UIScreen.main.bounds.height / 2)
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
                
                Spacer()
                
                BodyText("Room: \(currentRoomId)", color: .red)
                    .padding(.leading)
                    .padding(.trailing)
                
            }
            .frame(height: 50)
            .padding(.trailing)
            
            ScrollView(.vertical) {
                LazyVStack {
                    
                    ToolList(title: "Windows") {
                        CoreSolIconButton (
                            systemName: Icons.System.message.name,
                            width: 30.0,
                            height: 30.0,
                            fontColor: Color.black,
                            onTap: {
                                print("Chat View has been Tapped")
                                BroadcastTools.send(.NavStackMessage, value: NavStackMessage(navAction: .toggle, viewName: MenuBarProvider.chat.tool.title, viewAction: .toggle))
                            }
                        )
                        
                        CoreSolIconButton (
                            systemName: Icons.System.profile.name,
                            width: 30.0,
                            height: 30.0,
                            fontColor: Color.black,
                            onTap: {
                                print("Profile View has been Tapped")
                                BroadcastTools.send(.NavStackMessage, value: NavStackMessage(navAction: .toggle, viewName: MenuBarProvider.profile.tool.title, viewAction: .toggle))
                            }
                        )
                        
                        CoreSolIconButton (
                            systemName: Icons.System.people.name,
                            width: 30.0,
                            height: 30.0,
                            fontColor: Color.black,
                            onTap: {
                                print("Buddy List View has been Tapped")
                                BroadcastTools.send(.NavStackMessage, value: NavStackMessage(navAction: .toggle, viewName: MenuBarProvider.buddyList.tool.title, viewAction: .toggle))
                            }
                        )
                        
                        CoreSolIconButton (
                            systemName: Icons.System.room.name,
                            width: 30.0,
                            height: 30.0,
                            fontColor: Color.black,
                            onTap: {
                                print("Room View has been Tapped")
                                BroadcastTools.send(.NavStackMessage, value: NavStackMessage(navAction: .toggle, viewName: MenuBarProvider.activity.tool.title, viewAction: .toggle))
                            }
                        )
                        
                        CoreSolIconButton (
                            systemName: Icons.System.headphones.name,
                            width: 30.0,
                            height: 30.0,
                            fontColor: Color.black,
                            onTap: {
                                print("Bi-Beats View has been Tapped")
                                BroadcastTools.send(.NavStackMessage, value: NavStackMessage(navAction: .toggle, viewName: MenuBarProvider.info.tool.title, viewAction: .toggle))
                            }
                        )
                        
                    }
                    
                    CustomDisclosureGroup(isExpanded: $showBoardSettings, title: "Board Settings") {
//                        BoardSettingsBar()

                        ToolList(title: "") {
                            CoreSolIconConfirmButton(
                                systemName: "trash",
                                title: "Delete All Tools",
                                message: "Are you sure you want to delete all tools?",
                                width: 30.0,
                                height: 30.0,
                                onTap: {
                                    self.deleteRoomTools()
                                }
                            )
                            .padding(.leading)
                            .padding(.trailing)
                        }
                    }
                    
                    CustomDisclosureGroup(isExpanded: $showTools, title: "Tools") {
                        ToolList(title: "Smart Tools", forEachContent: {
                            ForEach(ViewEngine.Tool.ShapeTool.allCases, id: \.self) { tool in
                                ToolListItem(currentRoomId, tool: tool)
                            }
                        })
                        ToolList(title: "General", forEachContent: {
                            ForEach(ViewEngine.Tool.GeneralTool.allCases, id: \.self) { tool in
                                ToolListItem(currentRoomId, tool: tool)
                            }
                        })
                        ToolList(title: "Soccer", forEachContent: {
                            ForEach(ViewEngine.Tool.SoccerTool.allCases, id: \.self) { tool in
                                ToolListItem(currentRoomId, tool: tool)
                            }
                        })
                        ToolList(title: "Billiards", forEachContent: {
                            ForEach(ViewEngine.Tool.PoolBallTool.allCases, id: \.self) { tool in
                                ToolListItem(currentRoomId, tool: tool)
                            }
                        })
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 50)
            }
            
        }
        .frame(width: UIScreen.main.bounds.width * 1, height: currentSize)
        .toggleFromBelow($showSize, using: GPS, viewHeight: $currentSize, offsetY: 50)
        .onTap {
            onTapTop()
        }
        .onAppear() {
            
        }
    }
    
    func deleteRoomTools() {
        if let items = self.realmInstance.findAllByField(ManagedView.self, field: "boardId", value: self.currentRoomId) {
            self.realmInstance.safeWrite { db in
                for item in items {
                    item.isDeleted = true
                }
            }
        }
    }
}

public struct CustomDisclosureGroup<Content: View>: View {
    @Binding public var isExpanded: Bool
    public let title: String
    public let content: Content
    
    public init(isExpanded: Binding<Bool>, title: String, @ViewBuilder content: () -> Content) {
        self._isExpanded = isExpanded
        self.title = title
        self.content = content()
    }
    
    public var body: some View {
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
//                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.systemGray6))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
//        .padding(.horizontal)
    }
}

public struct BoardSettingsBarView: View {
    public var body: some View {
        Text("Board Settings Content")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 2)
    }
}
