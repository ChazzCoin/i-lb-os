//
//  PlayerRefItem.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI

struct PlayerRefItemView: View {
    var player: PlayerRef
    
    init(player: PlayerRef) {
        self.player = player
    }

    var body: some View {
        HStack {
            // Player's image
            if let imageUrl = URL(string: player.imgUrl), !player.imgUrl.isEmpty {
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
                Text(player.name)
                    .font(.headline)
                    .lineLimit(1)

                // Player's position
                Text(player.position)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                // Player's number
                if player.number != 0 {
                    Text("Number: \(player.number)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Additional details or indicators can go here
            VStack {
                // Sample: Foot preference (if applicable)
                if !player.foot.isEmpty {
                    Text(player.foot)
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
    }
}

#Preview {
    PlayerRefItemView(player: PlayerRef())
}
