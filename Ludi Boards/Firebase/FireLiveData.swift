//
//  FireLiveData.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/15/23.
//

import Foundation
import FirebaseDatabase


extension DatabaseReference {
    func fireObserver(completion: @escaping (DataSnapshot) -> Void) {
        self.observe(.value, with: { snapshot in
            completion(snapshot)
        })
    }
}


