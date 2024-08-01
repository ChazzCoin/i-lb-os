//
//  SessionPlanOverview.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/2/23.
//

import Foundation
import SwiftUI
import RealmSwift
import CoreEngine

struct HomeDashboardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var BEO: BoardEngineObject
  
    @ObservedResults(PlayerRef.self) var players
    @ObservedResults(Team.self) var teams
    @ObservedResults(CoreEvent.self) var events
    
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
    @State private var showNewEventSheet = false
    @State private var showNewActivitySheet = false
    
    @State private var isLoggedIn = false
    @State private var resetView = false
    
    @State private var isSidebarVisible = false
    var sidebarView: some View {
        
        DSidebarWindow {
            MenuListView(isShowing: $isSidebarVisible)
        }
        .clearSectionBackground()
        
    }

    var body: some View {
        // Main Content and Sidebar
        
        ZStackReset(reset: $resetView) {
            
            List {
                // Organization
                Section(header: Text("Organization")) {
                    if self.BEO.currentOrgId != "" {
                        OrganizationDashboardView(orgId: self.BEO.currentOrgId, showNewFlag: self.$showNewOrgSheet)
                            .padding()
                            .clearSectionBackground()
                    } else {
                        Text("Create Org")
                    }
                }
                
                Section(header: HStack {
                    Text("Teams")
                    Spacer()
                    SOLCON(icon: SolIcon.add, isConfirmEnabled: false, showTitle: false, onTap: {
                        self.showNewTeamSheet = true
                    })
                }) {
                    if teams.isEmpty {
                        NavigationLink(destination: TeamDetailsView(teamId: "new"), label: {Text("Create Team")})
                    } else {
                        ForEach(teams, id: \.id) { item in
                            NavigationLink(item.name, destination: TeamDetailsView(teamId: item.id))
                        }
                    }
                }
                
                Section(header: HStack {
                    Text("Players")
                    Spacer()
                    SOLCON(icon: SolIcon.add, isConfirmEnabled: false, showTitle: false, onTap: {
                        self.showNewPlayerRefSheet = true
                    })
                }) {
                    if players.isEmpty {
                        Text("No Members of SOL Academy")
                    } else {
                        ForEach(OrganizationManager().getAllUsersInOrganization(organizationId: BEO.currentOrgId), id: \.self) { item in
                            Text(item.name)
                        }
                    }
                }
               
                Section(header: HStack {
                    Text("Events")
                    Spacer()
                    SOLCON(icon: SolIcon.add, isConfirmEnabled: false, showTitle: false, onTap: {
                        self.showNewEventSheet = true
                    })
                }) {
                    if events.isEmpty {
                        Text("No Events")
                    }
                    ForEach(events, id: \.id) { item in
                        Text(item.name)
                    }
                }
               
                
                // Activities
                Section(header: HStack {
                    Text("Activities")
                    Spacer()
                    SOLCON(icon: SolIcon.add, isConfirmEnabled: false, showTitle: false, onTap: {
                        self.showNewActivitySheet = true
                    })
                }) {
                    SearchableActivityListView()
                        .environmentObject(self.BEO)

                }.clearSectionBackground()
                
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
            if let temp = realmInstance.objects(Organization.self).first {
                self.BEO.currentOrgId = temp.id
                self.resetView = true
                self.resetView = false
            }
        }
        .loading(isShowing: $isLoading)
        .organizationDetailsSheet(isPresented: $showNewOrgSheet, orgId: "new", reset: $resetView)
        .teamSheet(isPresented: $showNewTeamSheet, teamId: .constant("new"))
        .activityPlanSheet(isPresented: $showNewActivitySheet, activityId: "SOL", BEO: BEO)
        .sheet(isPresented: $showNewPlayerRefSheet) {
            PlayerRefView(playerId: .constant("new"), isShowing: $showNewPlayerRefSheet)
        }
        .refreshable {
            self.resetView = true
            self.resetView = false
        }
    }
    
}
