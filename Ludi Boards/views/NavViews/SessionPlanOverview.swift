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
  
    @ObservedResults(PlayerRef.self) var players
    
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
    
    @State private var currentTeamId = ""
    @State private var showCurrentTeamSheet = false
    @State private var showNewTeamSheet = false
    @State private var showNewPlayerRefSheet = false
    
    @State private var isLoggedIn = false
    
    @State private var isSidebarVisible = false
    var sidebarView: some View {
        
        DSidebarWindow {
            Spacer().frame(height: 50)
            SubHeaderText("Teams")
            SearchableTeamListView()
                .environmentObject(self.BEO)
                .environmentObject(self.NavStack)
            SubHeaderText("Players")
            SearchablePlayerRefListView()
                .environmentObject(self.BEO)
                .environmentObject(self.NavStack)
            Spacer()
        }
        
    }

    var body: some View {
        // Main Content and Sidebar
        ZStack(alignment: .leading) {
            
            Form {
                
                Section(header: Text("Manage")) {
                    
                    DStack {
                        SolButton(title: "Create Session", action: {
                            print("New Session Button")
                            showNewPlanSheet = true
                        })
                        
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
                    SearchableSessionListView()
                        .environmentObject(self.BEO)
                        .environmentObject(self.NavStack)
                }.clearSectionBackground()
                
                
                Section(header: Text("Activities")) {
                    SearchableActivityListView()
                        .environmentObject(self.BEO)
                        .environmentObject(self.NavStack)
                }.clearSectionBackground()
                
            }

            if isSidebarVisible {
                sidebarView
                    .frame(width: 300)
                    .transition(.move(edge: .leading))
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
        .navigationBarItems(leading: Button(action: {
            withAnimation {
                isSidebarVisible.toggle()
            }
        }) {
            Image(systemName: "line.horizontal.3")
        })
        .sheet(isPresented: $showNewPlanSheet) {
            SessionPlanView(sessionId: "new", isShowing: $showNewPlanSheet, isMasterWindow: false)
                .environmentObject(self.BEO)
                .environmentObject(self.NavStack)
        }
        .sheet(isPresented: $showCurrentTeamSheet) {
            TeamView(teamId: $currentTeamId, isShowing: $showCurrentTeamSheet)
        }
        .sheet(isPresented: $showNewTeamSheet) {
            TeamView(teamId: .constant("new"), isShowing: $showNewTeamSheet)
        }
        
        .sheet(isPresented: $showNewPlayerRefSheet) {
            PlayerRefView(playerId: .constant("new"), isShowing: $showNewPlayerRefSheet)
        }
        
        .refreshable {
            fetchAllSessionsFromFirebase()
        }
    }
    
    func fetchAllSessionsFromFirebase() {
        FirebaseSessionPlanService.runFullFetchProcess(realm: self.realmInstance)
    }
    
}
