//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/10/24.
//

import Foundation
import FirebaseDatabase
import RealmSwift


public func firebaseDatabaseSET(obj: RealmSwift.Object, block: @escaping (DatabaseReference) -> DatabaseReference) {
    if !UserTools.userIsVerifiedForFirebaseRequest() { return }
    let reference = Database.database().reference()
    block(reference).setValue(obj.toDict()) { (error: Error?, ref: DatabaseReference) in
        if let error = error { print("Error updating Firebase: \(error)") }
    }
}


public extension DatabaseReference {
        
    func get(_ onSnapshot: @escaping (DataSnapshot) -> Void) {
        if !UserTools.userIsVerifiedForFirebaseRequest() { return }
        self.observeSingleEvent(of: .value) { snapshot, _ in
            onSnapshot(snapshot)
        }
    }
    
    func delete(id: String) {
        if !UserTools.userIsVerifiedForFirebaseRequest() {
            return
        }
        self.child(id).removeValue()
    }
    
    func saveFused(obj: Object) {
        if !UserTools.userIsVerifiedForFirebaseRequest() {
//            FusedQueue.addToQueue(item: obj, operationType: OperationType.create.rawValue)
            return
        }
        self.setValue(obj.toDict())
    }
    
    func saveFused(id: String, obj: Object) {
        if !UserTools.userIsVerifiedForFirebaseRequest() {
//            FusedQueue.addToQueue(item: obj, operationType: OperationType.create.rawValue)
            return
        }
        self.child(id).setValue(obj.toDict())
    }
    
    func saveFused(collection: String, id: String, obj: Object) {
        if !UserTools.userIsVerifiedForFirebaseRequest() {
//            FusedQueue.addToQueue(item: obj, operationType: OperationType.create.rawValue)
            return
        }
        self.child(collection).child(id).setValue(obj.toDict())
    }
    
    func saveUserFused(obj: CoreUser) {
        if !UserTools.userIsVerifiedForFirebaseRequest() {
//            FusedQueue.addToQueue(item: obj, operationType: OperationType.create.rawValue)
            return
        }
        self.child(DatabasePaths.users.rawValue)
            .child(obj.id)
            .setValue(obj.toDict())
    }
    
}


