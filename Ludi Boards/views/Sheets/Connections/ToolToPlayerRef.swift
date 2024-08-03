//
//  Connections.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 8/2/24.
//

import Foundation
import SwiftUI
import RealmSwift
import CoreEngine
import UniformTypeIdentifiers

struct ToolToPlayerRefView: View {
    // State and Observed Variables
    @Binding var toolId: String
    @StateObject var player: PlayerRefObject = PlayerRefObject()
    let MPRM: ManagedPlayerRefManager = ManagedPlayerRefManager()
    
    @ObservedResults(PlayerRef.self) var allPlayers
    let realmInstance: Realm = newRealm()
    
    var toolPlayerIds: [String] {
        let temp = realmInstance.objects(ManagedPlayerRef.self).filter("toolId == %@", toolId)
        var ids: [String] = []
        for item in temp {
            ids.append(item.playerRefId)
        }
        return ids
    }
    
    var toolPlayers: Results<PlayerRef> {
        return realmInstance.objects(PlayerRef.self, in: toolPlayerIds)
    }
    var freePlayers: Results<PlayerRef> {
        return realmInstance.objects(PlayerRef.self, notIn: toolPlayerIds)
    }
    
    @State private var dragOverItemId: String = ""
    @State private var draggingPlayerId: String = ""
    @State private var isEditMode: Bool = false

    // Function to handle assigning a player to a team
    private func assignPlayer(_ playerId: String) {
        MPRM.attachToolToPlayer(toolId: self.toolId, playerRefId: playerId)
    }

    // Function to handle unassigning a player from a team
    private func unassignPlayer(_ playerId: String) {
        MPRM.detachToolFromPlayer(toolId: self.toolId, playerRefId: playerId)
    }
    
    @State var isShowingDetails: Bool = false
    @State var refreshDetails: Bool = false

    var body: some View {
        Form {
            AlignCenter {
                HeaderText("Attached Player", color: .blue)
            }
            if !refreshDetails {
                DisclosureGroup("\(player.name) Details", isExpanded: $isShowingDetails, content: {
                    CoreInputText(label: "Player Name", text: $player.name, isEdit: $isEditMode)
                    CoreInputNumber(label: "Tag", number: $player.tag, isEdit: $isEditMode)
                    PickerSoccerPosition(selection: $player.position, isEdit: $isEditMode)
                    PickerAgeLevel(selection: $player.age, isEdit: $isEditMode)
                    PickerDominateFoot(selection: $player.foot, isEdit: $isEditMode)
                    PickerDominateHand(selection: $player.hand, isEdit: $isEditMode)
                    PickerWeight(selection: $player.weight, isEdit: $isEditMode)
                    PickerHeight(selection: $player.height, isEdit: $isEditMode)
                })
            }
            
            HStack {
                // Assigned Players List
                VStack {
                    Text("Assigned Players")
                        .font(.headline)
                    
                    if toolPlayers.isEmpty {
                        // Placeholder for empty list
                        Text("Drop players here")
                            .foregroundColor(.gray)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .onDrop(of: [UTType.plainText], delegate: PlayerRefDropViewDelegate(performDrop: { player in
                                assignPlayer(player.id)
                            }))
                    } else {
                        List {
                            ForEach(toolPlayers) { player in
                                Text(player.name)
                                    .padding()
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                                    .onDrag {
                                        draggingPlayerId = player.id
                                        return NSItemProvider(object: player.id as NSString)
                                    }
                                    .onDrop(of: [UTType.plainText], delegate: PlayerRefDropViewDelegate(performDrop: { _ in
                                        unassignPlayer(player.id)
                                    }))
                            }
                        }
                    }
                }
                
                Spacer()

                // Free Players List
                VStack {
                    Text("Available Players")
                        .font(.headline)

                    List {
                        ForEach(freePlayers) { playerTemp in
                            Text(playerTemp.name)
                                .padding()
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(8)
                                .onDrag {
                                    self.draggingPlayerId = playerTemp.id
                                    return NSItemProvider(object: playerTemp.id as NSString)
                                }
                                .onDrop(of: [UTType.plainText], delegate: PlayerRefDropViewDelegate(performDrop: { _ in
                                    assignPlayer(playerTemp.id)
                                }))
                                .onTapAnimation {
                                    self.player.loadPlayerRef(byId: playerTemp.id)
                                    self.isShowingDetails = true
                                }
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear() {
            if !toolPlayers.isEmpty {
                self.player.loadPlayerRef(byId: toolPlayers.first?.id ?? "new")
                self.refreshDetails = true
                self.refreshDetails = false
            }
        }
    }
}

// DropViewDelegate for handling drop actions
struct PlayerRefDropViewDelegate: DropDelegate {
    var performDrop: (PlayerRef) -> Void

    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [UTType.plainText]).first else {
            return false
        }

        itemProvider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { (data, error) in
            if let data = data as? Data, let id = String(data: data, encoding: .utf8) {
                let realm = try! Realm()
                if let player = realm.object(ofType: PlayerRef.self, forPrimaryKey: id) {
                    performDrop(player)
                }
            }
        }
        return true
    }

    func dropEntered(info: DropInfo) {
        // Implement any visual feedback when the item is dragged over
    }
}
