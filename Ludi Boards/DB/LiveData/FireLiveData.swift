//
//  FireLiveData.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/15/23.
//

import Foundation
import FirebaseDatabase


func fireGetReference(dbPath: DatabasePaths) -> DatabaseReference {
    return Database
        .database()
        .reference()
        .child(dbPath.rawValue)
}

func fireObserver(ref: DatabaseReference, completion: @escaping (DataSnapshot) -> Void) {
    ref.observe(.value, with: { snapshot in
        completion(snapshot)
    })
}

extension DatabaseReference {
    
    func fireObserver(completion: @escaping (DataSnapshot) -> Void) {
        self.observe(.value, with: { snapshot in
            completion(snapshot)
        })
    }
}


