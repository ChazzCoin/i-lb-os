//
//  TeamDetailsView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/1/24.
//

import Foundation
import SwiftUI
import RealmSwift
import CoreEngine

struct TeamDetailsView: View {
    
    @State var teamId: String
    
    @StateObject var team: TeamObject = TeamObject()
    let PTManager: PlayerTeamManager = PlayerTeamManager()
    
    @ObservedResults(PlayerRef.self) var players
    var roster: Results<PlayerRefToTeam> {
        return PTManager.findPlayersByTeamId(teamId: self.teamId)
    }
    
    @State var sport: String = ""
    
    @State var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    @State var isEditMode: Bool = true
    
    // Function to handle saving the team data
    func save() {
        team.saveToRealm()
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
                            team.isDeleted = true
                            save()
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
                    CoreInputText(label: "Team Name", text: $team.name, isEdit: $isEditMode)
                    CoreInputText(label: "Coach Name", text: $team.coachName, isEdit: $isEditMode)
                    CoreInputText(label: "Location", text: $team.homeCity, isEdit: $isEditMode)
                    CoreInputText(label: "League", text: $team.league, isEdit: $isEditMode)
                    PickerYear(selection: $team.foundedYear, isEdit: $isEditMode)
                    
                }
                
            },
            footerBuilder: {
                Section("Team Roster") {
                    SolPlayerRefFreePicker(teamId: team.id, isEnabled: $isEditMode)
                    HeaderText("Roster", color: .black)
                        .font(.headline)
                        .padding(.top)
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(roster) { player in
                            PlayerRefItemView(playerId: .constant(player.id))
                                .onTapAnimation {
                                    TeamManager().removeUserFromTeam(userId: player.id, teamId: team.id, completion: { _ in
                                        print("Removed Player from Team.")
                                    })
                                }
                        }
                    }
                }
            }).onAppear() {
                if teamId != "new" {
                    team.loadTeam(byId: teamId)
                    isEditMode = false
                } else {
                    isEditMode = true
                }
                sport = team.sportType
            }
    }
}

#Preview {
    TeamDetailsView(teamId: "new")
}

