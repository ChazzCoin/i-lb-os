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
struct ActivityPlanSingleView: View {

    @Binding var inComingAP: ActivityPlan
    @Binding var sessionId: String
    @Binding var isShowing: Bool
    @EnvironmentObject var BEO: BoardEngineObject
    @EnvironmentObject var NavStack: NavStackWindowObservable
    @Environment(\.presentationMode) var presentationMode
    @State var isLoading: Bool = false
    @State var realmInstance = realm()
    
    @State var confirmationPopupIsShowing = false
    
    @State var activityId = ""
    @State var title = ""
    @State var subTitle = ""
    @State var date = ""
    
    @State var timePeriod = ""
    @State var duration = ""
    @State var ageLevel = ""
    
    @State var objectiveDetails = ""
    @State var activityDetails = ""
    @State var backgroundView = ""
    
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
    
    @State var showShareSheet = false
    @State var cancellables = Set<AnyCancellable>()

    func resetView() {
        refreshView = true
        refreshView = false
    }
    
    var body: some View {
        
        Form {
        
            DStack {
                // SAVE BUTTON
                SolConfirmButton(
                    title: "Save Activity",
                    message: "Would you like to save this activity?",
                    action: {
                        saveActivityPlan()
                        isShowing = false
                    }
                ).zIndex(2.0)
            
                if self.sessionId != "SOL-LIVE-DEMO" && self.sessionId != "SOL" && self.activityId != "new" {
                    // Delete BUTTON
                    SolConfirmButton(
                        title: "Delete Activity",
                        message: "Would you like to delete this activity?",
                        action: {
                            startLoadingProcess()
                            if let item = realmInstance.findByField(ActivityPlan.self, field: "id", value: self.activityId) {
                                realmInstance.safeWrite { r in
                                    item.isDeleted = true
                                }
                                // TODO: FIREBASE ONLY
                                deleteActivityPlanFromFirebase(apId: self.activityId)
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    ).zIndex(2.0)
                }
            
                if self.activityId != "new" {
                    SolConfirmButton(
                        title: "Load Activity onto Board",
                        message: "Would you like to load this activity?",
                        action: {
                            CodiChannel.SESSION_ON_ID_CHANGE.send(value: SessionChange(sessionId: self.sessionId, activityId: self.activityId))
                            self.isCurrentPlan = true
                        },
                        isEnabled: !self.isCurrentPlan
                    ).zIndex(2.0)
                }
                
            }
            .zIndex(1.0)
            .clearSectionBackground()
            
            // Details Section
            Section(header: AlignLeft { HeaderText("Activity Details") }) {
                
                DStack {
                    SolTextField("Title", text: $title)
                    SolTextField("Sub Title", text: $subTitle)
                }
                
                DStack {
                    SolTextField("Date", text: $date)
                    SolTextField("Time Period", text: $timePeriod)
                }
                
                DStack {
                    SolTextField("Duration", text: $duration)
                    SolTextField("Age Level", text: $ageLevel)
                }
                
                DStack {
                    SolTextEditor("Objective", text: $objectiveDetails)
                        .padding()
                        .frame(minHeight: 100)
                    
                    SolTextEditor("Description", text: $activityDetails)
                        .padding()
                        .frame(minHeight: 100)
                }
                
            }.clearSectionBackground()

            Section(header: AlignLeft { HeaderText("Board Settings") }) {
                AlignLeft {
                    SubHeaderText("Field Type: \(fieldName)")
                        .padding()
                }
                BarListPicker(initialSelected: self.isCurrentPlan ? self.BEO.boardBgName : self.backgroundView, viewBuilder: self.BEO.boards.getAllMinis()) { v in
                    fieldName = v
                    if self.isCurrentPlan {
                        self.BEO.setBoardBgView(boardName: v)
                    }
                }
                .padding()
                .border(Color.secondaryBackground, width: 1.0)
                .cornerRadius(8)
                .shadow(color: .gray, radius: 10, x: 0, y: 0)
                .padding()
                
                DStack {
                    VStack {
                        AlignLeft {
                            SubHeaderText("Background Color: \(colorOpacity)")
                                .padding()
                        }
                        ColorListPicker() { color in
                            bgColor = color
                            if self.isCurrentPlan {
                                self.BEO.setColor(colorIn: color)
                            }
                            
                        }
                    }
                    .border(Color.secondaryBackground, width: 1.0)
                    .cornerRadius(8)
                    .shadow(color: .gray, radius: 10, x: 0, y: 0)
                    .padding()
                    
                    VStack {
                        AlignLeft {
                            SubHeaderText("Background Color Transparency: \(colorOpacity)")
                                .padding()
                        }
                        Slider(
                            value: $colorOpacity,
                            in: 0.0...1.0,
                            step: 0.1,
                            onEditingChanged: { editing in
                                if !editing {
                                    if self.isCurrentPlan {
                                        self.BEO.boardBgAlpha = colorOpacity
                                        self.BEO.boardBgColor = self.BEO.getColor()
                                    }
                                    
                                }
                            }
                        )
                        .padding()
                    }
                    .border(Color.secondaryBackground, width: 1.0)
                    .cornerRadius(8)
                    .shadow(color: .gray, radius: 10, x: 0, y: 0)
                    .padding()
                    
                }
                
                DStack {
                    VStack {
                        AlignLeft {
                            SubHeaderText("Line Color: \(lineColor.uiColor.accessibilityName)")
                                .padding()
                        }
                        ColorListPicker() { color in
                            lineColor = color
                            if self.isCurrentPlan {
                                self.BEO.setFieldLineColor(colorIn: color)
                            }
                            
                        }
                    }
                    .border(Color.secondaryBackground, width: 1.0)
                    .cornerRadius(8)
                    .shadow(color: .gray, radius: 10, x: 0, y: 0)
                    .padding()
                    
                    VStack {
                        AlignLeft {
                            SubHeaderText("Rotate Field: \(Int(fieldRotation))")
                                .padding()
                        }
                        Slider(
                            value: $fieldRotation,
                            in: 0...360,
                            step: 45,
                            onEditingChanged: { editing in
                                if !editing {
                                    if self.isCurrentPlan {
                                        self.BEO.boardFeildRotation = fieldRotation
                                    }
                                    
                                }
                            }
                        ).padding()
                    }
                    .border(Color.secondaryBackground, width: 1.0)
                    .cornerRadius(8)
                    .shadow(color: .gray, radius: 10, x: 0, y: 0)
                    .padding()
                    
                }
                
                DStack {
                    
                    VStack {
                        AlignLeft {
                            SubHeaderText("Line Width: \(Int(lineStroke))")
                                .padding()
                        }
                        Slider(
                            value: $lineStroke,
                            in: 1.0...50.0,
                            step: 1,
                            onEditingChanged: { editing in
                                if !editing {
                                    if self.isCurrentPlan {
                                        self.BEO.boardFeildLineStroke = lineStroke
                                    }
                                }
                            }
                        ).padding()
                    }
                    .border(Color.secondaryBackground, width: 1.0)
                    .cornerRadius(8)
                    .shadow(color: .gray, radius: 10, x: 0, y: 0)
                    .padding()
                    
                    
                    VStack {
                        AlignLeft {
                            SubHeaderText("Line Transparency: \(lineOpacity)")
                                .padding()
                        }
                        Slider(
                            value: $lineOpacity,
                            in: 0.0...1.0,
                            step: 0.1,
                            onEditingChanged: { editing in
                                if !editing {
                                    if self.isCurrentPlan {
                                        self.BEO.boardFieldLineAlpha = lineOpacity
                                        self.BEO.boardFieldLineColor = self.BEO.getFieldLineColor()
                                    }
                                }
                            }
                        ).padding()
                    }
                    .border(Color.secondaryBackground, width: 1.0)
                    .cornerRadius(8)
                    .shadow(color: .gray, radius: 10, x: 0, y: 0)
                    .padding()
                       
                }
                
            }.clearSectionBackground()
                    

        }
        .onChange(of: self.inComingAP) { newPlan in
            DispatchQueue.main.async {
                self.fetchActivityPlan(activityPlan: newPlan)
            }
        }
        .onAppear {
            self.fetchActivityPlan(activityPlan: self.inComingAP)
            self.BEO.windowIsOpen = true
        }
        

    }
    
    private func fetchActivityPlan(activityPlan: ActivityPlan) {
        
        self.activityId = activityPlan.id
        
        self.title = activityPlan.title
        self.subTitle = activityPlan.subTitle
        self.date = activityPlan.dateOf
        self.activityDetails = activityPlan.activityDetails
        
        self.ageLevel = activityPlan.ageLevel
        self.timePeriod = activityPlan.timePeriod
        self.activityDetails = activityPlan.activityDetails
        self.objectiveDetails = activityPlan.objectiveDetails
        
        self.lineStroke = activityPlan.backgroundLineStroke
        self.lineOpacity = activityPlan.backgroundLineAlpha
        self.colorOpacity = activityPlan.backgroundAlpha
        self.fieldRotation = activityPlan.backgroundRotation
        self.fieldName = activityPlan.backgroundView
        if self.BEO.currentActivityId == self.activityId {
            self.isCurrentPlan = true
        } else {
            self.isCurrentPlan = false
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
    
    func saveActivityPlan() {
        if self.activityId == "new" {
            saveNewActivityPlan()
        } else {
            saveCurrentActivityPlan()
        }
    }
    
    func saveCurrentActivityPlan() {
        
        if let currentAp = self.realmInstance.findByField(ActivityPlan.self, value: self.activityId) {
            self.realmInstance.safeWrite { _ in
                currentAp.sessionId = self.sessionId
                currentAp.orderIndex = 0
                
                currentAp.ownerId = getFirebaseUserId() ?? "SOL"
                
                currentAp.title = title
                currentAp.subTitle = subTitle
                currentAp.duration = duration
                currentAp.dateOf = date
                currentAp.ageLevel = ageLevel
                currentAp.timePeriod = timePeriod
                currentAp.activityDetails = activityDetails
                currentAp.objectiveDetails = objectiveDetails
                
                currentAp.backgroundView = fieldName
                currentAp.backgroundRotation = fieldRotation
                currentAp.backgroundLineStroke = lineStroke
                
                if let c = bgColor.toRGBA() {
                    currentAp.backgroundRed = c.red
                    currentAp.backgroundGreen = c.green
                    currentAp.backgroundBlue = c.blue
                    currentAp.backgroundAlpha = c.alpha
                }
                
                if let lc = lineColor.toRGBA() {
                    currentAp.backgroundLineRed = lc.red
                    currentAp.backgroundLineGreen = lc.green
                    currentAp.backgroundLineBlue = lc.blue
                    currentAp.backgroundLineAlpha = lc.alpha
                }
                
                // TODO: Firebase Users ONLY
                updateInFirebase(newAP: currentAp)
            }
        }
        
        
    }
    
    func saveNewActivityPlan() {
        // New Activity
        let newAP = ActivityPlan()
        
        newAP.sessionId = self.sessionId
        newAP.orderIndex = 0
        
        newAP.ownerId = getFirebaseUserId() ?? "SOL"
        
        newAP.title = title
        newAP.subTitle = subTitle
        newAP.duration = duration
        newAP.dateOf = date
        newAP.ageLevel = ageLevel
        newAP.timePeriod = timePeriod
        newAP.activityDetails = activityDetails
        newAP.objectiveDetails = objectiveDetails
        
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
            r.create(ActivityPlan.self, value: newAP, update: .all)
        }
        // TODO: Firebase Users ONLY
        updateInFirebase(newAP: newAP)
        
    }
    
    func updateInFirebase(newAP: ActivityPlan) {
        // TODO: Firebase Users ONLY
        self.realmInstance.safeWrite { _ in
            newAP.ownerId = getFirebaseUserId() ?? "SOL"
        }
        firebaseDatabase { db in
            db.child(DatabasePaths.activityPlan.rawValue)
                .child(newAP.id)
                .setValue(newAP.toDict())
        }
    }
    
    func updateActivityPlan() {
        realmInstance.safeWrite { r in
//            if let temp = self.activityPlan.thaw() {
//                temp.ownerId = getFirebaseUserId() ?? "SOL"
//                r.create(ActivityPlan.self, value: temp, update: .all)
//                //TODO: FIREBASE ONLY
//                updateInFirebase(newAP: temp)
//            }
            
        }
        
    }
    func deleteActivityPlanFromFirebase(apId: String) {
        firebaseDatabase { db in
            db.child(DatabasePaths.activityPlan.rawValue)
                .child(apId)
                .removeValue()
        }
    }

}

