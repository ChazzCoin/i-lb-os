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
    @Published public var childAddedHandler: DatabaseHandle? = nil
    @Published public var childChangedHandler: DatabaseHandle? = nil
    @Published public var childRemovedHandler: DatabaseHandle? = nil
    @Published public var ref = Database.database().reference()
    public let realmInstance: Realm = newRealm()
    
    public init() {}
    
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
    
    public func childAdded() {
        childAddedHandler = ref.observe(.childAdded, with: { snapshot in
            let _ = snapshot.toCoreObject(O.self, realm: self.realmInstance)
        })
    }
    
    public func childChanged() {
        childChangedHandler = ref.observe(.childChanged, with: { snapshot in
            let _ = snapshot.toCoreObject(O.self, realm: self.realmInstance)
        })
    }
    
    public func childRemoved() {
        childRemovedHandler = ref.observe(.childRemoved, with: { snapshot in
            let _ = snapshot.deleteRealmObject(ofType: O.self)
        })
    }
    
}
