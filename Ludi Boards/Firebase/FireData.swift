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

func firebaseDatabase(collection: String, block: @escaping (DatabaseReference) -> Void) {
    let reference = Database.database().reference().child(collection)
    block(reference)
}

func fireManagedViewsAsync(boardId: String, realm: Realm) {
    firebaseDatabase(collection: DatabasePaths.managedViews.rawValue) { ref in
        ref.child(boardId).observeSingleEvent(of: .value) { snapshot, _ in
            var _ = snapshot.toLudiObjects(ManagedView.self)
        }
    }
}
