//
//  SessionPlanOverview.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/2/23.
//

import Foundation
import SwiftUI

struct SessionPlanOverview: View {
    @State var sessionPlans: [SessionPlan] = []
    let realmInstance = realm()
    
    @State private var showNewPlanSheet = false

    var body: some View {
        Form {
            
            Section(header: Text("Manage")) {
                Button("New Session", action: {
                    print("New Session Button")
                    showNewPlanSheet = true
                })
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }.clearSectionBackground()
            Section(header: Text("Sessions")) {
                List(sessionPlans) { sessionPlan in
                    NavigationLink(destination: SessionPlanView(sessionId: sessionPlan.id, isShowing: .constant(true))) {
                        SessionPlanThumbView(sessionPlan: sessionPlan)
                    }
                }
            }.clearSectionBackground()

        }
        .onAppear() {
            let results = realmInstance.objects(SessionPlan.self)
            if results.isEmpty {return}
            sessionPlans.removeAll()
            for i in results {
                sessionPlans.append(i)
            }
        }
        .navigationBarTitle("Session Plans", displayMode: .inline)
        .sheet(isPresented: $showNewPlanSheet) {
            SessionPlanView(sessionId: "new", isShowing: $showNewPlanSheet)
        }
    }
}
