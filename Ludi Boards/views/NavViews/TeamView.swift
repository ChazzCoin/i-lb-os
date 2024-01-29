//
//  TeamView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI
import RealmSwift

struct TeamView: View {
    @State var teamId: String
    @State var team: Team = Team()
    @ObservedResults(PlayerRef.self) var players
    @State private var isEditMode: Bool = false
    private let sports = ["Soccer", "Basketball", "Baseball", "Football", "Hockey", "Tennis", "Volleyball", "Rugby", "Cricket", "Golf"]

    @State var realmInstance = newRealm()
    
    @State var teamName: String = ""
    @State var teamYear: String = ""
    @State var teamCoach: String = ""
    @State var sport: String = ""
    
    @State var showAddPlayerSheet = false
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text(teamName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        isEditMode.toggle()
                    }) {
                        Text(isEditMode ? "Done" : "Edit")
                            .foregroundColor(.blue)
                    }
                }
                
                Divider()
                
                Group {
                    DStack {
                        TitleText("Sport: ")
                            .fontWeight(.bold)
                        Spacer()
                        if isEditMode {
                            SolPicker(selection: $sport, data: sports, title: "Select a Sport")
                        } else {
                            Text(sport)
                        }
                        Spacer()
                    }
                    
                    DStack {
                        TitleText("Coach: ")
                            .fontWeight(.bold)
                        Spacer()
                        if isEditMode {
                            SolTextField("Coach Name", text: $teamCoach)
                        } else {
                            Text(teamCoach)
                        }
                    }
                    
                    DStack {
                        TitleText("Year/Age: ")
                            .fontWeight(.bold)
                        Spacer()
                        if isEditMode {
                            SolTextField("Year", text: $teamYear)
                        } else {
                            Text(teamYear)
                        }
                    }
                    
                    SolButton(
                        title: "Save Team",
                        action: {
                            addTeam()
                        },
                        isEnabled: isEditMode
                    )
                }
                .padding(.vertical, 4)
                
                Divider()
                
                Group {
                    Text("Players")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(players) { player in
                        PlayerRefItemView(player: player)
                    }
                    .onDelete(perform: deletePlayer)
                    
                    if isEditMode {
                        SolButton(
                            title: "Add Player",
                            action: {
                                showAddPlayerSheet = true
                            },
                            isEnabled: true
                        )
                    }
                }
                
                Divider()
                
                
            }
            .padding()
        }
        .navigationBarTitle("Team Details", displayMode: .inline)
        .sheet(isPresented: $showAddPlayerSheet) {
            PlayerRefView(playerId: "new")
        }
        .onAppear() {
            if teamId == "new" {
                isEditMode = true
            }
        }
    }
    
    private func addTeam() {
        let newTeam = Team()
        newTeam.name = teamName
        newTeam.age = teamYear
        newTeam.sport = sport
        
        realmInstance.safeWrite { r in
            r.create(Team.self, value: newTeam, update: .all)
        }
    }

    private func deletePlayer(at offsets: IndexSet) {
        // Handle player deletion
    }

    private func addPlayer() {
        // Handle adding a new player
    }

    private func deleteStatistic(at offsets: IndexSet) {
        // Handle statistic deletion
    }

    private func addStatistic() {
        // Handle adding a new statistic
    }
}

struct PlayerRow: View {
    @ObservedRealmObject var player: PlayerRef
    @Binding var isEditMode: Bool

    var body: some View {
        HStack {
            if isEditMode {
                TextField("Player Name", text: $player.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Position", text: $player.position)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Number", value: $player.number, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            } else {
                Text(player.name)
                Spacer()
                Text(player.position)
                Spacer()
                Text("\(player.number)")
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TeamView(teamId: "")
}
