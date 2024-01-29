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
    
    @EnvironmentObject var BEO: BoardEngineObject
    @EnvironmentObject var NavStack: NavStackWindowObservable
  
    @ObservedResults(UserToSession.self, where: { $0.guestId == getFirebaseUserId() ?? "" && $0.status != "removed" }) var guestSessions
    var sharedSessionIds: [String] {
        var temp = Array(guestSessions.map { $0.sessionId })
        if !temp.contains("SOL-LIVE-DEMO") {
            temp.append("SOL-LIVE-DEMO")
        }
        return temp
    }
    @ObservedResults(SessionPlan.self) var sessionPlans
    var hostedSessionPlans: Results<SessionPlan> {
        return self.sessionPlans.filter("NOT id IN %@", self.sharedSessionIds)
    }
    var sharedSessionPlans: Results<SessionPlan> {
        return self.sessionPlans.filter("id IN %@", self.sharedSessionIds)
    }
    
    let realmInstance: Realm = newRealm()
    
    @State private var isLoading: Bool = false
    @State private var showNewPlanSheet = false
    
    @State private var showNewTeamSheet = false
    @State private var showNewPlayerRefSheet = false
    
    @State private var isLoggedIn = false

    var body: some View {
        Form {
            
            Section(header: Text("Manage")) {
                
                SolButton(title: "New Session", action: {
                    print("New Session Button")
                    showNewPlanSheet = true
                })
                
                DStack {
                    SolButton(title: "Create Team", action: {
                        print("Create Team Button")
                        showNewTeamSheet = true
                    })
                    
                    SolButton(title: "Create Player", action: {
                        print("Create Player Button")
                        showNewPlayerRefSheet = true
                    })
                }
                
            }.clearSectionBackground()
            
            Section(header: Text("Sessions")) {
                if !(self.sessionPlans.realm?.isInWriteTransaction ?? true) {
                    List(hostedSessionPlans) { sessionPlan in
                        NavigationLink(
                            destination: SessionPlanView(sessionId: sessionPlan.id, isShowing: .constant(true), isMasterWindow: false)
                                .environmentObject(self.BEO)
                                .environmentObject(self.NavStack)
                        ) {
                            SessionPlanThumbView(sessionPlan: sessionPlan)
                        }
                    }
                }
            }.clearSectionBackground()

            if self.BEO.isLoggedIn {
                Section(header: Text("Shared Sessions")) {
                    if !(self.sessionPlans.realm?.isInWriteTransaction ?? true)  {
                        List(sharedSessionPlans, id: \.self) { sessionPlan in
                            
                            NavigationLink(
                                destination: SessionPlanView(sessionId: sessionPlan.id, isShowing: .constant(true), isMasterWindow: false)
                                    .environmentObject(self.BEO)
                                    .environmentObject(self.NavStack)
                            ) {
                                SessionPlanThumbView(sessionPlan: sessionPlan)
                            }

                        }
                    }
                    
                }.clearSectionBackground()
            }
            
        }
        .onAppear() {
            self.NavStack.addToStack()
            fetchAllSessionsFromFirebase()
        }
        .onDisappear() {
            self.NavStack.removeFromStack()
        }
        .loading(isShowing: $isLoading)
        .navigationBarTitle("Session Plans", displayMode: .inline)
        .sheet(isPresented: $showNewPlanSheet) {
            SessionPlanView(sessionId: "new", isShowing: $showNewPlanSheet, isMasterWindow: false)
                .environmentObject(self.BEO)
                .environmentObject(self.NavStack)
        }
        
        .sheet(isPresented: $showNewTeamSheet) {
            TeamView(teamId: "new")
        }
        
        .sheet(isPresented: $showNewPlayerRefSheet) {
            PlayerRefView(playerId: "new")
        }
        
        .refreshable {
            fetchAllSessionsFromFirebase()
        }
    }
    
    func fetchAllSessionsFromFirebase() {
        FirebaseSessionPlanService.runFullFetchProcess(realm: self.realmInstance)
    }
    
}
