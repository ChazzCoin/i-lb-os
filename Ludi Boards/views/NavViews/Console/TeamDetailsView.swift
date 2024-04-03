//
//  TeamDetailsView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/1/24.
//

import Foundation
import SwiftUI
import RealmSwift

struct TeamDetailsView: View {
    
    var teamId: String
    
    @ObservedResults(PlayerRef.self) var players
    var roster: Results<PlayerRef> {
        return self.players.filter("teamId == %@", self.teamId)
    }
    
    @State var sport: String = ""
    
    @State private var teamName: String = ""
    @State private var coachName: String = ""
    @State private var sportType: String = ""
    @State private var logoUrl: String? = nil
    @State private var foundedYear: String = "2020"
    @State private var homeCity: String = ""
    @State private var stadiumName: String = ""
    
    @State private var coach: String = ""
    @State private var manager: String = ""
    @State private var league: String = ""
    @State private var achievements: [String] = [] // Converted from List<String>
    @State private var officialWebsite: String? = nil
    @State private var socialMediaLinks: [String] = [] // Converted from List<String>

    @State var realmInstance = newRealm()
    @State var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    @State var isEditMode: Bool = true
    
    func save() {
        if teamId == "new" {
            new()
        } else {
            update()
        }
    }
    func update() {
        if let team = realmInstance.findByField(Team.self, value: teamId) {
            realmInstance.safeWrite { r in
                team.name = teamName
                
            }
        }
    }
    func new() {
        let newTeam = Team()
        newTeam.name = teamName
       
        realmInstance.safeWrite { r in
            r.create(Team.self, value: newTeam)
        }
    }
    
    var body: some View {
        
        BaseDetailsView(
            navTitle: "Team",
            headerBuilder: {
                HStack {
                    SOLCON(
                        icon: SolIcon.save,
                        onTap: {
                            save()
                        }
                    )
                    
                    SOLCON(
                        icon: SolIcon.delete,
                        onTap: {
                            
                        }
                    )
                    
                    Spacer()
                    Text(isEditMode ? "Done" : "Edit")
                        .foregroundColor(.blue)
                        .onTapAnimation {
                            isEditMode.toggle()
                        }
                    
                }
                
            },
            bodyBuilder: {
                Section("Team Details") {
                    PickerSport(selection: $sport, isEdit: $isEditMode)
                    InputText(label: "Team Name", text: $teamName, isEdit: $isEditMode)
                    InputText(label: "Coach Name", text: $coachName, isEdit: $isEditMode)
                    InputText(label: "Location", text: $homeCity, isEdit: $isEditMode)
                    InputText(label: "League", text: $league, isEdit: $isEditMode)
                    PickerYear(selection: $foundedYear, isEdit: $isEditMode)
                    
                }
                
            },
            footerBuilder: {
                Section("Team Roster") {
                    SolPlayerRefFreePicker(teamId: "new", isEnabled: $isEditMode)
                    HeaderText("Roster", color: .black)
                        .font(.headline)
                        .padding(.top)
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(roster) { player in
                            PlayerRefItemView(playerId: .constant(player.id))
                                .onTapAnimation {
                                    
                                }
                        }
//                        .onDelete(perform: deletePlayer)
                    }
                }
            }).onAppear() {
                if teamId == "new" {
                    return
                }
                if let team = newRealm().findByField(Team.self, value: teamId) {
                    sport = team.sportType
                    teamName = team.name
                    coachName = team.coachName
                    isEditMode = false
                    return
                }
            }
        
    }
}

#Preview {
    TeamDetailsView(teamId: "new")
}
