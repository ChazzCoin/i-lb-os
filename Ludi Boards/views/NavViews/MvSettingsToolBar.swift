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

struct MvSettingsBar<Content: View>: View {
    let content: Content
    @Environment(\.colorScheme) var colorScheme
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    private let soccerTools = SoccerToolProvider.allCases
    
    @State var gps = GlobalPositioningSystem()
    
    var sWidth = UIScreen.main.bounds.width
    var sHeight = UIScreen.main.bounds.height
    var borderColor: Color = .primaryBackground
    var borderWidth: CGFloat = 2
    
    //
    @State var activityId = ""
    @EnvironmentObject var BEO: BoardEngineObject
    @StateObject var managedViews = ManagedViewListener()
    @State var managedViewNotificationToken: NotificationToken? = nil
    
    @State var viewId = ""
    @State var toolType: String = "BASIC"
    @State var toolLevel: Int = ToolLevels.BASIC.rawValue
    
    @State var isLocked = false
    @State var headIsEnabled: Bool = true
    @State var viewSize: CGFloat = 50
    @State var viewRotation: Double = 0
    @State var viewColor: Color = .black
    @State var lineDash: CGFloat = 1
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
                
                VStack {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.white)
                        .padding()
                        .onTapAnimation {
                            closeWindow()
                        }
                    Spacer()
                }
                .frame(width: 20)
                
                Spacer().frame(width: 24)
                
                SolIconConfirmButton(
                    systemName: "trash",
                    title: "Delete Tool",
                    message: "Are you sure you want to delete this tool?",
                    onTap: {
                        deleteFromRealm()
                        self.closeWindow()
                    }
                )
                
                Spacer().frame(width: 12)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 1, height: 50)
                    .padding()
                Spacer().frame(width: 12)
                
                VStack {
                    Image(systemName: isLocked ? "lock" : "lock.open")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(isLocked ? .red : .white)
                    Toggle("", isOn: $isLocked)
                        .onChange(of: isLocked, perform: { _ in
                            saveToRealm()
                        })
                }
                
                Spacer().frame(width: 12)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 1, height: 50)
                    .padding()
                Spacer().frame(width: 12)
                
                VStack {
                    
                    HStack {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                        BodyText("\(viewSize)")
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
                                viewSize = (viewSize - 10).bounded(byMin: 50, andMax: 400)
                                saveToRealm()
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
                                viewSize = (viewSize + 10).bounded(byMin: 50, andMax: 400)
                                saveToRealm()
                            }
                    }
                    
                }
                
                if !isLineTool {
                    Spacer().frame(width: 12)
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 1, height: 50)
                        .padding()
                    Spacer().frame(width: 12)
                    
                    VStack {
                        
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.white)
                            BodyText("\(viewRotation)")
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
                                    saveToRealm()
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
                                    saveToRealm()
                                }
                        }
                        
                    }
                }
                
                if isLineTool {
                    
                    Spacer().frame(width: 12)
                    Rectangle()
                        .fill(Color.white)
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
                                        lineDash = 1.0
                                    } else {
                                        lineDash = 50.0
                                    }
                                    saveToRealm()
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
                                        lineDash = (lineDash + 2.0).bounded(byMin: 1, andMax: 100)
                                        saveToRealm()
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
                                        lineDash = (lineDash - 2.0).bounded(byMin: 1, andMax: 100)
                                        saveToRealm()
                                    }
                            }
                        }
                        
                    }
                }
                
                if isLineTool {
                    Spacer().frame(width: 12)
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 1, height: 50)
                        .padding()
                    Spacer().frame(width: 12)
                    
                    VStack {
                        Image(systemName: headIsEnabled ? "arrowtriangle.up" : "multiply")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(headIsEnabled ? .red : .white)
                        Toggle("", isOn: $headIsEnabled)
                            .onChange(of: headIsEnabled, perform: { _ in
                                saveToRealm()
                            })
                    }
                }
                
                if isLineTool {
                    
                    Spacer().frame(width: 12)
                    Rectangle()
                        .fill(Color.white)
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
                        BodyText("Color")
                    }
                    
                    if self.showColorPicker {
                        ColorListPickerView() { color in
                            print("Color Picker Tapper")
                            viewColor = color
                            saveToRealm()
                        }
                        .frame(width: 100)
                        .padding(.bottom, UIScreen.main.bounds.height/2)
                    }
                    
//                    BorderedVStack {
//                        Text("Color: \(viewColor.uiColor.accessibilityName)")
//                            .foregroundColor(viewColor)
//                        ColorListPicker() { color in
//                            print("Color Picker Tapper")
//                            viewColor = color
//                            saveToRealm()
//                        }
//                    }
//                    .frame(width: 300)
                    Spacer().frame(width: 24)
                }
                
            }.padding()
        }
        .frame(width: Double(sWidth).bound(to: 200...sWidth) - 150, height: 150)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(backgroundColorForScheme(colorScheme))
                .shadow(radius: 5)
        )
        .onChange(of: self.BEO.toolBarCurrentViewId, perform: { value in
            loadFromRealm()
        })
        .onAppear() {
            loadFromRealm()
        }
    }
    
    
    
    func closeWindow() {
        self.BEO.toolSettingsIsShowing = false
    }
    
    func startRestartSession() {
        if self.activityId != self.BEO.currentActivityId {
            self.activityId = self.BEO.currentActivityId
        }
        managedViews.loadTools(activityId: self.activityId)
        observeFromRealm()
    }
    
    // Function to rotate the view by a certain angle
    private func rotateView(by degrees: Double) {
        let newAngle = viewRotation + degrees

        // Adjust the angle to be within the range 0-360
        viewRotation = newAngle.truncatingRemainder(dividingBy: 360)
        if viewRotation < 0 {
            viewRotation += 360
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
    
    func saveToRealm() {
        if let umv = self.BEO.realmInstance.findByField(ManagedView.self, value: self.BEO.toolBarCurrentViewId) {
            self.BEO.realmInstance.safeWrite { r in
                umv.isLocked = isLocked
                umv.width = Int(viewSize)
                umv.height = Int(viewSize)
                umv.rotation = viewRotation
                umv.headIsEnabled = headIsEnabled
                umv.lineDash = Int(lineDash)
                if let lc = viewColor.toRGBA() {
                    umv.colorRed = lc.red
                    umv.colorGreen = lc.green
                    umv.colorBlue = lc.blue
                    umv.colorAlpha = lc.alpha
                }
            }
        }
    }
    
    func deleteFromRealm() {
        if let temp = self.BEO.realmInstance.findByField(ManagedView.self, value: self.BEO.toolBarCurrentViewId) {
            self.BEO.realmInstance.safeWrite { r in
                temp.isDeleted = true
                firebaseDatabase { db in
                    db.child(self.activityId).child(self.viewId).setValue(temp.toDict())
                }
            }
        }
    }
    
    // Realm / Firebase
    func loadFromRealm() {
        
        if let umv = self.BEO.realmInstance.findByField(ManagedView.self, value: self.BEO.toolBarCurrentViewId) {
            // set attributes
            activityId = umv.boardId
            isLocked = umv.isLocked
            toolType = umv.toolType
            viewSize = Double(umv.width)
            viewRotation = umv.rotation
            headIsEnabled = umv.headIsEnabled
            lineDash = CGFloat(umv.lineDash)
            lineDashIsEnabled = lineDash == 1 ? false : true
            viewColor = colorFromRGBA(red: umv.colorRed, green: umv.colorGreen, blue: umv.colorBlue, alpha: umv.colorAlpha)
                        
        }
    }
    
    
}

