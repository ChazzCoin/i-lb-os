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
    
    @State var cancellables = Set<AnyCancellable>()
    @State private var sessionNotificationToken: NotificationToken? = nil
    
//    @State private var bgItems = [
//        { AnyView(SoccerFieldFullView(width: 100, height: 100, stroke: 2, color: Color.blue)) },
//        { AnyView(SoccerFieldHalfView(width: 100, height: 100, stroke: 2, color: Color.blue)) }
//    ]
    
    private func fetchSessionPlan() {
        if let ap = realmInstance.findByField(ActivityPlan.self, value: self.boardId) {
            self.activityPlan = ap
            self.boardId = ap.id
            if self.BEO.currentActivityId == self.activityPlan.id {
                self.isCurrentPlan = true
            }
        }
    }

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
//                ThumbnailListView() { item in
//                    
//                }
                Section(header: Text("Field Color")) {
                    ColorListPicker() { color in
                        if self.isCurrentPlan {
                            self.BEO.setColor(colorIn: color)
                        }
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
                }.padding(.leading)
                
                Section(header: Text("Field Lines")) {
                    BarListPicker(viewBuilder: self.BEO.boardBgViewSettingItems) { v in
                        if self.isCurrentPlan {
                            self.BEO.setBoardBgView(boardName: v)
                        }
                        
                        realmInstance.safeWrite { r in
                            self.activityPlan.backgroundView = v
                            r.add(self.activityPlan)
                        }
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

