//
//  SessionPlanOverview.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/2/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct SessionPlanOverview: View {
    @State var sessionPlans: [SessionPlan] = []
    let realmInstance = realm()
    
    @State private var isLoading: Bool = false
    @State private var sessionNotificationToken: NotificationToken? = nil
    @State private var showNewPlanSheet = false

    var body: some View {
        Form {
            Section(header: Text("Manage")) {
                solButton(title: "New Session", action: {
                    print("New Session Button")
                    showNewPlanSheet = true
                })
            }.clearSectionBackground()
            Section(header: Text("Sessions")) {
                List(sessionPlans) { sessionPlan in
                    NavigationLink(destination: SessionPlanView(sessionId: sessionPlan.id, isShowing: .constant(true), isMasterWindow: false)) {
                        SessionPlanThumbView(sessionPlan: sessionPlan)
                    }
                }
            }.clearSectionBackground()

        }
        .onAppear() {
            observeSessions()
        }
        .loading(isShowing: $isLoading)
        .navigationBarTitle("Session Plans", displayMode: .inline)
        .sheet(isPresented: $showNewPlanSheet) {
            SessionPlanView(sessionId: "new", isShowing: $showNewPlanSheet, isMasterWindow: false)
        }
    }
    
    func observeSessions() {
        let umvs = realmInstance.objects(SessionPlan.self)
        sessionNotificationToken = umvs.observe { (changes: RealmCollectionChange) in
            isLoading = true
            switch changes {
                case .initial(let results):
                    print("Realm Listener: initial")
                    for i in results {
                        sessionPlans.safeAdd(i)
                    }
                    isLoading = false
                case .update(let results, let de, _, _):
                    print("Realm Listener: update")
                    for i in results {
                        sessionPlans.safeAdd(i)
                    }
                    for d in de {
                        sessionPlans.remove(at: d)
                    }
                    isLoading = false
                case .error(let error):
                    print("Realm Listener: error")
                    isLoading = false
                    fatalError("\(error)")  // Handle errors appropriately in production code
            }
        }
    }
}
