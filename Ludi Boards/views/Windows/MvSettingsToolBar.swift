//
//  MvSettingsToolBar.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/1/24.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift
import CoreEngine

struct MvSettingsBar<Content: View>: View {
    let content: Content
    @Environment(\.colorScheme) var colorScheme
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    private let soccerTools = SoccerToolProvider.allCases
    
    @State var gps = GlobalPositioningSystem(CoreNameSpace.local)
    @StateObject var tool = ManagedViewO()
    
    var sWidth = UIScreen.main.bounds.width
    var sHeight = UIScreen.main.bounds.height
    var borderColor: Color = .primaryBackground
    var borderWidth: CGFloat = 2
    
    //
    @State var activityId = ""
    @AppStorage("selectedManagedViewId") var selectedManagedViewId: String = ""
    @EnvironmentObject var BEO: BoardEngineObject
//    @StateObject var managedViews = ManagedViewListener()
    @State var managedViewNotificationToken: NotificationToken? = nil
    
    @State var viewId = ""
    @State var toolType: String = "BASIC"
    @State var toolLevel: Int = ToolLevels.BASIC.rawValue
    
    @State var isLocked = false
    @State var headIsEnabled: Bool = true
    @State var viewSize: CGFloat = 50
    @State var lineDashIsEnabled: Bool = false
    
    var isLineTool: Bool { return toolType == "LINE" || toolType == "CURVED-LINE" }
    
    let colors: [Color] = [Color.red, Color.blue]
    private let circleSize: CGFloat = 40
    private let spacing: CGFloat = 10

    @State private var showColor = false
    @State private var isShowing = false
    @State private var isLoading = false
    @State private var showCompletion = false
    @State var cancellables = Set<AnyCancellable>()
    
    @State var attachedPlayerIsOn: Bool = false
    @State var showAttachPlayers: Bool = false
    @State var hasPlayerRef: Bool = false
    @State var addPlayerName = ""
    @State var addPlayerId = "new"
    @State var showAddPlayerPicker: Bool = false
    @State private var currentPlayerId = "new"
    @State private var showNewPlayerRefSheet = false
    
    @State private var showColorPicker = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                
                // -> Window Function
                VStack {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(getForegroundColor(colorScheme))
                        .padding()
                        .onTapAnimation {
                            self.selectedManagedViewId = ""
                            closeWindow()
                        }
                    Spacer()
                }
                .padding(.leading)
                .frame(width: 20)
                
                Spacer().frame(width: 24)
                
                // -> ALL TOOLS
                SolIconConfirmButton(
                    systemName: "trash",
                    title: "Delete Tool",
                    message: "Are you sure you want to delete this tool?",
                    onTap: {
                        deleteFromRealm()
                        self.closeWindow()
                    }
                )
                
                SolIconConfirmButton(
                    systemName: "add",
                    title: "Duplicatee Tool",
                    message: "Are you sure you want to duplicate this tool?",
                    onTap: {
                        duplicateTool()
                    }
                )
                
                SolIconConfirmButton(
                    systemName: "add",
                    title: "Attach Player",
                    message: "Attach A Player?",
                    onTap: {
                        showAttachPlayers = true
                    }
                )
                
                Spacer().frame(width: 12)
                Rectangle()
                    .fill(getForegroundColor(colorScheme))
                    .frame(width: 1, height: 50)
                    .padding()
                Spacer().frame(width: 12)
                
                VStack {
                    Image(systemName: tool.isLocked ? "lock" : "lock.open")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(tool.isLocked ? .red : getForegroundColor(colorScheme))
                    Toggle("", isOn: $tool.isLocked)
                        .onChange(of: tool.isLocked, perform: { _ in
                            tool.saveToRealm()
                        })
                }
                
