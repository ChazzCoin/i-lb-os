//
//  ActivityPlanView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import SwiftUI

// ActivityPlan View
struct ActivityPlanView: View {
    var boardId: String
    var sessionId: String
    @Binding var isShowing: Bool
    @Environment(\.presentationMode) var presentationMode
    @State var isLoading: Bool = false
    @State private var activityPlan: ActivityPlan = ActivityPlan() // Use StateObject for lifecycle management
    var realmInstance = realm()
    
    @State private var showLoading = false
    @State private var showCompletion = false
    @State private var isCurrentPlan = false
    
    private func fetchSessionPlan() {
        if let ap = realmInstance.findByField(ActivityPlan.self, value: self.boardId) {
            activityPlan = ap
            let actId = SharedPrefs.shared.retrieve("activityId", defaultValue: "nil")
            if actId == ap.id {
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
                TextEditor(text: $activityPlan.objectiveDetails)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }

            // Objective Section
            Section(header: Text("Objective")) {
                TextEditor(text: $activityPlan.activityDetails)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
            
            Section(header: Text("Boards")) {
                ThumbnailListView() { item in
                    
                }
            }.clearSectionBackground()

            // Save Button Section
            Section {
                if self.boardId != "new" {
                    solButton(title: "Load Activity onto Board", action: {
                        runLoading()
                        CodiChannel.SESSION_ON_ID_CHANGE.send(value: SessionChange(sessionId: self.activityPlan.sessionId, activityId: self.activityPlan.id))
                    }, isEnabled: !self.isCurrentPlan)
                }
                
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
        .onAppear { fetchSessionPlan() }
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            showCompletion = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showCompletion = false
            }
        }
    }
    
    func saveNewActivityPlan() {
        // New Activity
        let sessId = SharedPrefs.shared.retrieve("sessionId", defaultValue: "nil")
        let newAP = ActivityPlan()
        
        if boardId == "new" {
            newAP.sessionId = sessionId
        } else {
            newAP.sessionId = sessId
        }
        
        newAP.orderIndex = 0
        
        realmInstance.safeWrite { r in
            r.add(newAP)
        }
        
        // TODO: Firebase
        
    }
    
    func updateActivityPlan() {
        realmInstance.safeWrite { r in
            r.add(self.activityPlan)
        }
    }
}




//struct ActivityDetailsForm_Previews: PreviewProvider {
//    static var previews: some View {
////        ActivityPlanView(boardId: "123", isShowing: .constant(true))
//    }
//}
