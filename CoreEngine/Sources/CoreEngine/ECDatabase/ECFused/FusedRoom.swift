//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/10/24.
//

import Foundation
import SwiftUI
import RealmSwift
import FirebaseDatabase


public class FusedRoom : ObservableObject {
    
    @Published public var currentRoomId: String = ""
    @ObservedResults(UserInRoom.self) public var allUsersInRooms
    @ObservedResults(CoreUser.self) public var allUsers

    public var inRoom: Results<UserInRoom> {
        return allUsersInRooms.filter("roomId == %@", currentRoomId)
    }
    public var inRoomUserIds: [String] {
        return allUsersInRooms.filter("roomId == %@", currentRoomId).compactMap({ $0.guestId })
    }
    public var usersInRoom: Results<CoreUser> {
        return allUsers.filter("id IN %@", inRoomUserIds)
    }
    // Room
    @Published public var childAddedHandler: DatabaseHandle? = nil
    @Published public var childChangedHandler: DatabaseHandle? = nil
    @Published public var childRemovedHandler: DatabaseHandle? = nil
    @Published public var ref = Database.database().reference().child(DatabasePaths.rooms.rawValue)
    // Users In Room
    @Published public var userAddedHandler: DatabaseHandle? = nil
    @Published public var userChangedHandler: DatabaseHandle? = nil
    @Published public var userRemovedHandler: DatabaseHandle? = nil
    @Published public var userInRoomRef = Database.database().reference().child(DatabasePaths.userInRoom.rawValue)
    
    public let realmInstance: Realm = newRealm()
    
    public init() {}
    
    // Fused Firebase -> Realm
    public func start(roomId: String) {
        currentRoomId = roomId
        // UserInRoom
        userInRoomObservers()
        // Room
        roomObservers()
    }
    
    // UserInRoom
    public func userInRoomObservers() {
        userAddedHandler = ref
            .queryEqual(toValue: currentRoomId, childKey: "roomId")
            .observe(.childAdded, with: { snapshot in
                let _ = snapshot.toCoreObjects(UserInRoom.self, realm: self.realmInstance)
            })
        userChangedHandler = ref
            .queryEqual(toValue: currentRoomId, childKey: "roomId")
            .observe(.childChanged, with: { snapshot in
                let _ = snapshot.toCoreObjects(UserInRoom.self, realm: self.realmInstance)
            })
    }
    
    // Room
    public func roomObservers() {
        childAddedHandler = ref
            .observe(.childAdded, with: { snapshot in
                let _ = snapshot.toCoreObject(Room.self, realm: self.realmInstance)
            })
        childChangedHandler = ref
            .observe(.childChanged, with: { snapshot in
                let _ = snapshot.toCoreObject(Room.self, realm: self.realmInstance)
            })
        childRemovedHandler = ref
            .observe(.childRemoved, with: { snapshot in
                let _ = snapshot.deleteRealmObject(ofType: Room.self)
            })
    }
    
    // Utils
    public func stop() {
        userAddedHandler = nil
        userChangedHandler = nil
        childAddedHandler = nil
        childChangedHandler = nil
        childRemovedHandler = nil
    }
    
    private func getAllUsers() {
        DataPuller.getListOfUsers(ids: inRoomUserIds)
    }
    
}
