//
//  SessionPlanView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import SwiftUI

struct SessionPlanView: View {
    var sessionId: String
    @State private var sport = "soccer"
    @State private var title = "SOL Session"
    @State private var description = ""
    @State private var objective = ""
    @State private var isOpen = true
    @State private var activities: [ActivityPlan] = []
    
    let realmInstance = realm()
    private func fetchSessionPlan() {
        if let sp = realmInstance.findByField(SessionPlan.self, value: self.sessionId) {
            title = sp.title
            description = sp.sessionDetails
            objective = sp.objectiveDetails
        }
        if let acts = realmInstance.findAllByField(ActivityPlan.self, field: "sessionId", value: self.sessionId) {
            if acts.isEmpty {return}
            activities.removeAll()
            for i in acts {
                activities.append(i)
            }
        }
    }

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
                Button("New Activity", action: {
                    print("New Activity Button")
                })
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }.clearSectionBackground()

            Section {
                Toggle("Is Open", isOn: $isOpen)
            }
            
            // Save button at the bottom
            Section {
                Button("Load Session", action: {
                    CodiChannel.SESSION_ON_ID_CHANGE.send(value: sessionId)
                })
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                Button("Save", action: {
                    print("save button")
                })
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }.clearSectionBackground()
        }
        .onAppear {
            fetchSessionPlan()
        }
        .navigationBarTitle("Session Plan", displayMode: .inline)
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
        SessionPlanView(sessionId: "SOL")
    }
}

