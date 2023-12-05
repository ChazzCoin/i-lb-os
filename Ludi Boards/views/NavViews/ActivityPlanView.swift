//
//  ActivityPlanView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import SwiftUI
import RealmSwift
import Combine

// ActivityPlan View
struct ActivityPlanView: View {
    @State var boardId: String
    @State var sessionId: String
    @Binding var isShowing: Bool
    @EnvironmentObject var BEO: BoardEngineObject
    @Environment(\.presentationMode) var presentationMode
    @State var isLoading: Bool = false
    @State private var activityPlan: ActivityPlan = ActivityPlan() // Use StateObject for lifecycle management
    @State var realmInstance = realm()
    
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
    
    @State var cancellables = Set<AnyCancellable>()
    @State private var sessionNotificationToken: NotificationToken? = nil

    var body: some View {
        
        LoadingForm(isLoading: $isLoading, showCompletion: $showCompletion) { runLoading in
            
            // Details Section
            Section(header: Text("Activity Details")) {
                TextField("Title", text: $activityPlan.title)
                TextField("Sub Title", text: $activityPlan.subTitle)
                TextField("Date", text: $activityPlan.dateOf)
                TextField("Time Period", text: $activityPlan.timePeriod)
                TextField("Duration", text: $activityPlan.duration)
                TextField("Age Level", text: $activityPlan.ageLevel)
            }

            // Description Section
            Section(header: Text("Description")) {
                TextEditor(text:$activityPlan.objectiveDetails)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }

            // Objective Section
            Section(header: Text("Objective")) {
                TextEditor(text:$activityPlan.activityDetails)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
            
            Section(header: Text("Board Settings")) {
                
                
                Section(header: Text("Field Color: \(bgColor.uiColor.accessibilityName)")) {
                    ColorListPicker() { color in
                        bgColor = color
                        if self.isCurrentPlan {
                            self.BEO.setColor(colorIn: color)
                            if let c = color.toRGBA() {
                                realmInstance.safeWrite { r in
                                    self.activityPlan.backgroundRed = c.red
                                    self.activityPlan.backgroundGreen = c.green
                                    self.activityPlan.backgroundBlue = c.blue
                                    self.activityPlan.backgroundAlpha = c.alpha
                                    r.add(self.activityPlan)
                                }
                            }
                        }
                        
                    }
                    Text("Background Color Transparency: \(colorOpacity)")
                    Slider(
                        value: $colorOpacity,
                        in: 0.0...1.0,
                        step: 0.1,
                        onEditingChanged: { editing in
                            if !editing {
                                if self.isCurrentPlan {
                                    self.BEO.boardBgAlpha = colorOpacity
                                    self.BEO.boardBgColor = self.BEO.getColor()
                                    realmInstance.safeWrite { r in
                                        self.activityPlan.backgroundAlpha = colorOpacity
                                        r.add(self.activityPlan)
                                    }
                                }
                                
                            }
                        }
                    ).padding()
                }.padding(.leading)
                
                Section(header: Text("Field Lines")) {
                    
                    Text("Field Type: \(fieldName)")
                    BarListPicker(initialSelected: self.isCurrentPlan ? self.BEO.boardBgName : self.activityPlan.backgroundView, viewBuilder: self.BEO.boardBgViewSettingItems) { v in
                        fieldName = v
                        if self.isCurrentPlan {
                            self.BEO.setBoardBgView(boardName: v)
                            realmInstance.safeWrite { r in
                                self.activityPlan.backgroundView = v
                                r.add(self.activityPlan)
                            }
                        }
                    }
                    
                    Text("Line Color: \(lineColor.uiColor.accessibilityName)")
                    ColorListPicker() { color in
                        lineColor = color
                        if self.isCurrentPlan {
                            self.BEO.setFieldLineColor(colorIn: color)
                            if let c = color.toRGBA() {
                                realmInstance.safeWrite { r in
                                    self.activityPlan.backgroundLineRed = c.red
                                    self.activityPlan.backgroundLineGreen = c.green
                                    self.activityPlan.backgroundLineBlue = c.blue
                                    self.activityPlan.backgroundLineAlpha = c.alpha
                                    r.add(self.activityPlan)
                                }
                            }
                        }
                        
                    }
                    
                    Text("Line Transparency: \(lineOpacity)")
                    Slider(
                        value: $lineOpacity,
                        in: 0.0...1.0,
                        step: 0.1,
                        onEditingChanged: { editing in
                            if !editing {
                                if self.isCurrentPlan {
                                    self.BEO.boardFieldLineAlpha = lineOpacity
                                    self.BEO.boardFieldLineColor = self.BEO.getFieldLineColor()
                                    realmInstance.safeWrite { r in
                                        self.activityPlan.backgroundLineAlpha = lineOpacity
                                        r.add(self.activityPlan)
                                    }
                                }
                            }
                        }
                    ).padding()
                    
                    Text("Line Width: \(Int(lineStroke))")
                    Slider(
                        value: $lineStroke,
                        in: 1.0...50.0,
                        step: 1,
                        onEditingChanged: { editing in
                            if !editing {
                                if self.isCurrentPlan {
                                    self.BEO.boardFeildLineStroke = lineStroke
                                    realmInstance.safeWrite { r in
                                        self.activityPlan.backgroundLineStroke = lineStroke
                                        r.add(self.activityPlan)
                                    }
                                }
                            }
                        }
                    ).padding()
                    
                    Section() {
                        Text("Rotate Field: \(Int(fieldRotation))")
                        Slider(
                            value: $fieldRotation,
                            in: 0...360,
                            step: 45,
                            onEditingChanged: { editing in
                                if !editing {
                                    if self.isCurrentPlan {
                                        self.BEO.boardFeildRotation = fieldRotation
                                        realmInstance.safeWrite { r in
                                            self.activityPlan.backgroundRotation = fieldRotation
                                            r.add(self.activityPlan)
                                        }
                                    }
                                    
                                }
                            }
                        ).padding()
                    }
                    
                    
                }.padding(.leading)
                
                
            }.clearSectionBackground()
            
            // BUTTONS
            Section {
                
                // LOAD BUTTON
                if self.boardId != "new" {
                    solButton(title: "Load Activity onto Board", action: {
                        runLoading()
                        CodiChannel.SESSION_ON_ID_CHANGE.send(value: SessionChange(sessionId: self.sessionId, activityId: self.boardId))
                        self.isCurrentPlan = true
                    }, isEnabled: !self.isCurrentPlan)
                }
                
                // SAVE BUTTON
                solButton(title: "Save", action: {
                    // Implement the save action
                    runLoading()
                    if self.boardId == "new" {
                        saveNewActivityPlan()
                    } else {
                        updateActivityPlan()
                    }
                    isShowing = false
                })
                
            }.clearSectionBackground()
            
        }
        .onAppear {
            
            if self.boardId != "new" {
                fetchSessionPlan()
            }
            
            CodiChannel.SESSION_ON_ID_CHANGE.receive(on: RunLoop.main) { sc in
                let temp = sc as! SessionChange
                if temp.activityId == self.boardId {
                    self.isCurrentPlan = true
                } else {
                    self.isCurrentPlan = false
                }
            }.store(in: &cancellables)
        }
        .refreshable {
            if self.boardId != "new" {
                startLoadingProcess()
                fetchSessionPlan()
            }
        }
        .navigationBarTitle(isCurrentPlan ? "Current Activity" : "Activity Plan", displayMode: .inline)
        .navigationBarItems(trailing: HStack {
            Button(action: {
                // Delete View
                print("Trash")
                startLoadingProcess()
                if let temp = realmInstance.findByField(ActivityPlan.self, field: "id", value: self.boardId) {
                    activityPlan = ActivityPlan()
                    realmInstance.safeWrite { r in
                        r.delete(temp)
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }
            }) {
                Image(systemName: "trash")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
        })
    }
    
    private func fetchSessionPlan() {
        if let ap = realmInstance.findByField(ActivityPlan.self, value: self.boardId) {
            self.activityPlan = ap
            self.boardId = ap.id
            self.lineStroke = ap.backgroundLineStroke
            self.lineOpacity = ap.backgroundLineAlpha
            self.colorOpacity = ap.backgroundAlpha
            self.fieldRotation = ap.backgroundRotation
            self.fieldName = ap.backgroundView
            if self.BEO.currentActivityId == self.activityPlan.id {
                self.isCurrentPlan = true
            }
        }
    }
    
    func startLoadingProcess() {
        isLoading = true
        // Simulate a network request or some processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            showCompletion = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showCompletion = false
            }
        }
    }
    
    func saveNewActivityPlan() {
        // New Activity
        let newAP = ActivityPlan()
        newAP.sessionId = sessionId
        newAP.orderIndex = 0
        
        newAP.title = self.activityPlan.title
        newAP.subTitle = self.activityPlan.subTitle
        newAP.duration = self.activityPlan.duration
        newAP.dateOf = self.activityPlan.dateOf
        newAP.ageLevel = self.activityPlan.ageLevel
        newAP.timePeriod = self.activityPlan.timePeriod
        newAP.activityDetails = self.activityPlan.activityDetails
        newAP.objectiveDetails = self.activityPlan.objectiveDetails
        
        newAP.backgroundView = fieldName
        newAP.backgroundRotation = fieldRotation
        newAP.backgroundLineStroke = lineStroke
        
        if let c = bgColor.toRGBA() {
            newAP.backgroundRed = c.red
            newAP.backgroundGreen = c.green
            newAP.backgroundBlue = c.blue
            newAP.backgroundAlpha = c.alpha
        }
        
        if let lc = lineColor.toRGBA() {
            newAP.backgroundLineRed = lc.red
            newAP.backgroundLineGreen = lc.green
            newAP.backgroundLineBlue = lc.blue
            newAP.backgroundLineAlpha = lc.alpha
        }

        realmInstance.safeWrite { r in
            r.add(newAP)
        }
        // TODO: Firebase
        if let us = realmInstance.getCurrentUserSession() {
            if us.membership > 0 {
                // TODO
                firebaseDatabase { db in
                    db.child(DatabasePaths.activityPlan.rawValue)
                        .child(newAP.id)
                        .setValue(newAP.toDict())
                }
            }
        }
        
    }
    
    func updateActivityPlan() {
        realmInstance.safeWrite { r in
            r.add(self.activityPlan)
        }
    }
    

}

