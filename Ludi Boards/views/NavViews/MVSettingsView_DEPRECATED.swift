//
//  MVSettingsView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/28/23.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift
import FirebaseDatabase
import CoreEngine

enum ToolLevels: Int {
    case BASIC = 1
    case LINE = 11
    case SMART = 21
    case PREMIUM = 31
}

struct SettingsView: View {
    
    var onDelete: () -> Void
    
    @ObservedResults(PlayerRef.self) var players
    var attachedPlayer: Results<PlayerRef> {
        return self.players.filter("toolId == %@", self.viewId)
    }
    
    let realmInstance = realm()
    @State var activityId = ""
    @EnvironmentObject var BEO: BoardEngineObject
    @StateObject var managedViews = ManagedViewListener()
    @State var managedViewNotificationToken: NotificationToken? = nil
    @State var viewSize: CGFloat = 50
    @State var viewRotation: Double = 0
    @State var viewColor: Color = .black
    @State var lineDash: CGFloat = 1
    @State var headIsEnabled: Bool = true
    
    @State var toolType: String = "BASIC"
    @State var toolLevel: Int = ToolLevels.BASIC.rawValue
    @State var isLocked = false
    @State var viewId: String = ""
    
    
    
    let colors: [Color] = [Color.red, Color.blue]
    private let circleSize: CGFloat = 40
    private let spacing: CGFloat = 10

    @State private var showColor = false
    @State private var isShowing = false
    @State private var isLoading = false
    @State private var showCompletion = false
    @State var cancellables = Set<AnyCancellable>()
    
    @State var attachedPlayerIsOn: Bool = false
    @State var hasPlayerRef: Bool = false
    @State var addPlayerName = ""
    @State var addPlayerId = "new"
    @State var showAddPlayerPicker: Bool = false
    @State private var currentPlayerId = "new"
    @State private var showNewPlayerRefSheet = false
    
    @State var fireDB = Database
        .database()
        .reference()
        .child(DatabasePaths.managedViews.rawValue)
    
    let tips = [
        "Double Tap to Toggle Settings.",
        "Hold down on line for Anchors.",
        "Red Box Tools are 'Live Drawing'.",
        "Yellow Box Tools are 'Basic Tools'."
    ]
    
