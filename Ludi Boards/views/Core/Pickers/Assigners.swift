//
//  Assigners.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/1/24.
//

import Foundation
import SwiftUI
import RealmSwift
import CoreEngine

struct PickerOrganization: View {
    @ObservedResults(Organization.self) var allOrgs
    var currentOrg: Organization? {
        return allOrgs.filter("name == %@", selectionOrgName).first
    }
    
    @AppStorage("currentOrgId") var currentOrgId: String = "none"
    @AppStorage("currentOrgName") var currentOrgName: String = "none"
    
    
    @State var selectionOrgName: String = ""
    
    var body: some View {
        
        VStack(alignment: .leading, content: {
            Text("Organization")
                .font(.callout)
                .padding(.top)
                
            Picker("", selection: $selectionOrgName) {
                ForEach(allOrgs, id: \.self) { org in
                    Text(org.name).tag(org.name)
                }
            }
            .foregroundColor(.blue)
            .onChange(of: selectionOrgName, perform: { value in
                if let value = currentOrg {
                    currentOrgId = value.id
                    currentOrgName = value.name
                }
            })
        })
        
        .onAppear() {
            if !currentOrgId.isEmpty {
                if let temp = allOrgs.filter("id == %@", currentOrgId).first {
                    selectionOrgName = temp.name
                }
            }
        }
    }
}

// Assign Team to Org -
// Assign Player to Team -
// Assign Session to Org/Team
// Assign Activity to Session/Org/Team

struct AssignTeamToOrg: View {
    
    let teamId: String
    @Binding var isEnabled: Bool
    
    @State var selectionId: String = ""
    @State var selectionName: String = ""
    @ObservedResults(Organization.self) var allOrgs
    let realmInstance = newRealm()
    
    var body: some View {
        
        if !isEnabled {
            TextLabel("Organizations", text: selectionName)
        } else {
            if allOrgs.isEmpty {
                TextLabel("No Organizations", text: "No Organizations Available.")
            } else {
                Picker("Assign to Organization", selection: $selectionId) {
                    ForEach(allOrgs, id: \.self) { item in
                        Text(item.name).tag(item.id)
                    }
                }
                .foregroundColor(.blue)
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectionId, perform: { value in
                    if let org = realmInstance.findByField(Organization.self, value: value) {
                        selectionName = org.name
                    }
                    if let team = realmInstance.findByField(Team.self, value: teamId) {
                        realmInstance.safeWrite { r in
                            team.orgId = selectionId
                        }
                    }
                })
            }
        }
        
    }
}

struct AssignPlayerToTeam: View {
    
    let teamId: String
    @Binding var isEnabled: Bool
    
    @State var selectionId: String = ""
    @State var selectionName: String = ""
    @ObservedResults(PlayerRef.self) var allPlayers
    let title = "Player"
    let realmInstance = newRealm()
    
    var body: some View {
        
        if !isEnabled {
            TextLabel(title, text: selectionName)
        } else {
            if allPlayers.isEmpty {
                TextLabel("No \(title)s", text: "No \(title)s Available.")
            } else {
                Picker("Assign to \(title)", selection: $selectionId) {
                    ForEach(allPlayers, id: \.self) { item in
                        Text(item.name).tag(item.id)
                    }
                }
                .foregroundColor(.blue)
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectionId, perform: { value in
                    if let player = realmInstance.findByField(PlayerRef.self, value: value) {
                        selectionName = player.name
                        realmInstance.safeWrite { r in
                            player.teamId = selectionId
                        }
                    }
                })
            }
        }
        
    }
}

struct AssignSessionToOrg: View {
    
    let sessionId: String
    @Binding var isEnabled: Bool
    
    @State var selectionId: String = ""
    @State var selectionName: String = ""
    @ObservedResults(Organization.self) var allOrgs
    let realmInstance = newRealm()
    let title = "Organization"
    
    var body: some View {
        
        if !isEnabled {
            TextLabel(title, text: selectionName)
        } else {
            if allOrgs.isEmpty {
                TextLabel("No \(title)s", text: "No \(title)s Available.")
            } else {
                Picker("Assign to \(title)", selection: $selectionId) {
                    ForEach(allOrgs, id: \.self) { item in
                        Text(item.name).tag(item.id)
                    }
                }
                .foregroundColor(.blue)
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectionId, perform: { value in
                    if let org = realmInstance.findByField(Organization.self, value: value) {
                        selectionName = org.name
                    }
                    if let sess = realmInstance.findByField(SessionPlan.self, value: sessionId) {
                        realmInstance.safeWrite { r in
                            sess.orgId = selectionId
                        }
                    }
                })
            }
        }
        
    }
}


//#Preview {
//    Section {
//        AssignTeamToOrg(teamId: "new", isEnabled: .constant(true))
//    }
//    
//}
