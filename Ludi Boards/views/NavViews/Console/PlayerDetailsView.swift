//
//  TeamDetailsView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/1/24.
//

import Foundation
import SwiftUI
import CoreEngine

struct PlayerDetailsView: View {
    
    var playerId: String
    
    @State var sport: String = ""
    
    @State var playerName: String = ""
    @State private var teamId: String = ""
    @State private var userId: String = ""
    @State private var sessionId: String = ""
    @State private var activityId: String = ""
    @State private var toolId: String = ""
    @State private var name: String = ""
    @State private var position: String = ""
    @State private var number: Int = 0
    @State private var tag: String = ""
    @State private var foot: String = ""
    @State private var hand: String = ""
    @State private var age: String = ""
    @State private var year: String = ""
    @State private var imgUrl: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    
    @State var realmInstance = newRealm()
    @State var isEditMode: Bool = true
    
    func save() {
        if playerId == "new" {
            new()
        } else {
            update()
        }
    }
    func update() {
        if let player = realmInstance.findByField(PlayerRef.self, value: playerId) {
            realmInstance.safeWrite { r in
                player.name = playerName
                
            }
        }
    }
    func new() {
        let newPlayer = PlayerRef()
        newPlayer.name = playerName
       
        realmInstance.safeWrite { r in
            r.create(PlayerRef.self, value: newPlayer)
        }
    }
    
    var body: some View {
        
        BaseDetailsView(
            navTitle: "Player",
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
                Section("Player Details") {
                    PickerSport(selection: $sport, isEdit: $isEditMode)
                    CoreInputText(label: "Player Name", text: $playerName, isEdit: $isEditMode)
                    CoreInputText(label: "Tag", text: $tag, isEdit: $isEditMode)
                    PickerSoccerPosition(selection: $position, isEdit: $isEditMode)
                    PickerAgeLevel(selection: $age, isEdit: $isEditMode)
                    PickerDominateFoot(selection: $foot, isEdit: $isEditMode)
                    PickerDominateHand(selection: $hand, isEdit: $isEditMode)
                    PickerWeight(selection: $weight, isEdit: $isEditMode)
                    PickerHeight(selection: $height, isEdit: $isEditMode)
                }
                
            },
            footerBuilder: {
                EmptyView()
            })
        
    }
}

//#Preview {
////    PlayerDetailsView()
//}
