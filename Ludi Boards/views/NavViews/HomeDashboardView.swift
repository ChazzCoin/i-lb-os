//
//  SessionPlanOverview.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/2/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct HomeDashboardView: View {
    @State var userId: String = getFirebaseUserId() ?? "SOL"
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var BEO: BoardEngineObject
    @EnvironmentObject var NavStack: NavStackWindowObservable
  
    @ObservedResults(PlayerRef.self) var players
    @ObservedResults(Team.self) var teams
    
    @ObservedResults(UserToSession.self, where: { $0.status != "removed" }) var guestSessions
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
    @State private var showNewOrgSheet = false
    @State private var showNewTeamSheet = false
    @State private var showNewPlayerRefSheet = false
    
    @State private var isLoggedIn = false
    
    @State private var isSidebarVisible = false
    var sidebarView: some View {
        
        DSidebarWindow {
            MenuListView(isShowing: $isSidebarVisible)
        }
        .clearSectionBackground()
        
    }

    var body: some View {
        // Main Content and Sidebar
        ZStack(alignment: .leading) {
            
            List {
                
                OrganizationDashboardView(orgId: self.BEO.currentOrgId)
                
                // Teams
                if teams.isEmpty {
                    Text("No Teams")
                }
                ForEach(teams, id: \.id) { item in
                    
                    NavigationLink(item.name, destination: TeamDetailsView(teamId: item.id))
//                    Text(item.name)
                        
                }
                
                // Players
                if players.isEmpty {
                    Text("No Players")
                }
                ForEach(players, id: \.id) { item in
                    Text(item.name)
                }
                
                // Sessions
                Section(header: Text("Sessions")) {
                    SearchableSessionListView()
                        .environmentObject(self.BEO)
                        .environmentObject(self.NavStack)
                }.clearSectionBackground()
                
                // Activities
                
            }
            .onTap {
                if isSidebarVisible {
                    withAnimation {
                        isSidebarVisible = false
                    }
                }
            }

            if isSidebarVisible {
                MenuListView(isShowing: $isSidebarVisible)
            }
            
        }
        .navigationBarTitle("Session Plans", displayMode: .inline)
        .navigationBarItems(leading: Button(action: {
            withAnimation {
                isSidebarVisible.toggle()
            }
        }) {
            Image(systemName: "line.horizontal.3")
        })
        .onAppear() {
            self.NavStack.addToStack()
            fetchAllSessionsFromFirebase()
        }
        .onDisappear() {
            self.NavStack.removeFromStack()
        }
        .loading(isShowing: $isLoading)
//        .sheet(isPresented: $showNewPlanSheet) {
//            SessionPlanView(sessionId: "new", isShowing: $showNewPlanSheet, isMasterWindow: false)
//                .environmentObject(self.BEO)
//                .environmentObject(self.NavStack)
//        }
//        .sheet(isPresented: $showCurrentTeamSheet) {
//            TeamView(teamId: $currentTeamId, isShowing: $showCurrentTeamSheet)
//        }
//        .sheet(isPresented: $showNewOrgSheet) {
////            TeamView(teamId: .constant("new"), isShowing: $showNewTeamSheet)
//        }
//        .sheet(isPresented: $showNewTeamSheet) {
//            TeamView(teamId: .constant("new"), isShowing: $showNewTeamSheet)
//        }
//        .sheet(isPresented: $showNewPlayerRefSheet) {
//            PlayerRefView(playerId: .constant("new"), isShowing: $showNewPlayerRefSheet)
//        }
        .refreshable {
            fetchAllSessionsFromFirebase()
        }
    }
    
    func fetchAllSessionsFromFirebase() {
        FirebaseSessionPlanService.runFullFetchProcess(realm: self.realmInstance)
    }
    
}
