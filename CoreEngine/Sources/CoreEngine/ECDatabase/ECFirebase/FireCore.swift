//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/5/24.
//

import Foundation
import FirebaseDatabase


// Database Reference
public func firebaseDatabase(block: @escaping (DatabaseReference) -> Void) {
    let reference = Database.database().reference()
    block(reference)
}


