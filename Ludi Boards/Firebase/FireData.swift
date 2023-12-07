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

// GET ManagedViews
func fireManagedViewsAsync(activityId: String, realm: Realm) {
    firebaseDatabase(collection: DatabasePaths.managedViews.rawValue) { ref in
        ref.child(activityId).observeSingleEvent(of: .value) { snapshot, _ in
            var _ = snapshot.toLudiObjects(ManagedView.self)
        }
    }
}

// GET Live Demo
func fireGetLiveDemoAsync(realm: Realm?=nil) {
    firebaseDatabase(collection: DatabasePaths.sessionPlan.rawValue) { ref in
        ref.child("SOL-LIVE-DEMO").observeSingleEvent(of: .value) { snapshot, _ in
            var _ = snapshot.toLudiObject(SessionPlan.self, realm: realm)
        }
    }
}

// GET Share Session
func fireGetSessionSharesAsync(userId: String, realm: Realm?=nil) {
    firebaseDatabase(collection: DatabasePaths.userToSession.rawValue) { ref in
        ref.queryOrdered(byChild: "guestId").queryEqual(toValue: userId)
            .observeSingleEvent(of: .value) { snapshot, _ in
                var _ = snapshot.toLudiObjects(Share.self, realm: realm)
            }
    }
}


// GET Sessions
func fireGetSessionPlanAsync(sessionId: String, realm: Realm) {
    firebaseDatabase(collection: DatabasePaths.sessionPlan.rawValue) { ref in
        ref.child(sessionId).observeSingleEvent(of: .value) { snapshot, _ in
            var _ = snapshot.toLudiObjects(SessionPlan.self, realm: realm)
        }
    }
}

func fireGetSessionsAsync(withIds ids: [String], completion: @escaping ([SessionPlan]?) -> Void) {
    for id in ids {
        let reference = Database.database().reference().child(DatabasePaths.sessionPlan.rawValue).child(id)
        reference.observeSingleEvent(of: .value) { snapshot, _ in
            let _ = snapshot.toLudiObject(SessionPlan.self)
        }
    }
}

// GET Activities
func fireActivityPlanAsync(activityId: String, realm: Realm) {
    firebaseDatabase(collection: DatabasePaths.activityPlan.rawValue) { ref in
        ref.child(activityId).observeSingleEvent(of: .value) { snapshot, _ in
            var _ = snapshot.toLudiObjects(ActivityPlan.self, realm: realm)
        }
    }
}
func fireGetActivitiesBySessionId(sessionId: String, realm: Realm?=nil) {
    firebaseDatabase(collection: DatabasePaths.activityPlan.rawValue) { ref in
        ref.queryOrdered(byChild: "sessionId").queryEqual(toValue: sessionId)
            .observeSingleEvent(of: .value) { snapshot, _ in
                var _ = snapshot.toLudiObjects(ActivityPlan.self, realm: realm)
            }
    }
}

func fireGetActivitiesAsync(withIds ids: [String], completion: @escaping ([ActivityPlan]?) -> Void) {
    for id in ids {
        let reference = Database.database().reference().child(DatabasePaths.activityPlan.rawValue).child(id)
        reference.observeSingleEvent(of: .value) { snapshot, _ in
            let _ = snapshot.toLudiObject(ActivityPlan.self)
        }
    }
}
