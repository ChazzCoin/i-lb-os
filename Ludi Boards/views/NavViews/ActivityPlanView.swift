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
//    @State var boardId: String
//    @State var sessionId: String
    @Binding var activityPlan: ActivityPlan
    @Binding var isShowing: Bool
    @EnvironmentObject var BEO: BoardEngineObject
    @EnvironmentObject var NavStack: NavStackWindowObservable
    @Environment(\.presentationMode) var presentationMode
    @State var isLoading: Bool = false
//    @State private var activityPlan: ActivityPlan = ActivityPlan() // Use StateObject for lifecycle management
    @State var realmInstance = realm()
    
    @State var confirmationPopupIsShowing = false
    
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

    var body: some View {
        
//        LoadingForm(isLoading: $isLoading, showCompletion: $showCompletion) { runLoading in
        
        VStack {
        
            DStack {
                // SAVE BUTTON
                SolConfirmButton(
                    title: "Save Activity",
                    message: "Would you like to save this plan?",
                    action: {
//                        runLoading()
                        if self.activityPlan.id == "new" {
                            saveNewActivityPlan()
                        } else {
                            updateActivityPlan()
                        }
                        isShowing = false
                    }
                ).zIndex(2.0)
            
                if self.activityPlan.sessionId != "SOL-LIVE-DEMO" && self.activityPlan.sessionId != "SOL"{
                    // Delete BUTTON
                    SolConfirmButton(
                        title: "Delete Activity",
                        message: "Would you like to delete this plan?",
                        action: {
                            startLoadingProcess()
                            if let item = realmInstance.findByField(ActivityPlan.self, field: "id", value: self.activityPlan.id) {
                                activityPlan = ActivityPlan()
                                realmInstance.safeWrite { r in
                                    item.isDeleted = true
                                }
                                // TODO: FIREBASE ONLY
                                deleteActivityPlanFromFirebase(apId: self.activityPlan.id)
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    ).zIndex(2.0)
                }
            
                if self.activityPlan.id != "new" {
                    SolButton(
                        title: "Load Activity onto Board",
                        
                        action: {
//                            runLoading()
                            CodiChannel.SESSION_ON_ID_CHANGE.send(value: SessionChange(sessionId: self.activityPlan.sessionId, activityId: self.activityPlan.id))
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
                    SolTextField("Title", text: $activityPlan.title)
                    SolTextField("Sub Title", text: $activityPlan.subTitle)
                }
                
                DStack {
                    SolTextField("Date", text: $activityPlan.dateOf)
                    SolTextField("Time Period", text: $activityPlan.timePeriod)
                }
                
                DStack {
                    SolTextField("Duration", text: $activityPlan.duration)
                    SolTextField("Age Level", text: $activityPlan.ageLevel)
                }
                
                DStack {
                    SolTextEditor("Objective", text:$activityPlan.objectiveDetails)
                        .padding()
                        .frame(minHeight: 100)
                    
                    SolTextEditor("Description", text:$activityPlan.activityDetails)
                        .padding()
                        .frame(minHeight: 100)
                }
                
            }.clearSectionBackground()

            Section(header: AlignLeft { HeaderText("Board Settings") }) {
                AlignLeft {
                    SubHeaderText("Field Type: \(fieldName)")
                        .padding()
                }
                BarListPicker(initialSelected: self.isCurrentPlan ? self.BEO.boardBgName : self.activityPlan.backgroundView, viewBuilder: self.BEO.boards.getAllMinis()) { v in
                    fieldName = v
                    if self.isCurrentPlan {
                        self.BEO.setBoardBgView(boardName: v)
                        realmInstance.safeWrite { r in
                            if let ap = self.activityPlan.thaw() {
                                ap.backgroundView = v
                                r.add(ap)
                            }
                            
                        }
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
                                if let c = color.toRGBA() {
                                    realmInstance.safeWrite { r in
                                        if let ap = self.activityPlan.thaw() {
                                            ap.backgroundRed = c.red
                                            ap.backgroundGreen = c.green
                                            ap.backgroundBlue = c.blue
                                            ap.backgroundAlpha = c.alpha
                                            r.add(ap)
                                        }
                                        
                                    }
                                }
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
                                        realmInstance.safeWrite { r in
                                            if let ap = self.activityPlan.thaw() {
                                                ap.backgroundAlpha = colorOpacity
                                                r.add(ap)
                                            }
                                            
                                        }
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
                                if let c = color.toRGBA() {
                                    realmInstance.safeWrite { r in
                                        if let ap = self.activityPlan.thaw() {
                                            ap.backgroundLineRed = c.red
                                            ap.backgroundLineGreen = c.green
                                            ap.backgroundLineBlue = c.blue
                                            ap.backgroundLineAlpha = c.alpha
                                            r.add(ap)
                                        }
                                        
                                    }
                                }
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
                                        realmInstance.safeWrite { r in
                                            if let ap = self.activityPlan.thaw() {
                                                ap.backgroundRotation = fieldRotation
                                                r.add(ap)
                                            }
                                        }
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
                                        realmInstance.safeWrite { r in
                                            if let ap = self.activityPlan.thaw() {
                                                ap.backgroundLineStroke = lineStroke
                                                r.add(ap)
                                            }
                                        }
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
                                        realmInstance.safeWrite { r in
                                            if let ap = self.activityPlan.thaw() {
                                                ap.backgroundLineAlpha = lineOpacity
                                                r.add(ap)
                                            }
                                        }
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
//        .padding()
        .onChange(of: self.activityPlan) { _ in
            if self.BEO.currentActivityId == self.activityPlan.id {
                self.isCurrentPlan = true
            } else {
                self.isCurrentPlan = false
            }
        }
        .onAppear {
            self.BEO.windowIsOpen = true
            if self.BEO.currentActivityId == self.activityPlan.id {
                self.isCurrentPlan = true
            } else {
                self.isCurrentPlan = false
            }
        }
        .sheet(isPresented: self.$showShareSheet) {
//            AddBuddyView(isPresented: self.$showShareSheet, sessionId: self.activityPlan.$sessionId)
        }
//        .navigationBarTitle(isCurrentPlan ? "Current Activity" : "Activity Plan", displayMode: .inline)
    }
    
    private func fetchActivityPlan() {
        if let ap = realmInstance.findByField(ActivityPlan.self, value: self.activityPlan.id) {
            self.activityPlan = ap
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
        newAP.sessionId = self.activityPlan.sessionId
        newAP.orderIndex = 0
        
        newAP.ownerId = getFirebaseUserId() ?? "SOL"
        
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
            if let temp = self.activityPlan.thaw() {
                temp.ownerId = getFirebaseUserId() ?? "SOL"
                r.create(ActivityPlan.self, value: temp, update: .all)
                //TODO: FIREBASE ONLY
                updateInFirebase(newAP: temp)
            }
            
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

