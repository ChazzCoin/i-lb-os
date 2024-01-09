//
//  FirebaseService.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/1/23.
//

import Foundation
import FirebaseDatabase
import RealmSwift

class ActivityPlanService: ObservableObject {
    let realmInstance: Realm
    var reference: DatabaseReference = Database.database().reference()
    private var observerHandle: DatabaseHandle?
    private var isObserving = false

    init(realm: Realm) {
        self.realmInstance = realm
    }

    func startObserving(activityId: String) {
        if !isLoggedIntoFirebase() { return }
        guard !isObserving else { return }
        observerHandle = reference.child(DatabasePaths.activityPlan.rawValue)
            .child(activityId).observe(.value, with: { snapshot in
                print("New Activity Arriving...")
                let _ = snapshot.toLudiObject(ActivityPlan.self, realm: self.realmInstance)
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
