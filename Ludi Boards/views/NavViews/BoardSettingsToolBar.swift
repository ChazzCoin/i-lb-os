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

struct BoardSettingsBar: View {
    @Environment(\.colorScheme) var colorScheme
    
    private let soccerTools = SoccerToolProvider.allCases
    
    @State var gps = GlobalPositioningSystem()
    
    var sWidth = UIScreen.main.bounds.width
    var sHeight = UIScreen.main.bounds.height
    var borderColor: Color = .primaryBackground
    var borderWidth: CGFloat = 2
    
    @EnvironmentObject var BEO: BoardEngineObject
    @StateObject var managedViews = ManagedViewListener()
    @State var managedViewNotificationToken: NotificationToken? = nil

    @State private var refreshView = false
    @State private var showLoading = false
    @State private var showCompletion = false
    @State private var isCurrentPlan = false
    @State private var colorOpacity = 1.0
    @State private var lineOpacity = 1.0
    @State private var lineStroke = 1.0
    @State private var lineColor = Color.clear
    @State private var bgColor = Color.clear
    @State private var fieldName = ""
    @State private var fieldRotation = 0.0
    @State var backgroundView = ""
    
    let colors: [Color] = [Color.red, Color.blue]
    private let circleSize: CGFloat = 40
    private let spacing: CGFloat = 10

    @State private var lockIconColor: Color = .white
    @State private var showColor = false
    @State private var isShowing = false
    @State private var isLoading = false
    @State var cancellables = Set<AnyCancellable>()
    
//    @State var attachedPlayerIsOn: Bool = false
//    @State var hasPlayerRef: Bool = false
//    @State var addPlayerName = ""
//    @State var addPlayerId = "new"
//    @State var showAddPlayerPicker: Bool = false
//    @State private var currentPlayerId = "new"
//    @State private var showNewPlayerRefSheet = false
    
    @State var showBoardPicker = false
    @State var showBoardBgColorPicker = false
    @State var showBoardLineColorPicker = false
   
