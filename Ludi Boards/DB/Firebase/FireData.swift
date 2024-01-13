//
//  FireData.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/14/23.
//

import Foundation
import FirebaseDatabase
import RealmSwift

// Firebase Extensions
extension Object {
    
    func fireRef(block: (DatabaseReference) -> Void) {
        if !userIsVerifiedToProceed() { return }
        if let path = DatabasePaths.path(forObjectType: Self.self) {
            block(
                Database
                    .database()
                    .reference()
                    .child(path.rawValue)
                )
        }
    }
    
    func fireRef(id:String, block: (DatabaseReference) -> Void) {
        if !userIsVerifiedToProceed() { return }
        if let path = DatabasePaths.path(forObjectType: Self.self) {
            block(Database
                .database()
                .reference()
                .child(path.rawValue)
                .child(id))
        }
    }
    
    func fireSave(id:String) {
        fireRef(id: id, block: { db in
            db.save(obj: self)
        })
    }
    
    func fireDelete(id:String) {
        fireRef(id: id, block: { db in
            db.delete(id: id)
        })
    }
    
    func fireGet(id:String) {
        fireRef(id: id, block: { db in
            db.get { snapshot in
                let _ = snapshot.toLudiObjects(Self.self)
            }
        })
    }
    
    func fireObserve(id:String, block: (DatabaseHandle) -> Void) {
        fireRef(id: id, block: { db in
            block(db.fireObserver(completion: { snapshot in
                let _ = snapshot.toLudiObjects(Self.self)
            }))
        })
    }
    
}

func safeRef(block: (DatabaseReference) -> Void) {
    if !userIsVerifiedToProceed() { return }
    block(Database.database().reference())
}

extension DatabaseReference {
        
    func get(onSnapshot: @escaping (DataSnapshot) -> Void) {
        if !userIsVerifiedToProceed() { return }
        self.observeSingleEvent(of: .value) { snapshot, _ in
            onSnapshot(snapshot)
        }
    }
    
    func delete(id: String) {
        if !userIsVerifiedToProceed() { return }
        self.child(id).removeValue()
    }
    
    func save(obj: Object) {
        if !userIsVerifiedToProceed() { return }
        self.setValue(obj.toDict())
    }
    
    func save(id: String, obj: Object) {
        if !userIsVerifiedToProceed() { return }
        self.child(id).setValue(obj.toDict())
    }
    
    func save(collection: String, id: String, obj: Object) {
        if !userIsVerifiedToProceed() { return }
        self.child(collection).child(id).setValue(obj.toDict())
    }
    
}

func firebaseDatabase(block: @escaping (DatabaseReference) -> Void) {
    if !userIsVerifiedToProceed() { return }
    let reference = Database.database().reference()
    block(reference)
}

func firebaseDatabaseSET(obj: RealmSwift.Object, block: @escaping (DatabaseReference) -> DatabaseReference) {
    if !userIsVerifiedToProceed() { return }
    let reference = Database.database().reference()
    block(reference).setValue(obj.toDict()) { (error: Error?, ref: DatabaseReference) in
        if let error = error { print("Error updating Firebase: \(error)") }
    }
}


func firebaseDatabase(safeFlag:Bool, _ block: @escaping (DatabaseReference) -> Void) {
    if !safeFlag {return}
    let reference = Database.database().reference()
    block(reference)
}

func firebaseDatabase(collection: String, block: @escaping (DatabaseReference) -> Void) {
    if !userIsVerifiedToProceed() { return }
    let reference = Database.database().reference().child(collection)
    block(reference)
}

// GET ManagedViews
func fireManagedViewsAsync(activityId: String, realm: Realm) {
    if !userIsVerifiedToProceed() { return }
    firebaseDatabase(collection: DatabasePaths.managedViews.rawValue) { ref in
        ref.child(activityId).observeSingleEvent(of: .value) { snapshot, _ in
            var _ = snapshot.toLudiObjects(ManagedView.self)
        }
    }
}