    var body: some View {
        LoadingForm(isLoading: $isLoading, showCompletion: $showCompletion) { runLoading in
            
            if self.BEO.isLoggedIn {
                Section(header: Text("Connection Status").font(.headline)) {
                    InternetSpeedChecker()
                }
            }
            
            Section(header: Text("Player Reference").font(.headline)) {
                
                DStack {
                    Toggle(attachedPlayerIsOn ? "Player Attached" : "No Player", isOn: $attachedPlayerIsOn)
                        .padding()
                    
                    if hasPlayerRef {
                        PlayerRefItemView(playerId: $currentPlayerId)
                    } else {
//                        SolPlayerRefFreePicker(selection: $addPlayerName, isEnabled: $attachedPlayerIsOn)
//                            .padding()
                    }
                   
                }
                if hasPlayerRef {
                    SolButton(
                        title: "Player Details",
                        action: {
                            showNewPlayerRefSheet = true
                        },
                        isEnabled: hasPlayerRef
                    )
                } else {
                    SolButton(
                        title: "Create Player Reference",
                        action: {
                            showNewPlayerRefSheet = true
                        },
                        isEnabled: hasPlayerRef
                    )
                }
                
                
            }
            
            Section(header: Text("Tool Settings").font(.headline)) {
                
                DStack {
                    Section {
                        Toggle(isLocked ? "Locked" : "UnLocked", isOn: $isLocked)
                            .onChange(of: isLocked, perform: { _ in
                                let va = ViewAtts(viewId: viewId, isLocked: isLocked)
                                CodiChannel.TOOL_ATTRIBUTES.send(value: va)
                            })
                    }.padding()
                    
                    // Line Tool Only
                    if toolType == "LINE" {
                        Section {
                            Toggle(headIsEnabled ? "Arrow Visible" : "Arrow Not-Visible", isOn: $headIsEnabled)
                                .onChange(of: headIsEnabled, perform: { _ in
                                    let va = ViewAtts(viewId: viewId, headIsEnabled: headIsEnabled)
                                    CodiChannel.TOOL_ATTRIBUTES.send(value: va)
                                })
                        }.padding()
                    }
                    
                }
                
                // Settings
                Section(header: Text("Size: \(Int(viewSize))")) {
                    
                    Slider(value: $viewSize,
                       in: 15...500,
                       onEditingChanged: { editing in
                            if !editing {
                                let va = ViewAtts(viewId: viewId, size: viewSize)
                                CodiChannel.TOOL_ATTRIBUTES.send(value: va)
                            }
                        }
                    ).padding()
                        .gesture(DragGesture().onChanged { _ in }, including: .subviews)
                    
                }
                .padding(.horizontal)
                
                
                // Line Tool Only
                if toolType == "LINE" {
                    Section(header: Text("Dash/Dots: \(Int(lineDash))")) {
                        
                        Slider(value: $lineDash,
                           in: 1...100,
                           onEditingChanged: { editing in
                                if !editing {
                                    let va = ViewAtts(viewId: viewId, lineDash: lineDash)
                                    CodiChannel.TOOL_ATTRIBUTES.send(value: va)
                                }
                            }
                        ).padding()
                            .gesture(DragGesture().onChanged { _ in }, including: .subviews)
                        
                    }
                    .padding(.horizontal)
                }
                
                
                if toolType == "LINE" {
                    Text("Color: \(viewColor.uiColor.accessibilityName)")
                    ColorListPicker() { color in
                        print("Color Picker Tapper")
                        viewColor = color
                        let va = ViewAtts(viewId: viewId, color: viewColor)
                        CodiChannel.TOOL_ATTRIBUTES.send(value: va)
                    }
                } else {
                    Section(header: Text("Rotation: \(Int(viewRotation))")) {
                        Slider(
                            value: $viewRotation,
                            in: 0...360,
                            step: 15,
                            onEditingChanged: { editing in
                                if !editing {
                                    let va = ViewAtts(viewId: viewId, rotation: viewRotation)
                                    CodiChannel.TOOL_ATTRIBUTES.send(value: va)
                                }
                            }
                        ).padding()
                        
                    }.padding(.horizontal)
                }
                
                SolConfirmButton(
                    title: "Delete Tool",
                    message: "Would you like to delete this tool?",
                    action: {
                        if let temp = self.realmInstance.findByField(ManagedView.self, value: self.viewId) {
                            self.realmInstance.safeWrite { r in
                                temp.isDeleted = true
                            }
                            
                            firebaseDatabase { db in
                                db.child(self.activityId).child(self.viewId).setValue(temp.toDict())
                            }
                            
                        }
                        CodiChannel.TOOL_ON_DELETE.send(value: self.viewId)
                        closeWindow()
                    }
                )
            }
            
            /*  */
            Section(header: Text("All Activity Tools").font(.headline)) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(self.managedViews.basicTools) { item in
                            if item.toolType == "LINE" {
                                if self.viewId == item.id {
                                    BorderedView(color: .red) {
                                        LineIconView(isBgColor: true)
                                            .frame(width: 100, height: 100)
                                            .onTapAnimation {}
                                    }
                                } else {
                                    LineIconView(isBgColor: true)
                                        .frame(width: 100, height: 100)
                                        .onTapAnimation {}
                                }
                            } else {
                                if let temp = SoccerToolProvider.parseByTitle(title: item.toolType) {
                                    if self.viewId == item.id {
                                        BorderedView(color: .red) {
                                            ToolButtonSettingsIcon(icon: temp)
                                        }
                                    } else {
                                        ToolButtonSettingsIcon(icon: temp)
                                    }
                                }
                            }
                        }
                    }.padding()
                }
            }
            
            Section(header: Text("Tips and Tricks").font(.headline)) {
                ForEach(tips, id: \.self) { tip in
                    HStack(alignment: .top) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .frame(width: 12, height: 12)
                            .foregroundColor(.blue)
                            .padding(.top, 5)

                        Text(tip)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .background(Color.clear)
        .navigationBarTitle("Settings", displayMode: .inline)
        .onChange(of: addPlayerName, perform: { value in
            if !addPlayerName.isEmpty {
                showAddPlayerPicker = true
            }
        })
        .sheet(isPresented: $showNewPlayerRefSheet) {
            PlayerRefView(playerId: $currentPlayerId, isShowing: $showNewPlayerRefSheet)
        }
        .alert("Attach Player", isPresented: $showAddPlayerPicker) {
            Button("Cancel", role: .cancel) {
                showAddPlayerPicker = false
            }
            Button("OK", role: .none) {
                showAddPlayerPicker = false
                if let obj = self.realmInstance.findPlayerByName(name: self.addPlayerName) {
                    self.currentPlayerId = obj.id
                    self.realmInstance.safeWrite { _ in
                        obj.toolId = self.viewId
                    }
                }
            }
        } message: {
            Text("Are you sure you want to attach player to team?")
        }
        .onChange(of: self.BEO.currentActivityId, perform: { _ in
            startRestartSession()
        })
        .refreshable { onCreate() }
        .onAppear() { onCreate() }
        .onDisappear() { closeSession() }
    }
    
    func closeSession() {
        let va = ViewAtts(viewId: viewId, stateAction: "close")
        CodiChannel.TOOL_ATTRIBUTES.send(value: va)
        self.managedViewNotificationToken?.invalidate()
    }
    
    func closeWindow() {
        CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: "mv_settings", stateAction: "close", viewId: viewId))
    }
    
    func startRestartSession() {
        if self.activityId != self.BEO.currentActivityId {
            self.activityId = self.BEO.currentActivityId
        }
        managedViews.loadTools(activityId: self.activityId)
        observeFromRealm()
    }
    
    @MainActor
    func onCreate() {
        CodiChannel.TOOL_ATTRIBUTES.receive(on: RunLoop.main) { vId in
            let temp = vId as! ViewAtts
            if temp.viewId != self.viewId {
                self.viewId = temp.viewId
                startRestartSession()
            }
            if toolLevel != temp.level {
                toolLevel = temp.level
                if toolLevel == ToolLevels.BASIC.rawValue {showColor = false}
                else if toolLevel == ToolLevels.LINE.rawValue {showColor = true}
            }
            if let ttype = temp.toolType { self.toolType = ttype }
            if let tdash = temp.lineDash { self.lineDash = tdash }
            if let thead = temp.headIsEnabled { self.headIsEnabled = thead }
            if let ts = temp.size { self.viewSize = ts }
            if let tr = temp.rotation { self.viewRotation = tr }
            if let tc = temp.color { self.viewColor = tc }
            if let lc = temp.isLocked { self.isLocked = lc }
            
            hasPlayerRef = !attachedPlayer.isEmpty
            if hasPlayerRef {
                attachedPlayerIsOn = true
            } else {
                attachedPlayerIsOn = false
            }
            self.currentPlayerId = attachedPlayer.first?.id ?? "new"
            
        }.store(in: &cancellables)
        startRestartSession()
    }
    
    // Observe From Realm
    func observeFromRealm() {
        self.managedViewNotificationToken?.invalidate()
        if let mv = self.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: self.viewId) {
            self.managedViewNotificationToken = mv.observe { change in
                switch change {
                    case .change(let obj, _):
                        let temp = obj as! ManagedView
                        if temp.id != self.viewId {return}
                        DispatchQueue.main.async {
                            if temp.id != self.viewId {return}
                            if self.activityId != temp.boardId {self.activityId = temp.boardId}
                            if self.viewSize != Double(temp.width) {self.viewSize = Double(temp.width)}
                            if self.viewRotation != temp.rotation { self.viewRotation = temp.rotation}
                            if self.isLocked != temp.isLocked { self.isLocked = temp.isLocked}
//                            self.lifeLastUserId = temp.lastUserId
                        }
                        case .error(let error):
                            print("Error: \(error)")
                            self.managedViewNotificationToken?.invalidate()
                            self.managedViewNotificationToken = nil
                            self.observeFromRealm()
                        case .deleted:
                            print("Object has been deleted.")
                            self.isLocked = true
                            self.managedViewNotificationToken?.invalidate()
                            self.managedViewNotificationToken = nil
                    }
                }
            }
        
    }
    
}
