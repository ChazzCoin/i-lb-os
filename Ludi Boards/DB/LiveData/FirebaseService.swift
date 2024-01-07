//
//  FirebaseService.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/1/23.
//

import Foundation
import FirebaseDatabase

class FirebaseService {
    var reference: DatabaseReference
    private var observerHandle: DatabaseHandle?
    private var isObserving = false

    init(reference: DatabaseReference) {
        self.reference = reference
    }

    func startObserving(path: DatabaseReference, completion: @escaping (DataSnapshot) -> Void) {
        guard !isObserving else { return }
        self.reference = path
        observerHandle = reference.observe(.value, with: { snapshot in
            completion(snapshot)
        })

        isObserving = true
    }

    func stopObserving() {
        guard isObserving, let handle = observerHandle else { return }

        reference.removeObserver(withHandle: handle)
        isObserving = false
        observerHandle = nil
    }
}
