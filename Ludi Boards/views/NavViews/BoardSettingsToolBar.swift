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
    
    
    
    
    let colors: [Color] = [Color.red, Color.blue]
    private let circleSize: CGFloat = 40
    private let spacing: CGFloat = 10

    @State private var showColor = false
    @State private var isShowing = false
    @State private var isLoading = false
    @State var cancellables = Set<AnyCancellable>()
    
    @State var attachedPlayerIsOn: Bool = false
    @State var hasPlayerRef: Bool = false
    @State var addPlayerName = ""
    @State var addPlayerId = "new"
    @State var showAddPlayerPicker: Bool = false
    @State private var currentPlayerId = "new"
    @State private var showNewPlayerRefSheet = false

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
                    title: "Delete All Tools",
                    message: "Are you sure you want to delete all tools?",
                    onTap: {
                        self.BEO.deleteAllTools()
                    }
                )
                
                Spacer().frame(width: 12)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 1, height: 50)
                    .padding()
                Spacer().frame(width: 12)
                
                SolIconButton(
                    systemName: "play",
                    onTap: {
                        
                    }
                )
                
                
                Spacer().frame(width: 12)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 1, height: 50)
                    .padding()
                Spacer().frame(width: 12)
                
                SolIconConfirmButton(
                    systemName: "video",
                    title: "Record Animation",
                    message: "Enter recording mode?",
                    onTap: {
                        
                    }
                )
                
                
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
                        BodyText("\(lineStroke)")
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
//                                saveToRealm()
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
//                                saveToRealm()
                            }
                    }
                    
                }
                
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
                        BodyText("\(fieldRotation)")
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
//                                saveToRealm()
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
//                                saveToRealm()
                            }
                    }
                    
                }
                
                Spacer().frame(width: 12)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 1, height: 50)
                    .padding()
                Spacer().frame(width: 12)
                
                
                
//                Spacer().frame(width: 12)
//                Rectangle()
//                    .fill(Color.white)
//                    .frame(width: 1, height: 50)
//                    .padding()
//                Spacer().frame(width: 12)
//                
//                
//                Spacer().frame(width: 12)
//                Rectangle()
//                    .fill(Color.white)
//                    .frame(width: 1, height: 50)
//                    .padding()
//                Spacer().frame(width: 12)
                
                BorderedVStack {
                    Text("Background Color: \(bgColor.uiColor.accessibilityName)")
                        .foregroundColor(bgColor)
                    ColorListPicker() { color in
                        print("Color Picker Tapper")
                        bgColor = color
                        self.BEO.setColor(colorIn: bgColor)
//                        saveToRealm()
                    }
                }
                .frame(width: 300)
                Spacer().frame(width: 24)
                
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
    
   
    
    // Function to rotate the view by a certain angle
    private func rotateView(by degrees: Double) {
        let newAngle = fieldRotation + degrees

        // Adjust the angle to be within the range 0-360
        fieldRotation = newAngle.truncatingRemainder(dividingBy: 360)
        if fieldRotation < 0 {
            fieldRotation += 360
        }
    }
    
//    // Observe From Realm
//    func observeFromRealm() {
//        self.managedViewNotificationToken?.invalidate()
//        if let mv = self.BEO.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: self.viewId) {
//            self.BEO.realmInstance.executeWithRetry {
//                self.managedViewNotificationToken = mv.observe { change in
//                    switch change {
//                        case .change(let obj, _):
//                            let temp = obj as! ManagedView
//                            if temp.id != self.viewId {return}
//                            DispatchQueue.main.async {
//                                if temp.id != self.viewId {return}
//                                if self.activityId != temp.boardId {self.activityId = temp.boardId}
//                                if self.viewSize != Double(temp.width) {self.viewSize = Double(temp.width)}
//                                if self.viewRotation != temp.rotation { self.viewRotation = temp.rotation}
//                                if self.isLocked != temp.isLocked { self.isLocked = temp.isLocked}
//    //                            self.lifeLastUserId = temp.lastUserId
//                            }
//                            case .error(let error):
//                                print("Error: \(error)")
//                                self.managedViewNotificationToken?.invalidate()
//                                self.managedViewNotificationToken = nil
//                                self.observeFromRealm()
//                            case .deleted:
//                                print("Object has been deleted.")
//                                self.isLocked = true
//                                self.managedViewNotificationToken?.invalidate()
//                                self.managedViewNotificationToken = nil
//                        }
//                    }
//            }
//            
//            }
//        
//    }
    
    func saveToRealm() {
        if let umv = self.BEO.realmInstance.findByField(ManagedView.self, value: self.BEO.toolBarCurrentViewId) {
            self.BEO.realmInstance.safeWrite { r in
                
            }
        }
    }
    
    func deleteFromRealm() {
        if let temp = self.BEO.realmInstance.findByField(ManagedView.self, value: self.BEO.toolBarCurrentViewId) {
            self.BEO.realmInstance.safeWrite { r in
//                temp.isDeleted = true
//                firebaseDatabase { db in
//                    db.child(self.activityId).child(self.viewId).setValue(temp.toDict())
//                }
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

