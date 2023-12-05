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
            }.clearSectionBackground()
        }
        .onAppear {
            if self.sessionId != "new" {
                fetchSessionPlan()
            }
        }
        .navigationBarTitle(isCurrentPlan ? "Current Plan" : "Session Plan", displayMode: .inline)
        .navigationBarItems(trailing: HStack {
            Button(action: {
                print("Minimize")
                CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: MenuBarProvider.boardDetails.tool.title, stateAction: "close"))
            }) {
                Image(systemName: "minus")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
        })
        .sheet(isPresented: $showNewActivity) {
            ActivityPlanView(boardId: "new", sessionId: sessionId, isShowing: $showNewActivity)
        }
        .refreshable {
            if self.sessionId != "new" {
                runLoadingProcess()
                fetchSessionPlan()
            }
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
        // New Activity
        let newAP = ActivityPlan()
        newAP.sessionId = newSP.id
        newAP.title = "\(title) Activity"
        newAP.orderIndex = 0
        newAP.isOpen = isOpen
        
        realmInstance.safeWrite { r in
            r.add(newSP)
            r.add(newAP)
        }
        
        // TODO: Firebase
    }
    
    func updateSessionPlan() {
        if let sp = realmInstance.findByField(SessionPlan.self, value: self.sessionId) {
            realmInstance.safeWrite { r in
                sp.title = title
                sp.sessionDetails = description
                sp.objectiveDetails = objective
                sp.isOpen = isOpen
                r.add(sp)
            }
            
            if let us = realmInstance.getCurrentUserSession() {
                if us.membership > 0 {
                    // TODO
                    firebaseDatabase { db in
                        db.child(DatabasePaths.sessionPlan.rawValue)
                            .child(sessionId)
                            .setValue(sp.toDict())
                    }
                }
            }
            
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
        
        if let sp = realmInstance.findByField(SessionPlan.self, value: self.sessionId) {
            title = sp.title
            description = sp.sessionDetails
            objective = sp.objectiveDetails
            isOpen = sp.isOpen
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
    
//    func checkCurrentSessionId() {
//        if let umvs = realmInstance.findByField(CurrentSession.self, value: "SOL") {
//            if self.sessionId == umvs.sessionId {
//                self.isCurrentPlan = true
//            }
//        }
//    }
//    
//    func loadFromCurrentSession() {
//        if let umvs = realmInstance.findByField(CurrentSession.self, value: "SOL") {
//            self.sessionId = umvs.sessionId
//            self.isCurrentPlan = true
//            self.fetchSessionPlan()
//        }
//    }
    
//    func observeCurrentSession() {
//        if let umvs = realmInstance.findByField(CurrentSession.self, value: "SOL") {
//            sessionNotificationToken = umvs.observe { change in
//                switch change {
//                    case .change(let obj, _):
//                        let temp = obj as! CurrentSession
//                        if self.isMasterWindow {
//                            self.sessionId = temp.sessionId
//                            self.isCurrentPlan = true
//                            self.fetchSessionPlan()
//                            break
//                        }
//                        if temp.sessionId == self.sessionId {
//                            self.isCurrentPlan = true
//                            self.fetchSessionPlan()
//                            break
//                        }
//                        break
//                    case .deleted:
//                        // Handle deletion
//                        break
//                    case .error(let error):
//                        // Handle error
//                        print(error)
//                }
//            }
//        } 
//    }
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




struct BoardSessionDetailsForm_Previews: PreviewProvider {
    static var previews: some View {
        SessionPlanView(sessionId: "SOL", isShowing: .constant(true), isMasterWindow: true)
    }
}
