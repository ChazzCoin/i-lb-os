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
    @State var userId: String = getFirebaseUserId() ?? "SOL"
  
    @ObservedResults(UserToSession.self, where: { $0.guestId == getFirebaseUserId() ?? "" }) var guestSessions
    var sharedSessionIds: [String] {
       guestSessions.map { $0.sessionId }
    }
    @ObservedResults(SessionPlan.self) var sessionPlans
    var hostedSessionPlans: Results<SessionPlan> {
        return self.sessionPlans.filter("NOT id IN %@", self.sharedSessionIds)
    }
    var sharedSessionPlans: Results<SessionPlan> {
        return self.sessionPlans.filter("id IN %@", self.sharedSessionIds)
    }
    
    let realmInstance = realm()
    
    @State private var liveDemoNotificationToken: NotificationToken? = nil
    
    @State private var isLoading: Bool = false
    @State private var sessionNotificationToken: NotificationToken? = nil
    @State private var sessionSharesNotificationToken: NotificationToken? = nil
    @State private var sharesNotificationToken: NotificationToken? = nil
    @State private var showNewPlanSheet = false
    
    @State private var isLoggedIn = false

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

            if userIsVerifiedToProceed() {
                Section(header: Text("Shared Sessions")) {
                    List(sharedSessionPlans, id: \.self) { sessionPlan in
                        
                        NavigationLink(destination: SessionPlanView(sessionId: sessionPlan.id, isShowing: .constant(true), isMasterWindow: false)) {
                            SessionPlanThumbView(sessionPlan: sessionPlan)
                        }

                    }
                }.clearSectionBackground()
            }
            
        }
        .onAppear() {
            fetchAllSessionsFromFirebase()
        }
        .onDisappear() {
            
        }
        .loading(isShowing: $isLoading)
        .navigationBarTitle("Session Plans", displayMode: .inline)
        .sheet(isPresented: $showNewPlanSheet) {
            SessionPlanView(sessionId: "new", isShowing: $showNewPlanSheet, isMasterWindow: false)
        }
        .refreshable {
            fetchAllSessionsFromFirebase()
        }
    }
    
    func fetchAllSessionsFromFirebase() {
        FirebaseSessionPlanService.runFullFetchProcess(realm: self.realmInstance)
    }
    
}
