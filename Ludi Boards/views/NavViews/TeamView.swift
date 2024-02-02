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
    @Binding var teamId: String
    @Binding var isShowing: Bool
    @State var team: Team = Team()
    @Environment(\.colorScheme) var colorScheme
    @ObservedResults(PlayerRef.self) var players
    var roster: Results<PlayerRef> {
        return self.players.filter("teamId == %@", self.teamId)
    }
    
    @State private var isEditMode: Bool = false
    private let sports = ["Soccer", "Basketball", "Baseball", "Football", "Hockey", "Tennis", "Volleyball", "Rugby", "Cricket", "Golf"]

    @State var realmInstance = newRealm()
    
    @State var teamName: String = ""
    @State var teamYear: String = ""
    @State var teamCoach: String = ""
    @State var sport: String = ""
    
    @State var addPlayerName = ""
    @State var addPlayerId = ""
    @State var showAddPlayerPicker: Bool = false
    
    @State var currentPlayerId = ""
    @State var showCurrentPlayerSheet = false
    @State var showAddPlayerSheet = false
    
    @State var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
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
                        if !isEditMode { isShowing = false }
                    }) {
                        Text(isEditMode ? "Done" : "Edit")
                            .foregroundColor(.blue)
                    }
                }
                
                Divider()
                
                Group {
                    DStack {
                        SolButton(
                            title: "Save Team",
                            action: {
                                if teamId == "new" {
                                    addTeam()
                                } else {
                                    saveTeam()
                                }
                            },
                            isEnabled: isEditMode
                        )
                        SolConfirmButton(
                            title: "Delete Team",
                            message: "Are you sure you want to delete this team?",
                            action: {
                                deleteTeam()
                            },
                            isEnabled: isEditMode && teamId != "new"
                        )
                    }
                }
                
                Group {
                    
                    SolTextField("Team Name", text: $teamName, isEditable: $isEditMode)
                    
                    DStack {
                        SolTextField("Coach Name", text: $teamCoach, isEditable: $isEditMode)
                        SolTextField("Year", text: $teamYear, isEditable: $isEditMode)
                    }
                    
                    HStack {
                        BodyText("Sport: ", color: colorScheme == .dark ? .white : .black)
                            .fontWeight(.bold)
                        SolPicker(selection: $sport, data: sports, title: "Select a Sport", isEnabled: $isEditMode)
                        Spacer()
                    }
                    
                }
                .padding(.vertical, 4)
                
                Divider()
                
                if isEditMode {
                    HStack {
                        Spacer()
                        SolPlayerRefFreePicker(selection: $addPlayerName, isEnabled: $isEditMode)
                        Spacer()
                    }
                }
                
                Group {
                    HeaderText("Roster")
                        .font(.headline)
                        .padding(.top)
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(roster) { player in
                            PlayerRefItemView(playerId: .constant(player.id))
                                .onTapAnimation {
                                    currentPlayerId = player.id
                                    showCurrentPlayerSheet = true
                                }
                        }
                        .onDelete(perform: deletePlayer)
                    }
                    
                }
                
                Divider()
            }
            .padding()
        }
        .onChange(of: self.teamId, perform: { value in
            loadTeam()
        })
        .navigationBarTitle("Team Details", displayMode: .inline)
        .onChange(of: addPlayerName, perform: { value in
            if !addPlayerName.isEmpty {
                showAddPlayerPicker = true
            }
        })
        .alert("Attach Player", isPresented: $showAddPlayerPicker) {
            Button("Cancel", role: .cancel) {
                showAddPlayerPicker = false
            }
            Button("OK", role: .none) {
                showAddPlayerPicker = false
                if let obj = self.realmInstance.findPlayerByName(name: self.addPlayerName) {
                    self.realmInstance.safeWrite { _ in
                        obj.teamId = self.teamId
                    }
                }
            }
        } message: {
            Text("Are you sure you want to attach player to team?")
        }
        .sheet(isPresented: $showAddPlayerSheet) {
            PlayerRefView(playerId: .constant("new"), isShowing: $showAddPlayerSheet)
        }
        .sheet(isPresented: $showCurrentPlayerSheet) {
            PlayerRefView(playerId: $currentPlayerId, isShowing: $showAddPlayerSheet)
        }
        .onAppear() {
            if teamId == "new" {
                isEditMode = true
            } else {
                loadTeam()
            }
        }
    }
    
    private func loadTeam() {
        if let obj = self.realmInstance.findByField(Team.self, value: self.teamId) {
            teamName = obj.name
            teamYear = obj.age
            teamCoach = obj.coachName
            sport = obj.sport
        }
    }
    
    private func deleteTeam() {
        if let obj = self.realmInstance.findByField(Team.self, value: self.teamId) {
            self.realmInstance.safeWrite { r in
                r.delete(obj)
                isShowing = false
            }
        }
    }
    
    private func addTeam() {
        let newTeam = Team()
        
        newTeam.name = teamName
        newTeam.age = teamYear
        newTeam.sport = sport
        newTeam.coachName = teamCoach
        
        realmInstance.safeWrite { r in
            r.create(Team.self, value: newTeam, update: .all)
        }
        
        isEditMode = false
    }
    
    private func saveTeam() {
        if let obj = self.realmInstance.findByField(Team.self, value: self.teamId) {
            self.realmInstance.safeWrite { r in
                obj.name = teamName
                obj.year = teamYear
                obj.coachName = teamCoach
                obj.sport = sport
            }
        }
        
        isEditMode = false
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

//#Preview {
//    TeamView(teamId: "")
//}
