//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/9/24.
//

import Foundation
import FirebaseDatabase
import RealmSwift
import SwiftUI



public class FusedRealmFire<O:Object> : ObservableObject {
    
    @AppStorage("currentUserId", store: UserDefaults(suiteName: "worlds")) public var currentUserId: String = ""
    @AppStorage("currentRoomId", store: UserDefaults(suiteName: "worlds")) public var currentRoomId: String = ""
    @AppStorage("currentSessionId", store: UserDefaults(suiteName: "worlds")) public var currentSessionId: String = ""
    
    @Published public var childAddedHandler: DatabaseHandle? = nil
    @Published public var childChangedHandler: DatabaseHandle? = nil
    @Published public var childRemovedHandler: DatabaseHandle? = nil
    @Published public var ref = Database.database().reference()
    public let realmInstance: Realm = newRealm()
    
    @Published public var notificationToken: NotificationToken?
    @Published public var path: String = ""
    @Published public var lifeId: String = ""
    @Published public var sessionId: String = ""
    
    @Published public var isDeleted: Bool = false
    @Published public var hasChanged: Bool = false
    
    public init() {}
    
    public func load(lifeId: String, path: String, onLoad: @escaping (O) -> Void) {
        self.lifeId = lifeId
        self.path = path
        self.ref = self.ref.child(self.path).child(self.lifeId)
        self.loadFromFirebase(onResult: { item in
            onLoad(item)
        })
    }
    
    public func load(roomId: String, sessionId: String, path: String, onLoad: @escaping (O) -> Void) {
        self.path = path
        self.ref = self.ref.child(self.path).child(roomId).child(sessionId)
        self.ref.child(self.path).child(roomId).child(sessionId).observe(.childAdded) { snapshot in
            let obj = snapshot.toCoreObject(O.self)
            if let obj = obj { onLoad(obj) }
        }
        self.ref.child(self.path).child(roomId).child(sessionId).observe(.childChanged) { snapshot in
            let obj = snapshot.toCoreObject(O.self)
            if let obj = obj { onLoad(obj) }
        }
    }
    
    public func resetHasChanged() {
        DispatchQueue.main.async {
            self.hasChanged = false
        }
    }
    // Realm
    public func loadFromFirebase(onResult: ((O) -> Void)? = nil) {
        self.ref.get(onSnapshot: { snapshot in
            let obj = snapshot.toCoreObject(O.self)
            if let obj = obj { onResult?(obj) }
        })
    }

    // Firebase
    public func setReference(fullReference: DatabaseReference) {
        self.ref = fullReference
    }
    public func setReference(setReference: (DatabaseReference) -> DatabaseReference) {
        self.ref = setReference(self.ref)
    }
    
    public func start(fullReference: DatabaseReference?=nil) {
        if let fr = fullReference { self.ref = fr }
        childAdded()
        childChanged()
        childRemoved()
    }
    
    public func stop() {
        childAddedHandler = nil
        childChangedHandler = nil
        childRemovedHandler = nil
    }
    
    public func observeFire(onAdded: ((O) -> Void)? = nil, onChange: ((O) -> Void)? = nil, onDelete: ((O) -> Void)? = nil) {
        self.childAdded(onAdded: onAdded)
        self.childChanged(onChange: onChange)
        self.childRemoved(onDelete: onDelete)
    }
    
    public func childAdded(onAdded: ((O) -> Void)? = nil) {
        childAddedHandler = self.ref.observe(.childAdded, with: { snapshot in
            let obj = snapshot.toCoreObject(O.self, realm: self.realmInstance)
            if let obj = obj as? O {
                let o = obj.toDict()
                if o["lastUpdatedBy"] as? String == self.currentUserId { return }
                onAdded?(obj)
            }
            
        })
    }
    
    public func childChanged(onChange: ((O) -> Void)? = nil) {
        childChangedHandler = self.ref.observe(.value, with: { snapshot in
            let obj = snapshot.toCoreObjects(O.self, realm: self.realmInstance)
            if obj == nil {
                let obj = snapshot.toCoreObject(O.self, realm: self.realmInstance)
                if let obj = obj {
                    let o1 = obj.toDict()
                    if o1["lastUpdatedBy"] as? String == self.currentUserId { return }
                    onChange?(obj)
                }
                return
            }
            if let obj = obj {
                for o in obj {
                    let o1 = o.toDict()
                    if o1["lastUpdatedBy"] as? String == self.currentUserId { return }
                    onChange?(o)
                }
            }
            
        })
    }
    
    public func childRemoved(onDelete: ((O) -> Void)? = nil) {
        childRemovedHandler = ref.observe(.childRemoved, with: { snapshot in
            let obj = snapshot.deleteRealmObject(ofType: O.self)
            if let obj = obj as? O {
                onDelete?(obj)
            }
            
        })
    }
    
}
