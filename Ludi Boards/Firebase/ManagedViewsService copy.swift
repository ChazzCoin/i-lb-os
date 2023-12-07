//
//  FirebaseService.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/1/23.
//

import Foundation
import FirebaseDatabase
import RealmSwift

class ManagedViewsService: ObservableObject {
    let realmInstance: Realm
    var reference: DatabaseReference = Database.database().reference()
    private var observerHandle: DatabaseHandle?
    private var isObserving = false

    init(realm: Realm) {
        self.realmInstance = realm
    }

    func startObserving(activityId: String) {
        guard !isObserving else { return }
        observerHandle = reference.child(DatabasePaths.managedViews.rawValue)
            .child(activityId).observe(.value, with: { snapshot in
                print("New Managed Views Arriving...")
                let _ = snapshot.toLudiObjects(ManagedView.self, realm: self.realmInstance)
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

class ManagedViewService: ObservableObject {
    let realmInstance: Realm
    var reference: DatabaseReference = Database.database().reference()
    private var observerHandle: DatabaseHandle?
    private var isObserving = false

    init(realm: Realm) {
        self.realmInstance = realm
    }

    func startObserving(activityId: String, viewId: String) {
        guard !isObserving else { return }
        observerHandle = reference.child(DatabasePaths.managedViews.rawValue)
            .child(activityId).child(viewId).observe(.value, with: { snapshot in
                print("New View Arriving...")
                let _ = snapshot.toLudiObject(ManagedView.self, realm: self.realmInstance)
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
