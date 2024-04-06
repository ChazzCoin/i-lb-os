//
//  PlayerRefItem.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI
import RealmSwift
import CoreEngine

struct PlayerRefListView: View {
    // Assuming you have an array of image names from your assets
    var callback: (PlayerRef) -> Void
    @ObservedResults(PlayerRef.self) var players

    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 10) {
                
                if !players.isEmpty {
                    ForEach(players, id: \.self) { player in
                        PlayerRefItemView(playerId: .constant(player.id))
                            .onTapAnimation {
                                callback(player)
                            }
                    }
                } else {
                    HeaderText("No Players.")
                }
                
            }
            
        }
        .frame(height: 200)
    }
}

struct PlayerRefItemView: View {
    @Binding var playerId: String
    
    @State var realmInstance = newRealm()
    
    @State var playerName: String = ""
    @State var playerPosition: String = ""
    @State var playerNumber: String = ""
    @State var playerFoot: String = ""
    @State var playerHand: String = ""
    @State var playerAge: String = ""
    @State var playerYear: String = ""
    @State var playerImgUrl: String = ""

    var body: some View {
        VStack(alignment: .leading) {

            // Player's name
            BodyText(playerName)

            // Player's position
            BodyText(playerPosition)
                .padding(.leading)

        }
        .padding()
        .frame(maxWidth: 300, minHeight: 75, alignment: .leading)
        .background(Color.secondaryBackground)
        .cornerRadius(8)
        .shadow(radius: 3)
        .onAppear() {
            if let obj = self.realmInstance.findByField(PlayerRef.self, value: self.playerId) {
                playerName = obj.name
                playerPosition = obj.position
                playerNumber = String(obj.number)
                playerFoot = obj.foot
                playerImgUrl = obj.imgUrl
            }
        }
    }
}

//#Preview {
//    PlayerRefItemView(playerId: .constant(""))
//}
