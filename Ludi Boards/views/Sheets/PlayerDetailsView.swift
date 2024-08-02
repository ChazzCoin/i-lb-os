//
//  PlayerDetailsView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/1/24.
//

import Foundation
import SwiftUI
import CoreEngine

struct PlayerDetailsView: View {
    
    @State var playerId: String
    
    @StateObject var player: PlayerRefObject = PlayerRefObject()

    @State var sport: String = ""
    
    @State var isEditMode: Bool = true

    // Function to handle saving the player data
    func save() {
        player.saveToRealm()
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
                            player.isDeleted = true
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
                Section("Player Details") {
                    PickerSport(selection: $sport, isEdit: $isEditMode)
                    CoreInputText(label: "Player Name", text: $player.name, isEdit: $isEditMode)
                    CoreInputNumber(label: "Tag", number: $player.tag, isEdit: $isEditMode)
                    PickerSoccerPosition(selection: $player.position, isEdit: $isEditMode)
                    PickerAgeLevel(selection: $player.age, isEdit: $isEditMode)
                    PickerDominateFoot(selection: $player.foot, isEdit: $isEditMode)
                    PickerDominateHand(selection: $player.hand, isEdit: $isEditMode)
                    PickerWeight(selection: $player.weight, isEdit: $isEditMode)
                    PickerHeight(selection: $player.height, isEdit: $isEditMode)
                }

            },
            footerBuilder: {
                EmptyView()
            }
        ).onAppear() {
            if playerId != "new" {
                player.loadPlayerRef(byId: playerId)
                isEditMode = false
            } else {
                isEditMode = true
            }
            sport = player.teamId // Assuming sport is related to teamId
        }

    }
}

//#Preview {
//    PlayerDetailsView(player: PlayerRefObject())
//}
