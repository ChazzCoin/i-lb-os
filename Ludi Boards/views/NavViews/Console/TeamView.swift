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
    
    @State private var isEditMode: Bool = true

    @State var realmInstance = newRealm()
    
    @State var teamName: String = ""
    @State var teamYear: String = ""
    @State var teamCoach: String = ""
    @State var sport: String = ""
    @State var teamImgUrl: String = ""
    
    @State var addPlayerName = ""
    @State var addPlayerId = ""
    @State var showAddPlayerPicker: Bool = false
    
    @State var currentPlayerId = ""
    @State var showCurrentPlayerSheet = false
    @State var showAddPlayerSheet = false
    
    @State var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        Form {
            HStack {
                
                SOLCON(
                    icon: SolIcon.save,
                    onTap: {
                        if teamId == "new" {
                            addTeam()
                        } else {
                            saveTeam()
                        }
                    }
                ).solEnabled(isEnabled: self.isEditMode)
                
                SOLCON(
                    icon: SolIcon.delete,
                    onTap: {
                        deleteTeam()
                    }
                ).solEnabled(isEnabled: isEditMode && teamId != "new")
                
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
            }.clearSectionBackground()
            
            Section {
                
                // Player's image
                if let imageUrl = URL(string: teamImgUrl), !teamImgUrl.isEmpty {
                    AsyncImage(url: imageUrl) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .padding(.top, 20)
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 100, height: 100)
                        .shadow(radius: 10)
                        .padding(.top, 20)
                }

               
            }
            
            Section {
                PickerSport(selection: $sport, isEdit: $isEditMode)
                InputText(label: "Team Name", text: $teamName, isEdit: $isEditMode)
                InputText(label: "Coach Name", text: $teamCoach, isEdit: $isEditMode)
                InputText(label: "Year", text: $teamYear, isEdit: $isEditMode)
            }
            
            Section {
                
//                SolPlayerRefFreePicker(selection: $addPlayerName, isEnabled: $isEditMode)
                
                HeaderText("Roster", color: .black)
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
            
        }
        .padding()
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
            teamYear = obj.foundedYear
            teamCoach = obj.coachName
            sport = obj.sportType
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
        
//        newTeam.name = teamName
//        newTeam.age = teamYear
//        newTeam.sport = sport
//        newTeam.coachName = teamCoach
        
        realmInstance.safeWrite { r in
            r.create(Team.self, value: newTeam, update: .all)
        }
        
        isEditMode = false
    }
    
    private func saveTeam() {
        if let obj = self.realmInstance.findByField(Team.self, value: self.teamId) {
            self.realmInstance.safeWrite { r in
                obj.name = teamName
                obj.foundedYear = teamYear
                obj.coachName = teamCoach
                obj.sportType = sport
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
