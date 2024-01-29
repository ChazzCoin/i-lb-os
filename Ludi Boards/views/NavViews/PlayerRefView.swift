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
    @State var playerId: String
    @State var player: PlayerRef = PlayerRef()
    @State private var isEditMode: Bool = false

    @State var playerName: String = ""
    @State var playerPosition: String = ""
    @State var playerNumber: String = ""
    @State var playerFoot: String = ""
    @State var playerHand: String = ""
    @State var playerAge: String = ""
    @State var playerYear: String = ""
    @State var playerImgUrl: String = ""

    var body: some View {
        ScrollView {
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
                
                Divider()
                    .padding(.vertical)

                // Edit Button
                if isEditMode {
                    SolButton(title: "Save Player", action: {
                        savePlayer()
                        isEditMode.toggle()
                    }, isEnabled: isEditMode)
                } else {
                    Button(action: {
                        isEditMode.toggle()
                    }) {
                        Text("Edit Player")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }

                // Player Details
                if !isEditMode {
                    VStack(alignment: .leading) {
                        DetailView(label: "Foot:", value: playerFoot)
                        DetailView(label: "Hand:", value: playerHand)
                        DetailView(label: "Year:", value: playerYear)
                    }
                    .padding(.top, 20)
                } else {
                    // Editable fields
                    VStack {
                        SolTextField("Player Name", text: $playerName)
                        SolTextField("Position", text: $playerPosition)
                        SolTextField("Number", text: $playerNumber)
                        SolTextField("Foot", text: $playerFoot)
                        SolTextField("Hand", text: $playerHand)
                        SolTextField("Age", text: $playerAge)
                        SolTextField("Year", text: $playerYear)
                    }
                    .padding(.top, 20)
                }
            }
            .padding()
        }
        .navigationBarTitle("Player Details", displayMode: .inline)
        .onAppear() {
            if playerId == "new" {
                isEditMode = true
            }
            loadPlayer()
        }
    }

    private func loadPlayer() {
        // Load player data into state variables
    }
    
    private func savePlayer() {
        // Implement functionality to save player data
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


#Preview {
    PlayerRefView(playerId: "new")
}