    @State var alertRecordAnimation = false
    @State var showRecordingsSheet = false
    @State var alertRecordAnimationTitle = "Animation Recording"
    var alertRecordAnimationMessage: String {
        return "Are you sure you want to \(self.BEO.isRecording ? "Stop" : "Start") recording?"
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                
                VStack {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(getForegroundColor(colorScheme))
                        .padding()
                        .padding(.top)
                        .padding(.leading)
                        .onTapAnimation {
                            closeWindow()
                        }
                    Spacer()
                }
                .frame(width: 20)
                
                Spacer().frame(width: 24)
                
                VStack {
                    SolIconButton(
                        systemName: self.BEO.gesturesAreLocked ? "lock.fill" : "lock.open",
                        width: 40.0,
                        height: 40.0,
                        fontColor: Color.red,
                        onTap: {
                            withAnimation {
                                self.BEO.gesturesAreLocked = !self.BEO.gesturesAreLocked
                            }
                        }
                    )
                    
                    Rectangle()
                        .fill(getForegroundColor(colorScheme))
                        .frame(width: 50, height: 1)
                    
                    SolIconConfirmButton(
                        systemName: "trash",
                        title: "Delete All Tools",
                        message: "Are you sure you want to delete all tools?",
                        width: 40.0,
                        height: 40.0,
                        onTap: {
                            self.BEO.deleteAllTools()
                        }
                    )
                }
                
                Spacer().frame(width: 12)
                Rectangle()
                    .fill(getForegroundColor(colorScheme))
                    .frame(width: 1, height: 50)
                    .padding()
                Spacer().frame(width: 12)
                
                VStack {
                    SolIconButton(
                        systemName: "play",
                        width: 40.0,
                        height: 40.0,
                        onTap: {
                            self.showRecordingsSheet = true
                        }
                    )
                    
                    Rectangle()
                        .fill(getForegroundColor(colorScheme))
                        .frame(width: 50, height: 1)
                    
                    SolIconConfirmButton(
                        systemName: "video",
                        title: "Record Animation",
                        message: "Enter recording mode?",
                        width: 40.0,
                        height: 40.0,
                        onTap: {
                            self.alertRecordAnimation = true
                        }
                    )
                }
                
                Spacer().frame(width: 12)
                Rectangle()
                    .fill(getForegroundColor(colorScheme))
                    .frame(width: 1, height: 50)
                    .padding()
                Spacer().frame(width: 12)
                
                VStack {
                    SolIconButton(
                        systemName: "photo",
                        width: 40.0,
                        height: 40.0,
                        onTap: {
                            self.showBoardPicker = !self.showBoardPicker
                        }
                    )
                    BodyText("Boards", color: getFontColor(colorScheme))
                }
                
                if self.showBoardPicker {
                    BoardListPicker(initialSelected: self.isCurrentPlan ? self.BEO.boardBgName : self.backgroundView, viewBuilder: self.BEO.boards.getAllMinis()) { v in
                        fieldName = v
                        self.BEO.setBoardBgView(boardName: v)
                        saveToRealm()
                    }
                    .frame(width: 400)
                    .padding(.bottom, UIScreen.main.bounds.height/2)
                }
                
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
                        BodyText("\(fieldRotation)", color: getFontColor(colorScheme))
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
                                self.BEO.boardFeildRotation = fieldRotation
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
                                self.BEO.boardFeildRotation = fieldRotation
                                saveToRealm()
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
                            self.showBoardBgColorPicker = !self.showBoardBgColorPicker
                        }
                    )
                    BodyText("Background", color: getFontColor(colorScheme))
                    BodyText("Color", color: getFontColor(colorScheme))
                }
                
                if self.showBoardBgColorPicker {
                    ColorListPickerView() { color in
                        print("Background Color Picker Tapper")
                        bgColor = color
                        self.BEO.setColor(colorIn: bgColor)
                        saveToRealm()
                    }
                    .frame(width: 100)
                    .padding(.bottom, UIScreen.main.bounds.height/2)
                }
                
                Spacer().frame(width: 12)
                Rectangle()
                    .fill(getForegroundColor(colorScheme))
                    .frame(width: 1, height: 50)
                    .padding()
                Spacer().frame(width: 12)
                
                
                // LINE SETTINGS
                
                VStack {
                    
                    HStack {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(getForegroundColor(colorScheme))
                        BodyText("\(lineStroke)", color: getFontColor(colorScheme))
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
                                print("make lineStroke smaller")
                                lineStroke = (lineStroke - 10).bounded(byMin: 50, andMax: 400)
                                self.BEO.boardFeildLineStroke = lineStroke
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
                                print("make lineStroke bigger")
                                lineStroke = (lineStroke + 10).bounded(byMin: 50, andMax: 400)
                                self.BEO.boardFeildLineStroke = lineStroke
                                saveToRealm()
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
                        systemName: "paintbrush",
                        width: 40.0,
                        height: 40.0,
                        onTap: {
                            self.showBoardLineColorPicker = !self.showBoardLineColorPicker
                        }
                    )
                    BodyText("Line Color", color: getFontColor(colorScheme))
                }
                
                if self.showBoardLineColorPicker {
                    ColorListPickerView() { color in
                        print("Background Color Picker Tapper")
                        lineColor = color
                        self.BEO.setFieldLineColor(colorIn: lineColor)
                        saveToRealm()
                    }
                    .frame(width: 100)
                    .padding(.bottom, UIScreen.main.bounds.height/2)
                }
                
            }.padding()
        }
        .frame(width: Double(sWidth).bound(to: 200...sWidth) - 150, height: 150)
        .solBackground()
        .onChange(of: self.BEO.toolBarCurrentViewId, perform: { value in
            loadFromRealm()
        })
        .alert(self.alertRecordAnimationTitle, isPresented: $alertRecordAnimation) {
            Button("Cancel", role: .cancel) {
                alertRecordAnimation = false
            }
            Button("OK", role: .none) {
                alertRecordAnimation = false
                if !self.BEO.isRecording {
                    self.BEO.startRecording()
                } else {
                    self.BEO.stopRecording()
                }
            }
        } message: {
            Text(self.alertRecordAnimationMessage)
        }
        .sheet(isPresented: self.$showRecordingsSheet, content: {
            RecordingListView(isShowing: self.$showRecordingsSheet)
                .environmentObject(self.BEO)
        })
        .onAppear() {
            loadFromRealm()
        }
    }

    
    func closeWindow() { self.BEO.boardSettingsIsShowing = false }
    
    // Function to rotate the view by a certain angle
    private func rotateView(by degrees: Double) {
        let newAngle = fieldRotation + degrees

        // Adjust the angle to be within the range 0-360
        fieldRotation = newAngle.truncatingRemainder(dividingBy: 360)
        if fieldRotation < 0 {
            fieldRotation += 360
        }
    }
    
    func saveToRealm() {
        if let activityPlan = self.BEO.realmInstance.findByField(ActivityPlan.self, value: self.BEO.currentActivityId) {
            self.BEO.realmInstance.safeWrite { r in
                 activityPlan.backgroundLineStroke = self.lineStroke
                 activityPlan.backgroundLineAlpha = self.lineOpacity
                 activityPlan.backgroundAlpha = self.colorOpacity
                 activityPlan.backgroundRotation = self.fieldRotation
                 activityPlan.backgroundView = self.fieldName
                
                if let c = bgColor.toRGBA() {
                    activityPlan.backgroundRed = c.red
                    activityPlan.backgroundGreen = c.green
                    activityPlan.backgroundBlue = c.blue
                    activityPlan.backgroundAlpha = c.alpha
                }
                
                if let lc = lineColor.toRGBA() {
                    activityPlan.backgroundLineRed = lc.red
                    activityPlan.backgroundLineGreen = lc.green
                    activityPlan.backgroundLineBlue = lc.blue
                    activityPlan.backgroundLineAlpha = lc.alpha
                }
                
                // TODO: FIREBASE
            }
        }
    }
    
    // Realm / Firebase
    func loadFromRealm() {
        
        if let activityPlan = self.BEO.realmInstance.findByField(ActivityPlan.self, value: self.BEO.currentActivityId) {
            // set attributes
            self.lineStroke = activityPlan.backgroundLineStroke
            self.lineOpacity = activityPlan.backgroundLineAlpha
            self.colorOpacity = activityPlan.backgroundAlpha
            self.fieldRotation = activityPlan.backgroundRotation
            self.fieldName = activityPlan.backgroundView
                        
        }
    }
    
}