                Spacer().frame(width: 12)
                Rectangle()
                    .fill(getForegroundColor(colorScheme))
                    .frame(width: 1, height: 50)
                    .padding()
                Spacer().frame(width: 12)
                
                
                VStack {
                    
                    HStack {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(getForegroundColor(colorScheme))
                        BodyText("\(tool.width)", color: getFontColor(colorScheme))
                    }
                    
                    HStack {
                        Image(systemName: "minus")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.secondaryBackground.opacity(0.75)))
                            .font(.title)
                            .onTapAnimation {
                                print("make view smaller")
                                
                                if tool.isCircle {
                                    if let umv = self.BEO.realmInstance.findByField(ManagedView.self, value: self.BEO.toolBarCurrentViewId) {
                                        self.BEO.realmInstance.safeWrite { r in
                                            umv.width = Int(CGFloat(umv.width - 10).bounded(byMin: 50, andMax: 400))
                                        }
                                    }
                                } else {
                                    viewSize = (viewSize - 10).bounded(byMin: 50, andMax: 400)
                                    tool.width = Int(viewSize)
                                    tool.height = Int(viewSize)
                                    tool.saveToRealm()
                                }
                            }
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.secondaryBackground.opacity(0.75)))
                            .font(.title)
                            .onTapAnimation {
                                print("make view bigger")
                                if tool.isCircle {
                                    if let umv = self.BEO.realmInstance.findByField(ManagedView.self, value: self.BEO.toolBarCurrentViewId) {
                                        self.BEO.realmInstance.safeWrite { r in
                                            umv.width = Int(CGFloat(umv.width + 10).bounded(byMin: 50, andMax: 400))
                                        }
                                    }
                                } else {
                                    viewSize = (viewSize + 10).bounded(byMin: 50, andMax: 400)
                                    tool.width = Int(viewSize)
                                    tool.height = Int(viewSize)
                                    tool.saveToRealm()
                                }
                            }
                    }
                    
                }
                
                // -> Basic Tools Only
                if self.tool.isGeneral {
                    Spacer().frame(width: 12)
                    Rectangle()
                        .fill(getForegroundColor(colorScheme))
                        .frame(width: 1, height: 50)
                        .padding()
                    Spacer().frame(width: 12)
                    
                    VStack {
                        
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(getForegroundColor(colorScheme))
                            BodyText("\(tool.rotation)", color: getFontColor(colorScheme))
                        }
                        
                        HStack {
                            Image(systemName: "rotate.left")
                                .resizable()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.secondaryBackground.opacity(0.75)))
                                .font(.title)
                                .onTapAnimation {
                                    print("rotate left")
                                    rotateView(by: -22.5)
                                    tool.saveToRealm()
                                }
                            Image(systemName: "rotate.right")
                                .resizable()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.secondaryBackground.opacity(0.75)))
                                .font(.title)
                                .onTapAnimation {
                                    print("rotate right")
                                    rotateView(by: 22.5)
                                    tool.saveToRealm()
                                }
                        }
                        
                    }
                }
                
                
                // -> Line Tool Only
                
                if tool.isLineStraight {
                    
                    Spacer().frame(width: 12)
                    Rectangle()
                        .fill(getForegroundColor(colorScheme))
                        .frame(width: 1, height: 50)
                        .padding()
                    Spacer().frame(width: 12)
                    
                    VStack {
                        Image(systemName: tool.headIsEnabled ? "arrowtriangle.up" : "multiply")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(tool.headIsEnabled ? .red : getForegroundColor(colorScheme))
                        Toggle("", isOn: $tool.headIsEnabled)
                            .onChange(of: tool.headIsEnabled, perform: { _ in
                                tool.saveToRealm()
                            })
                    }
                    
                }
                
                if tool.isLinedShape || tool.isCircle {
                    Spacer().frame(width: 12)
                    Rectangle()
                        .fill(getForegroundColor(colorScheme))
                        .frame(width: 1, height: 50)
                        .padding()
                    Spacer().frame(width: 12)
                    
                    HStack {
                        VStack {
                            if lineDashIsEnabled {
                                DottedLineIconView()
                                    .frame(width: 25, height: 25)
                            } else {
                                LineIconView(isBgColor: false)
                                    .frame(width: 25, height: 25)
                            }
                            
                            Toggle("", isOn: $lineDashIsEnabled)
                                .onChange(of: lineDashIsEnabled, perform: { _ in
                                    if !lineDashIsEnabled {
                                        tool.lineDash = 1
                                    } else {
                                        tool.lineDash = 50
                                    }
                                    tool.saveToRealm()
                                })
                        }
                        
                        if lineDashIsEnabled {
                            VStack {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Circle().fill(Color.secondaryBackground.opacity(0.75)))
                                    .font(.title)
                                    .onTapAnimation {
                                        print("more line dash")
                                        
                                        tool.lineDash = (tool.lineDash + 2).bound(minValue: 1, maxValue: 100)
                                        tool.saveToRealm()
                                    }
                                Image(systemName: "minus")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Circle().fill(Color.secondaryBackground.opacity(0.75)))
                                    .font(.title)
                                    .onTapAnimation {
                                        print("less line dash")
                                        tool.lineDash = (tool.lineDash - 2).bound(minValue: 1, maxValue: 100)
                                        tool.saveToRealm()
                                    }
                            }
                        }
                        
                    }
                    
                    Spacer().frame(width: 12)
                    Rectangle()
                        .fill(getForegroundColor(colorScheme))
                        .frame(width: 1, height: 50)
                        .padding()
                    Spacer().frame(width: 12)
                    
                    
                    
                    VStack {
                        SolIconButton(
                            systemName: "paintpalette",
                            width: 40.0,
                            height: 40.0,
                            onTap: {
                                self.showColorPicker = !self.showColorPicker
                            }
                        )
                        BodyText("Color", color: getFontColor(colorScheme))
                    }
                    
                    if self.showColorPicker {
                        ColorListPickerView() { color in
                            print("Color Picker Tapper")
                            let red = color.toRGBA()?.red ?? 255
                            let green = color.toRGBA()?.green ?? 255
                            let blue = color.toRGBA()?.blue ?? 255
                            let opacity = color.toRGBA()?.alpha ?? 255
                            tool.colorRed = red
                            tool.colorBlue = blue
                            tool.colorGreen = green
                            tool.colorAlpha = opacity
                            tool.saveToRealm()
                            
                        }
                        .frame(width: 100)
    //                        .offset(x: 0.0, y: -(UIScreen.main.bounds.height/2))
                        .padding(.bottom, UIScreen.main.bounds.height/2)
                    }
                    
                    Spacer().frame(width: 24)
                }
            }
                    
        }
        .sheet(isPresented: $showAttachPlayers) {
            ToolToPlayerRefView(toolId: self.$viewId)
        }
        .frame(width: Double(sWidth).bound(to: 200...sWidth) - 150, height: 150)
        .solBackground()
        .onChange(of: self.BEO.toolBarCurrentViewId, perform: { value in
            self.viewId = self.BEO.toolBarCurrentViewId
            loadFromRealm()
        })
        .onAppear() {
            loadFromRealm()
        }
    }
    
    
    
    func closeWindow() {
        self.BEO.toolSettingsIsShowing = false
        BroadcastTools.send(.NavStackMessage, value: NavStackMessage(viewName: "mvsettings", viewAction: WindowAction.close))
    }
    
    func startRestartSession() {
        if self.activityId != self.BEO.currentActivityId {
            self.activityId = self.BEO.currentActivityId
        }
//        managedViews.loadTools(activityId: self.activityId)
        observeFromRealm()
    }
    
    // Function to rotate the view by a certain angle
    private func rotateView(by degrees: Double) {
        let newAngle = tool.rotation + degrees

        // Adjust the angle to be within the range 0-360
        tool.rotation = newAngle.truncatingRemainder(dividingBy: 360)
        if tool.rotation < 0 {
            tool.rotation += 360
        }
    }
    
    // Observe From Realm
    func observeFromRealm() {
        self.managedViewNotificationToken?.invalidate()
        if let mv = self.BEO.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: self.viewId) {
            self.BEO.realmInstance.executeWithRetry {
                self.managedViewNotificationToken = mv.observe { change in
                    switch change {
                        case .change(let obj, _):
                            let temp = obj as! ManagedView
                            if temp.id != self.tool.id {return}
                            DispatchQueue.main.async {
                                if temp.id != self.tool.id {return}
                                if self.tool.boardId != temp.boardId {self.tool.boardId = temp.boardId}
                                if self.tool.width != temp.width {self.tool.width = temp.width}
                                if self.tool.rotation != temp.rotation { self.tool.rotation = temp.rotation}
                                if self.tool.isLocked != temp.isLocked { self.tool.isLocked = temp.isLocked}
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
    
    func saveToRealm() {
        tool.saveToRealm()
//        if let umv = self.BEO.realmInstance.findByField(ManagedView.self, value: self.BEO.toolBarCurrentViewId) {
//            self.BEO.realmInstance.safeWrite { r in
//                umv.isLocked = isLocked
//                umv.width = Int(viewSize)
//                umv.height = Int(viewSize)
//                umv.rotation = viewRotation
//                umv.headIsEnabled = headIsEnabled
//                umv.lineDash = Int(lineDash)
//                if let lc = viewColor.toRGBA() {
//                    umv.colorRed = lc.red
//                    umv.colorGreen = lc.green
//                    umv.colorBlue = lc.blue
//                    umv.colorAlpha = lc.alpha
//                }
//            }
//        }
    }
    func updateRealm(update: @escaping (ManagedView) -> Void) {
        if let temp = self.BEO.realmInstance.findByField(ManagedView.self, value: self.BEO.toolBarCurrentViewId) {
            self.BEO.realmInstance.safeWrite { r in
                update(temp)
            }
        }
    }
    func deleteFromRealm() {
        if let temp = self.BEO.realmInstance.findByField(ManagedView.self, value: self.BEO.toolBarCurrentViewId) {
            self.BEO.realmInstance.safeWrite { r in
                temp.isDeleted = true
                BroadcastTools.send(.Canvas, value: CanvasAction.refresh)
            }
        }
    }
    
    func duplicateTool() {
        if let temp = self.BEO.realmInstance.findByField(ManagedView.self, value: self.BEO.toolBarCurrentViewId) {
            self.BEO.realmInstance.safeWrite { r in
                let copied = ManagedView()
                copied.absorbProperties(from: temp)
                copied.id = UUID().uuidString
                copied.x = temp.x - 300.0
                copied.y = temp.y - 300.0
                copied.startX = temp.startX - 300.0
                copied.startY = temp.startY - 300.0
                copied.endX = temp.endX - 300.0
                copied.endY = temp.endY - 300.0
                copied.centerX = temp.centerX - 300.0
                copied.centerY = temp.centerY - 300.0
                copied.colorRed = temp.colorRed
                copied.colorBlue = temp.colorBlue
                copied.colorGreen = temp.colorGreen
                copied.colorAlpha = temp.colorAlpha
                copied.lineDash = temp.lineDash
                r.create(ManagedView.self, value: copied, update: .all)
            }
            BroadcastTools.send(.Canvas, value: CanvasAction.refresh)
        }
    }
    
    // Realm / Firebase
    func loadFromRealm() {
        self.tool.loadManagedView(byId: self.BEO.toolBarCurrentViewId)
//        if let umv = self.BEO.realmInstance.findByField(ManagedView.self, value: self.BEO.toolBarCurrentViewId) {
//            // set attributes
//            self.viewId = umv.id
//            activityId = umv.boardId
//            isLocked = umv.isLocked
//            toolType = umv.toolType
//            viewSize = Double(umv.width)
//            viewRotation = umv.rotation
//            headIsEnabled = umv.headIsEnabled
//            lineDash = CGFloat(umv.lineDash)
//            lineDashIsEnabled = lineDash == 1 ? false : true
//            viewColor = colorFromRGBA(red: umv.colorRed, green: umv.colorGreen, blue: umv.colorBlue, alpha: umv.colorAlpha)
//        }
    }
    
    
}

