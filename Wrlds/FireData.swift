//
//  FireData.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/14/23.
//

import Foundation
import FirebaseDatabase
import RealmSwift

func firebaseDatabase(block: @escaping (DatabaseReference) -> Void) {
    let reference = Database.database().reference()
    block(reference)
}

func firebaseDatabaseSET(obj: RealmSwift.Object, block: @escaping (DatabaseReference) -> DatabaseReference) {
    let reference = Database.database().reference()
    block(reference).setValue(obj.toDict()) { (error: Error?, ref: DatabaseReference) in
        if let error = error { print("Error updating Firebase: \(error)") }
    }
}


func firebaseDatabase(safeFlag:Bool, _ block: @escaping (DatabaseReference) -> Void) {
    if !safeFlag {return}
    let reference = Database.database().reference()
    block(reference)
}

func firebaseDatabase(collection: String, block: @escaping (DatabaseReference) -> Void) {
    let reference = Database.database().reference().child(collection)
    block(reference)
}

extension DatabaseReference {
    
    func get(onSnapshot: @escaping (DataSnapshot) -> Void) {
        self.observeSingleEvent(of: .value) { snapshot, _ in
            onSnapshot(snapshot)
        }
    }
    
    func save(obj: Object) {
        self.setValue(obj.toDict())
    }
    
}
