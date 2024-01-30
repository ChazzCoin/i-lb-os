//
//  PlayerRefItem.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI

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
        HStack {
            // Player's image
            if let imageUrl = URL(string: playerImgUrl), !playerImgUrl.isEmpty {
                AsyncImage(url: imageUrl) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 50, height: 50)
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
            }

            VStack(alignment: .leading) {
                // Player's name
                Text(playerName)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)

                // Player's position
                Text(playerPosition)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(1)

                // Player's number
                if Int(playerNumber) != 0 {
                    Text("Number: \(playerNumber)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }.padding()

            Spacer()

            // Additional details or indicators can go here
            VStack {
                // Sample: Foot preference (if applicable)
                if !playerFoot.isEmpty {
                    Text(playerFoot)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.secondary, lineWidth: 1)
                        )
                }
            }
        }
        .padding()
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
