//
//  FireLiveData.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/15/23.
//

import Foundation
import FirebaseDatabase
import CoreEngine


func fireGetReference(dbPath: DatabasePaths) -> DatabaseReference {
    return Database
        .database()
        .reference()
        .child(dbPath.rawValue)
}

func fireObserver(ref: DatabaseReference, completion: @escaping (DataSnapshot) -> Void) -> DatabaseHandle {
    return ref.observe(.value, with: { snapshot in
        completion(snapshot)
    })
}

extension DatabaseReference {
    
    func fireObserver(completion: @escaping (DataSnapshot) -> Void) -> DatabaseHandle {
        return self.observe(.value, with: { snapshot in
            completion(snapshot)
        })
    }
}


