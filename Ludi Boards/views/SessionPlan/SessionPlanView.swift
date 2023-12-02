//
//  SessionPlanView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import SwiftUI
import Combine

struct SessionPlanView: View {
    @State var sessionId: String
    @Binding var isShowing: Bool
    @State private var sport = "soccer"
    @State private var title = "SOL Session"
    @State private var description = ""
    @State private var objective = ""
    @State private var isOpen = true
    @State private var activities: [ActivityPlan] = []
    @State private var showNewActivity = false
    
    
    @State var cancellables = Set<AnyCancellable>()
    let realmInstance = realm()

    var body: some View {
        Form {
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
                ActivityPlanListView(activityPlans: $activities)
                
                if self.sessionId != "new" {
                    Button("New Activity", action: {
                        print("New Activity Button")
                        showNewActivity = true
                    })
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
            }.clearSectionBackground()

            Section {
                Toggle("Is Open", isOn: $isOpen)
            }
            
            // Save button at the bottom
            Section {
                if self.sessionId != "new" {
                    Button("Load Session", action: {
                        CodiChannel.SESSION_ON_ID_CHANGE.send(value: SessionChange(sessionId: sessionId))
                    })
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button("Save", action: {
                    print("save button")
                    if self.sessionId == "new" {
                        saveNewSessionPlan()
                    } else {
                        updateSessionPlan()
                    }
                    isShowing = false
                })
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }.clearSectionBackground()
        }
        .onAppear {
            if self.sessionId != "new" {
                fetchSessionPlan()
            }
        }
        .navigationBarTitle("Session Plan", displayMode: .inline)
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
            ActivityPlanView(boardId: "new")
        }.onAppear() {
            CodiChannel.SESSION_ON_ID_CHANGE.receive(on: RunLoop.main) { sc in
                let temp = sc as! SessionChange
                  
                if let sID = temp.sessionId {
                    if sID != self.sessionId {
                        self.sessionId = sID
                        fetchSessionPlan()
                    }
                }
                
            }.store(in: &cancellables)
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
        
        realmInstance.safeWrite { r in
            r.add(newSP)
            r.add(newAP)
        }
        
        // TODO: Firebase
    }
    
    func updateSessionPlan() {
        if let sp = realmInstance.findByField(SessionPlan.self, value: self.sessionId) {
            sp.title = title
            sp.sessionDetails = description
            sp.objectiveDetails = objective
            sp.isOpen = isOpen
            realmInstance.safeWrite { r in
                r.add(sp)
            }
        }
    }
    
    private func fetchSessionPlan() {
        if let sp = realmInstance.findByField(SessionPlan.self, value: self.sessionId) {
            title = sp.title
            description = sp.sessionDetails
            objective = sp.objectiveDetails
            isOpen = sp.isOpen
        }
        if let acts = realmInstance.findAllByField(ActivityPlan.self, field: "sessionId", value: self.sessionId) {
            if acts.isEmpty {return}
            activities.removeAll()
            for i in acts {
                activities.append(i)
            }
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




struct BoardSessionDetailsForm_Previews: PreviewProvider {
    static var previews: some View {
        SessionPlanView(sessionId: "SOL", isShowing: .constant(true))
    }
}

