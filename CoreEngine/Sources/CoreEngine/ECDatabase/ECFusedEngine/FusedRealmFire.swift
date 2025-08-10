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
    
    @Published public var childAddedHandler: DatabaseHandle? = nil
    @Published public var childChangedHandler: DatabaseHandle? = nil
    @Published public var childRemovedHandler: DatabaseHandle? = nil
    @Published public var ref = Database.database().reference()
    public let realmInstance: Realm = newRealm()
    
    @Published public var notificationToken: NotificationToken?
    @Published public var path: String = ""
    @Published public var lifeId: String = ""
    
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
        childAddedHandler = ref.observe(.childAdded, with: { snapshot in
            let obj = snapshot.toCoreObject(O.self, realm: self.realmInstance)
            if let obj = obj as? O {
                let o = obj.toDict()
                if o["lastUpdatedBy"] as? String == self.currentUserId { return }
                onAdded?(obj)
            }
            
        })
    }
    
    public func childChanged(onChange: ((O) -> Void)? = nil) {
        childChangedHandler = ref.observe(.value, with: { snapshot in
            let obj = snapshot.toCoreObject(O.self, realm: self.realmInstance)
            if let obj = obj as? O {
                let o = obj.toDict()
                if o["lastUpdatedBy"] as? String == self.currentUserId { return }
                onChange?(obj)
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
