//
//  MVSettingsView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/28/23.
//

import Foundation
import SwiftUI
import Combine
import FirebaseDatabase

enum ToolLevels: Int {
    case BASIC = 1
    case LINE = 11
    case SMART = 21
    case PREMIUM = 31
}

struct SettingsView: View {
    
    var onDelete: () -> Void
    
    let realmInstance = realm()
    @State var activityId = ""
    @EnvironmentObject var BEO: BoardEngineObject
    @StateObject var managedViews = ManagedViewListener()
    
    @State var viewSize: CGFloat = 50
    @State var viewRotation: Double = 0
    @State var viewColor: Color = .black
    @State var toolLevel: Int = ToolLevels.BASIC.rawValue
    @State var viewId: String = ""
    
    let colors: [Color] = [Color.red, Color.blue]
    private let circleSize: CGFloat = 40
    private let spacing: CGFloat = 10

    @State private var showColor = false
    @State private var isShowing = false
    @State private var isLoading = false
    @State private var showCompletion = false
    @State var cancellables = Set<AnyCancellable>()
    
    @State var fireDB = Database
        .database()
        .reference()
        .child(DatabasePaths.managedViews.rawValue)
    
    let tips = [
        "Double Tap to Toggle Settings.",
        "Single Tap Line's for Resize.",
        "Red Box Tools are 'Live Drawing'.",
        "Yellow Box Tools are 'Basic Tools'."
    ]
    
    var body: some View {
        LoadingForm(isLoading: $isLoading, showCompletion: $showCompletion) { runLoading in
            
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
            
            Section(header: Text("Tool Settings").font(.headline)) {
                // Settings
                Section(header: Text("Size: \(Int(viewSize))")) {
                    
                    Slider(value: $viewSize,
                       in: 15...300,
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
                
                if self.showColor {
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
                            step: 45,
                            onEditingChanged: { editing in
                                if !editing {
                                    let va = ViewAtts(viewId: viewId, rotation: viewRotation)
                                    CodiChannel.TOOL_ATTRIBUTES.send(value: va)
                                }
                            }
                        ).padding()
                        
                    }.padding(.horizontal)
                }
                
                solConfirmButton(
                    title: "Delete Tool",
                    message: "Would you like to delete this tool?",
                    action: {
                        if let temp = self.realmInstance.findByField(ManagedView.self, value: self.viewId) {
                            self.realmInstance.safeWrite { r in
                                temp.isDeleted = true
                            }
                            self.fireDB.child(self.activityId).child(self.viewId).setValue(temp.toDict())
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
                            if item.toolType == "LINE" || item.toolType == "DOTTED-LINE" {
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
        }
        .background(Color.clear)
        .navigationBarTitle("Settings", displayMode: .inline)
        .refreshable { onCreate() }
        .onAppear() { onCreate() }
        .onDisappear() { closeSession() }
    }
    
    func closeSession() {
        let va = ViewAtts(viewId: viewId, stateAction: "close")
        CodiChannel.TOOL_ATTRIBUTES.send(value: va)
    }
    
    func closeWindow() {
        CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: "mv_settings", stateAction: "close", viewId: viewId))
    }
    
    func startRestartSession() {
        if self.activityId != self.BEO.currentActivityId {
            self.activityId = self.BEO.currentActivityId
        }
        managedViews.loadTools(activityId: self.activityId)
    }
    
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
            if let ts = temp.size { viewSize = ts }
            if let tr = temp.rotation { viewRotation = tr }
            if let tc = temp.color { viewColor = tc }
        }.store(in: &cancellables)
        startRestartSession()
    }
    
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView(onDelete: {})
//    }
//}
