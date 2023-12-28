//
//  FirebaseService.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/1/23.
//

import Foundation
import FirebaseDatabase
import RealmSwift


//
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
            .child(activityId).observe(.childAdded, with: { snapshot in
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
    @Published var realmInstance: Realm = realm()
    @Published var reference: DatabaseReference = Database.database().reference()
    @Published var observerHandle: DatabaseHandle?
    @Published var isObserving = false
    @Published var activityId = ""
    @Published var viewId = ""
    @Published var isDeleted: Bool = false
    
    init(realm: Realm, activityId:String, viewId:String) {
        self.realmInstance = realm
        self.activityId = activityId
        self.viewId = viewId
    }

    func start() {
        guard !isObserving else { return }
        observerHandle = reference.child(DatabasePaths.managedViews.rawValue)
            .child(activityId).child(viewId).observe(.value, with: { snapshot in
                let _ = snapshot.toLudiObject(ManagedView.self, realm: self.realmInstance)
            })
        reference.child(DatabasePaths.managedViews.rawValue)
               .child(activityId).child(viewId).observe(.childRemoved, with: { snapshot in
                   if let mv = self.realmInstance.findByField(ManagedView.self, value: self.viewId) {
                       if self.isDeleted {return}
                       self.isDeleted = true
                       self.realmInstance.safeWrite { r in
                           mv.isDeleted = true
                       }
                   }
               })
        isObserving = true
    }
    
    func observeActivity(activityId: String) {
        guard !isObserving else { return }
        observerHandle = reference.child(DatabasePaths.managedViews.rawValue)
            .child(activityId).observe(.childAdded, with: { snapshot in
                let _ = snapshot.toLudiObjects(ManagedView.self, realm: self.realmInstance)
            })

        isObserving = true
    }

    func stop() {
        guard isObserving, let handle = observerHandle else { return }
        reference.removeObserver(withHandle: handle)
        isObserving = false
        observerHandle = nil
    }
}
