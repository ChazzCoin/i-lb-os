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


public class FusedCurrentUserFriends : ObservableObject {
    
    @AppStorage("currentUserId") public var currentUserId: String = ""

    @Published public var childAddedHandler: DatabaseHandle? = nil
    @Published public var childChangedHandler: DatabaseHandle? = nil
    @Published public var childRemovedHandler: DatabaseHandle? = nil
    @Published public var ref = Database.database().reference().child("friends")
    public let realmInstance: Realm = newRealm()
    
    public init() {}
    
    public func addFriend(friendId: String) {
        if let f = realmInstance.findByField(Friends.self, field: "userId", value: currentUserId) {
            realmInstance.safeWrite { r in
                f.friendIds.safeAddString(friendId)
                FusedDB.saveToFirebase(item: f)
            }
        }
    }
    
    // Fused Firebase -> Realm
    public func start() {
        childAdded()
        childChanged()
        childRemoved()
    }
    
    public func stop() {
        childAddedHandler = nil
        childChangedHandler = nil
        childRemovedHandler = nil
    }
    
    public func childAdded() {
        childAddedHandler = ref
            .queryEqual(toValue: currentUserId, childKey: "userId")
            .observe(.childAdded, with: { snapshot in
                let _ = snapshot.toCoreObject(Friends.self, realm: self.realmInstance)
            })
    }
    
    public func childChanged() {
        childChangedHandler = ref
            .queryEqual(toValue: currentUserId, childKey: "userId")
            .observe(.childChanged, with: { snapshot in
                let _ = snapshot.toCoreObject(Friends.self, realm: self.realmInstance)
            })
    }
    
    public func childRemoved() {
        childRemovedHandler = ref
            .queryEqual(toValue: currentUserId, childKey: "userId")
            .observe(.childRemoved, with: { snapshot in
                let _ = snapshot.deleteRealmObject(ofType: Friends.self)
            })
    }
    
}
