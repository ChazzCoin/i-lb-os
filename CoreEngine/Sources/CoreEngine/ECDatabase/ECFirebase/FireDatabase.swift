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


public func FireReference(dbPath: DatabasePaths) -> DatabaseReference {
    return Database
        .database()
        .reference()
        .child(dbPath.rawValue)
}

public extension DatabaseReference {
    
    func get(onSnapshot: @escaping (DataSnapshot) -> Void) {
        self.observeSingleEvent(of: .value) { snapshot, _ in
            onSnapshot(snapshot)
        }
    }
    
    func save(obj: Object) {
        self.setValue(obj.toDict())
    }
    
    func fireObserveValue(completion: @escaping (DataSnapshot) -> Void) -> DatabaseHandle {
        return self.observe(.value, with: { snapshot in
            completion(snapshot)
        })
    }
    
    func fireObserveChildAdded(completion: @escaping (DataSnapshot) -> Void) -> DatabaseHandle {
        return self.observe(.childAdded, with: { snapshot in
            completion(snapshot)
        })
    }
    
    func fireObserveChildChanged(completion: @escaping (DataSnapshot) -> Void) -> DatabaseHandle {
        return self.observe(.childChanged, with: { snapshot in
            completion(snapshot)
        })
    }
    
    func fireObserveChildRemoved(completion: @escaping (DataSnapshot) -> Void) -> DatabaseHandle {
        return self.observe(.childRemoved, with: { snapshot in
            completion(snapshot)
        })
    }
}

