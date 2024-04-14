//
//  FirebaseService.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/1/23.
//

import Foundation
import FirebaseDatabase
import RealmSwift
import CoreEngine

class SessionPlanService: ObservableObject {
    let realmInstance: Realm
    var reference: DatabaseReference = Database.database().reference()
    private var observerHandle: DatabaseHandle?
    private var isObserving = false

    init(realm: Realm) {
        self.realmInstance = realm
    }

    func startObserving(sessionId: String) {
        
//        if !userIsVerifiedToProceed()
//            || self.realmInstance.isLiveSessionPlan(sessionId: sessionId) { return }
        
        guard !isObserving else { return }
        observerHandle = reference
            .child(DatabasePaths.sessionPlan.rawValue)
            .child(sessionId).observe(.value, with: { snapshot in
                print("New Session Arriving...")
                let _ = snapshot.toCoreObjects(SessionPlan.self, realm: self.realmInstance)
            })

        isObserving = true
    }
    
    func startObserving(ownerId: String? = UserTools.currentUserId) {
        guard let ownerId = ownerId else { return }
        guard !isObserving else { return }
        observerHandle = reference
            .child(DatabasePaths.sessionPlan.rawValue)
            .queryOrdered(byChild: "ownerId")
            .queryEqual(toValue: ownerId)
            .observe(.value, with: { snapshot in
                print("New Session Arriving...")
                let _ = snapshot.toCoreObjects(SessionPlan.self, realm: self.realmInstance)
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
