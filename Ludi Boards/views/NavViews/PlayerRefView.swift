//
//  PlayerRefView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI
import RealmSwift

struct PlayerRefView: View {
    @Binding var playerId: String
    @Binding var isShowing: Bool
    @State var player: PlayerRef = PlayerRef()
    @State private var isEditMode: Bool = false

    @State private var attachATeamConfirmation: Bool = false
    @State private var attachATeamIsOn: Bool = false
    @State var playerTeamId: String = ""
    @State var originalTeamId: String = ""
    
    @State var playerName: String = ""
    @State var playerPosition: String = ""
    @State var playerNumber: String = ""
    @State var playerFoot: String = ""
    @State var playerHand: String = ""
    @State var playerAge: String = ""
    @State var playerYear: String = ""
    @State var playerImgUrl: String = ""
    
    @State var realmInstance = newRealm()

    var body: some View {
        ScrollView {
            
            HStack {
                Text(playerName)
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
            }.padding()
            
            Divider()
            
            DStack {
                VStack {
                    // Player's image
                    if let imageUrl = URL(string: playerImgUrl), !playerImgUrl.isEmpty {
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

                    // Player's name
                    Text(playerName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)

                    // Player's position, number, and age
                    HStack {
                        Text(playerPosition)
                            .font(.title3)
                            .fontWeight(.medium)
                        Text("#\(playerNumber)")
                            .font(.title3)
                            .fontWeight(.medium)
                        Spacer()
                        Text("Age \(playerAge)")
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    .padding(.top, 5)
                    
                    
                }.frame(width: 200)
            
            
                // Player Details
                VStack {
                    SolTextField("Player Name", text: $playerName, isEditable: $isEditMode)
                    
                    
                    
                    DStack {
                        SolTextField("Position", text: $playerPosition, isEditable: $isEditMode)
                        SolTextField("Number", text: $playerNumber, isEditable: $isEditMode)
                    }
                    DStack {
                        SolTextField("Foot", text: $playerFoot, isEditable: $isEditMode)
                        SolTextField("Hand", text: $playerHand, isEditable: $isEditMode)
                    }
                    DStack {
                        SolTextField("Age", text: $playerAge, isEditable: $isEditMode)
                        SolTextField("Year", text: $playerYear, isEditable: $isEditMode)
                    }
                }
                .padding(.top, 20)
                

               
            }
            .padding()
            
            DStack {
                Toggle(isOn: $attachATeamIsOn, label: {
                    SubHeaderText(playerTeamId.isEmpty ? "Attach a Team." : "Reassign Team")
                })
                SolTeamPicker(selection: $playerTeamId, isEnabled: .constant(attachATeamIsOn && isEditMode))
            }
            
            Divider()
                .padding(.vertical)

            // Edit Button
            if isEditMode {
                
                DStack {
                    SolButton(title: "Save Player", action: {
                        savePlayer()
                        isEditMode.toggle()
                        if !isEditMode { isShowing = false }
                    }, isEnabled: isEditMode)
                    
                    SolButton(title: "Delete Player", action: {
                        deletePlayer()
                        isEditMode.toggle()
                        if !isEditMode { isShowing = false }
                    }, isEnabled: isEditMode && playerId != "new")
                }
                
                
            } else {
                SolButton(title: "Edit Player", action: {
                    isEditMode.toggle()
                    if !isEditMode { isShowing = false }
                }, isEnabled: isEditMode)
            }
            
        }
        .padding()
        .navigationBarTitle("Player Details", displayMode: .inline)
        .onChange(of: self.playerId, perform: { value in
            loadPlayer()
        })
        .onChange(of: playerTeamId, perform: { value in
            if playerTeamId != originalTeamId && isEditMode {
                attachATeamConfirmation = true
            } else {
                attachATeamConfirmation = false
            }
        })
        .alert("Assign Player", isPresented: $attachATeamConfirmation) {
            Button("Cancel", role: .cancel) {
                playerTeamId = originalTeamId
                attachATeamConfirmation = false
            }
            Button("OK", role: .none) {
                savePlayer()
                originalTeamId = playerTeamId
                attachATeamConfirmation = false
            }
        } message: {
            Text("Are you sure you want to assign this player?")
        }
        .onAppear() {
            loadPlayer()
        }
    }

    private func loadPlayer() {
        if playerId == "new" {
            isEditMode = true
            return
        }
        if let obj = self.realmInstance.findByField(PlayerRef.self, value: self.playerId) {
            playerName = obj.name
            playerTeamId = obj.teamId
            playerPosition = obj.position
            playerNumber = String(obj.number)
            playerFoot = obj.foot
            playerHand = obj.hand
            playerAge = obj.age
            playerYear = obj.year
            playerImgUrl = obj.imgUrl
        }
        
        if !playerTeamId.isEmpty {
            originalTeamId = playerTeamId
            attachATeamIsOn = true
        }
    }
    
    private func addPlayer() {
        let obj = PlayerRef()
        obj.name = playerName
        obj.teamId = attachATeamIsOn ? playerTeamId : ""
        obj.position = playerPosition
        obj.number = Int(playerNumber) ?? 0
        obj.foot = playerFoot
        obj.hand = playerHand
        obj.age = playerAge
        obj.year = playerYear
        obj.imgUrl = playerImgUrl
        
        self.realmInstance.safeWrite { r in
            r.create(PlayerRef.self, value: obj, update: .all)
        }
        
        // TODO: FIREBASE
        
    }
    private func savePlayer() {
        
        if self.playerId == "new" {
            addPlayer()
            return
        }
        
        if let obj = self.realmInstance.findByField(PlayerRef.self, value: self.playerId) {
            
            self.realmInstance.safeWrite { r in
                obj.name = playerName
                obj.teamId = attachATeamIsOn ? playerTeamId : ""
                obj.position = playerPosition
                obj.number = Int(playerNumber) ?? 0
                obj.foot = playerFoot
                obj.hand = playerHand
                obj.age = playerAge
                obj.year = playerYear
                obj.imgUrl = playerImgUrl

                // TODO: FIREBASE
            }
            
        }
    }
    
    private func deletePlayer() {
        if let obj = self.realmInstance.findByField(PlayerRef.self, value: self.playerId) {
            self.realmInstance.safeWrite { r in
                r.delete(obj)
            }
        }
    }
}

struct DetailView: View {
    var label: String
    var value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
        }
        .padding(.vertical, 2)
    }
}


//#Preview {
//    PlayerRefView(playerId: "new")
//}