// GET Live Demo
func fireGetLiveDemoAsync(realm: Realm?=nil) {
    if !userIsVerifiedToProceed() { return }
    firebaseDatabase(collection: DatabasePaths.sessionPlan.rawValue) { ref in
        ref.child("SOL-LIVE-DEMO").observeSingleEvent(of: .value) { snapshot, _ in
            var _ = snapshot.toLudiObject(SessionPlan.self, realm: realm)
        }
    }
}

// GET Share Session
func fireGetSessionSharesAsync(userId: String, realm: Realm?=nil) {
    if !userIsVerifiedToProceed() { return }
    firebaseDatabase(collection: DatabasePaths.userToActivity.rawValue) { ref in
        ref.queryOrdered(byChild: "guestId").queryEqual(toValue: userId)
            .observeSingleEvent(of: .value) { snapshot, _ in
                var _ = snapshot.toLudiObjects(Share.self, realm: realm)
            }
    }
}

// GET Share Session
func fireGetSolUserAsync(userId: String, realm: Realm?=nil, onCompletion: @escaping ([SolUser]) -> Void={ _ in }) {
    if !userIsVerifiedToProceed() { return }
    firebaseDatabase(collection: DatabasePaths.users.rawValue) { ref in
        ref
            .queryOrdered(byChild: "userId")
            .queryEqual(toValue: userId)
            .observeSingleEvent(of: .value) { snapshot, _ in
                if let results = snapshot.toLudiObjects(SolUser.self, realm: realm) {
                    onCompletion(Array(results))
                }
            }
    }
}


// GET Sessions
func fireGetSessionPlanAsync(sessionId: String, realm: Realm) {
    if !userIsVerifiedToProceed() { return }
    firebaseDatabase(collection: DatabasePaths.sessionPlan.rawValue) { ref in
        ref.child(sessionId).observeSingleEvent(of: .value) { snapshot, _ in
            var _ = snapshot.toLudiObjects(SessionPlan.self, realm: realm)
        }
    }
}

func fireGetSessionsAsync(withIds ids: [String], completion: @escaping ([SessionPlan]?) -> Void) {
    if !userIsVerifiedToProceed() { return }
    for id in ids {
        let reference = Database.database().reference().child(DatabasePaths.sessionPlan.rawValue).child(id)
        reference.observeSingleEvent(of: .value) { snapshot, _ in
            let _ = snapshot.toLudiObject(SessionPlan.self)
        }
    }
}

// GET Activities
func fireActivityPlanAsync(activityId: String, realm: Realm) {
    if !userIsVerifiedToProceed() { return }
    firebaseDatabase(collection: DatabasePaths.activityPlan.rawValue) { ref in
        ref.child(activityId).observeSingleEvent(of: .value) { snapshot, _ in
            var _ = snapshot.toLudiObjects(ActivityPlan.self, realm: realm)
        }
    }
}
func fireGetActivitiesBySessionId(sessionId: String, realm: Realm?=nil) {
    if !userIsVerifiedToProceed() { return }
    firebaseDatabase(collection: DatabasePaths.activityPlan.rawValue) { ref in
        ref.queryOrdered(byChild: "sessionId").queryEqual(toValue: sessionId)
            .observeSingleEvent(of: .value) { snapshot, _ in
                var _ = snapshot.toLudiObjects(ActivityPlan.self, realm: realm)
            }
    }
}

func fireGetActivitiesAsync(withIds ids: [String], completion: @escaping ([ActivityPlan]?) -> Void) {
    if !userIsVerifiedToProceed() { return }
    for id in ids {
        let reference = Database.database().reference().child(DatabasePaths.activityPlan.rawValue).child(id)
        reference.observeSingleEvent(of: .value) { snapshot, _ in
            let _ = snapshot.toLudiObject(ActivityPlan.self)
        }
    }
}
