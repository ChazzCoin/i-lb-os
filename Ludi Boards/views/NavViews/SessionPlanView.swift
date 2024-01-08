//
//  SessionPlanView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import SwiftUI
import RealmSwift
import Combine

struct SessionPlanView: View {
    @State var sessionId: String
    @Binding var isShowing: Bool
    @State var isMasterWindow: Bool
    @State private var sport = "soccer"
    @State private var title = "SOL Session"
    @State private var description = ""
    @State private var objective = ""
    @State private var isOpen = true
    @State private var activities: [ActivityPlan] = []
    @State private var showNewActivity = false
    @State private var showShareSheet = false
    
    @State private var shareIds: [String] = []
    
    @EnvironmentObject var BEO: BoardEngineObject
    @State private var isLoading = false
    @State private var showCompletion = false
    @State private var isCurrentPlan = false
    @State private var sessionNotificationToken: NotificationToken? = nil
    @State var cancellables = Set<AnyCancellable>()
    let realmInstance = realm()

    func runLoadingProcess() {
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

    var body: some View {
        
        LoadingForm(isLoading: $isLoading, showCompletion: $showCompletion) { runLoading in
            Section(header: Text("Details")) {
                TextField("Title", text: $title)
                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                Section(header: Text("Objective")) {
                    TextEditor(text: $objective)
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                
            }

            Section(header: Text("Activities")) {
                ActivityPlanListView(activityPlans: $activities).environmentObject(self.BEO)
                
                if self.sessionId != "new" {
                    solButton(title: "New Activity", action: {
                        print("New Activity Button")
                        showNewActivity = true
                    })
                }
            }.clearSectionBackground()

            Section {
                Toggle("Is Open", isOn: $isOpen)
            }
            
            // Save button at the bottom
            Section {
                
                if self.sessionId != "new" {
                    solButton(title: "Load Session", action: {
                        runLoading()
                        CodiChannel.SESSION_ON_ID_CHANGE.send(value: SessionChange(sessionId: sessionId, activityId: self.activities.first?.id ?? "nil"))
                        isCurrentPlan = true
                    }, isEnabled: !self.isCurrentPlan)
                }
                
                solButton(title: "Save", action: {
                    print("save button")
                    runLoading()
                    if self.sessionId == "new" {
                        saveNewSessionPlan()
                    } else {
                        updateSessionPlan()
                    }
                    isShowing = false
                })
                
                if self.sessionId == "new" {
                    solButton(title: "Cancel", action: {
                        self.isShowing = false
                    }, isEnabled: self.isShowing)
                } else {
                    
                    if !self.shareIds.contains(self.sessionId) {
                        solButton(title: "Share Session", action: {
                            self.showShareSheet = true
                        }, isEnabled: true)
                        
                        if sessionId != "SOL-LIVE-DEMO" {
                            solButton(title: "Delete", action: {
                                runLoading()
                                deleteSessionPlan()
                            })
                        }
                    }
                }                
            }.clearSectionBackground()
        }
        .onAppear {
            if self.sessionId != "new" {
                fetchSessionPlan()
            }
            getShareIds()
        }
        
        .navigationBarTitle(isCurrentPlan ? "Current Plan" : "Session Plan", displayMode: .inline)
//        .navigationBarItems(trailing: Button("Cancel") {
//            isShowing = false
//        })
//        .navigationBarItems(trailing: HStack {
//            Button(action: {
//                print("Minimize")
//                CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: MenuBarProvider.boardDetails.tool.title, stateAction: "close"))
//            }) {
//                Image(systemName: "minus")
//                    .resizable()
//                    .frame(width: 30, height: 30)
//            }
//        })
        .sheet(isPresented: self.$showNewActivity) {
            ActivityPlanView(boardId: "new", sessionId: sessionId, isShowing: $showNewActivity)
        }
        .sheet(isPresented: self.$showShareSheet) {
            AddBuddyView(isPresented: self.$showShareSheet, sessionId: self.sessionId)
        }
        .refreshable {
            if self.sessionId != "new" {
                runLoadingProcess()
                fetchSessionPlan()
            }
        }
    }
    
    func getShareIds() {
        safeFirebaseUserId() { userId in
            let umvs = realmInstance.objects(UserToSession.self).filter("guestId == %@", userId)
            for i in umvs {
                self.shareIds.append(i.sessionId)
            }
        }
    }
    
    func deleteSessionPlan() {
        if let sess = realmInstance.findByField(SessionPlan.self, value: self.sessionId) {
            realmInstance.safeWrite { r in
                r.delete(sess)
            }
            // TODO: FIREBASE ONLY
            deleteSessionPlanFromFirebase(spId: self.sessionId)
        }
    }
    
    func deleteSessionPlanFromFirebase(spId: String) {
        firebaseDatabase { db in
            db.child(DatabasePaths.sessionPlan.rawValue)
                .child(spId)
                .removeValue()
        }
    }
    
    func saveNewSessionPlan() {
        // New Plan
        let newSP = SessionPlan()
        newSP.id = UUID().uuidString
        newSP.title = title
        newSP.sessionDetails = description
        newSP.objectiveDetails = objective
        newSP.isOpen = isOpen
        newSP.ownerId = CURRENT_USER_ID
        // New Activity
        let newAP = ActivityPlan()
        newAP.sessionId = newSP.id
        newAP.title = "\(title) Activity"
        newAP.orderIndex = 0
        newAP.isOpen = isOpen
        
        realmInstance.safeWrite { r in
            r.create(SessionPlan.self, value: newSP, update: .all)
            r.create(ActivityPlan.self, value: newAP, update: .all)
        }
        
        // TODO: Firebase
        saveSessionPlanToFirebase(sp: newSP)
        saveActivityPlanToFirebase(ap: newAP)
    }
    
    func saveSessionPlanToFirebase(sp: SessionPlan) {
        firebaseDatabase { db in
            db.child(DatabasePaths.sessionPlan.rawValue)
                .child(sp.id)
                .setValue(sp.toDict())
        }
    }
    
    func saveActivityPlanToFirebase(ap: ActivityPlan) {
        firebaseDatabase { db in
            db.child(DatabasePaths.activityPlan.rawValue)
                .child(ap.id)
                .setValue(ap.toDict())
        }
    }
    
    func updateSessionPlan() {
        if let sp = realmInstance.findByField(SessionPlan.self, value: self.sessionId) {
            realmInstance.safeWrite { r in
                sp.title = title
                sp.sessionDetails = description
                sp.objectiveDetails = objective
                sp.isOpen = isOpen
            }
            saveSessionPlanToFirebase(sp: sp)
            
        }
    }
    
    func fetchSessionPlan() {
        print("BEO SessionId: \(self.BEO.currentSessionId)")
        if self.isMasterWindow {
            self.sessionId = self.BEO.currentSessionId
            self.isCurrentPlan = true
        } else if self.BEO.currentSessionId == self.sessionId {
            self.isCurrentPlan = true
        }
        
        fireGetSessionPlanAsync(sessionId: self.sessionId, realm: self.realmInstance)
        fireGetActivitiesBySessionId(sessionId: self.sessionId, realm: self.realmInstance)
        
        if let sp = realmInstance.findByField(SessionPlan.self, value: self.sessionId) {
            title = sp.title
            description = sp.sessionDetails
            objective = sp.objectiveDetails
            isOpen = sp.isOpen
            if sp.ownerId != self.BEO.userId {
                self.BEO.isShared = true
            }
        }
        if let acts = realmInstance.findAllByField(ActivityPlan.self, field: "sessionId", value: self.sessionId) {
            if acts.isEmpty {return}
            var temp: [ActivityPlan] = []
            for i in acts {
                temp.append(i)
            }
            activities = temp
        }
    }
    

}

struct ClearBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.clear)
            .listRowBackground(Color.clear)
    }
}

extension View {
    func clearSectionBackground() -> some View {
        self.modifier(ClearBackgroundModifier())
    }
}


struct InputFieldA: View {
    var label: String
    @Binding var value: String
    var onValueChange: (String) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
            TextField("", text: $value, onEditingChanged: { _ in onValueChange(value) })
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct InputTextEditorA: View {
    var label: String
    @Binding var value: String
    var onValueChange: (String) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
            TextEditor(text: $value)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .onAppear {
                    onValueChange(value)
                }
        }
    }
}




//struct BoardSessionDetailsForm_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionPlanView(sessionId: "SOL", isShowing: .constant(true), isMasterWindow: true)
//    }
//}

