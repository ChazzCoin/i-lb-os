//
//  LiveConnections.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/6/24.
//

import Foundation
import SwiftUI
import RealmSwift
import FirebaseDatabase

@propertyWrapper
struct LiveSessionPlans: DynamicProperty {
    @ObservedObject var observer: RealmSessionPlanObserver
    @ObservedObject var sharedObserver: RealmUserToSessionObserver
    @ObservedObject var firebaseObserver = FirebaseSessionPlanObserver()
    @State var objects: Results<SessionPlan>? = nil
    @State var sharedIds: [String] = []
    @State var realmInstance: Realm
    @State var filterSharedOnly = false
    @State var userId = ""

    init(realmInstance: Realm = realm(), shared:Bool=false) {
        self.realmInstance = realmInstance
        self.filterSharedOnly = shared
        self.observer = RealmSessionPlanObserver()
        self.sharedObserver = RealmUserToSessionObserver()
        self.objects = self.observer.objects
    }

    var wrappedValue: Results<SessionPlan>? {
        get {
            if filterSharedOnly {
                return toShared()
            }
            return toNotShared()
        }
        set { objects = newValue }
    }
    
    var projectedValue: Binding<[SessionPlan]> {
        Binding<[SessionPlan]>(
            get: {
                if filterSharedOnly {
                    return toShared()?.toArray() ?? []
                }
                return toNotShared()?.toArray() ?? []
                
            },
            set: { newValue in
                // Handle updates if needed
                // Note: This might be complex depending on how you intend to sync changes back to Realm
            }
        )
    }
    
    func toArray() -> [SessionPlan?] {
        if let obj = objects {
            return Array(obj)
        }
        return []
    }
    
    func start() {
        
        DispatchQueue.main.async {
            safeFirebaseUserId() { id in
                self.userId = id
                self.observer.startObserver(realm: self.realmInstance)
                self.sharedObserver.startObserver(realm: self.realmInstance)
                fireGetSessionSharesAsync(id: id, realm: self.realmInstance)
                
                let sharedSess = self.realmInstance.objects(UserToSession.self)
                for i in sharedSess {
                    if id == i.guestId {
                        self.sharedIds.append(i.sessionId)
                    }
                }
            }
        }
    }
    
    func toNotShared() -> Results<SessionPlan>? {
        let obj = self.realmInstance.objects(SessionPlan.self).filter("NOT id IN %@", self.sharedIds)
        print("UserId: [ \(self.userId) ], Not Shared Ids: [ \(self.sharedIds) ], Not Shared Objs: [ \(obj) ]")
        return obj
    }
    
    func toShared() -> Results<SessionPlan>? {
        let obj = self.realmInstance.objects(SessionPlan.self).filter("id IN %@", self.sharedIds)
        print("UserId: [ \(self.userId) ], Shared Ids: [ \(self.sharedIds) ], Shared Objs: [ \(obj) ]")
        return obj
    }
    
    func startFirebaseObservation(block: @escaping (DatabaseReference) -> DatabaseReference) {
        firebaseObserver.startObserving(query: block(firebaseObserver.reference), realmInstance: self.realmInstance)
    }
    
    func startFirebaseObservation(block: @escaping (DatabaseReference) -> DatabaseQuery) {
        firebaseObserver.startObserving(query: block(firebaseObserver.reference), realmInstance: self.realmInstance)
    }

    func stopFirebaseObservation() {
        firebaseObserver.stopObserving()
    }
    
    func fireGetSessionSharesAsync(id:String, realm: Realm?=nil) {
        firebaseDatabase(collection: DatabasePaths.userToActivity.rawValue) { ref in
            ref.queryOrdered(byChild: "guestId").queryEqual(toValue: id)
                .observeSingleEvent(of: .value) { snapshot, _ in
                    let _ = snapshot.toLudiObjects(UserToSession.self, realm: realm)
                }
        }
    }

}

// Realm

class RealmSessionPlanObserver: ObservableObject {
    @Published var objects: Results<SessionPlan>? = nil
    @Published var watchedObjects: Results<SessionPlan>? = nil
    @Published var notificationToken: NotificationToken? = nil

    func startObserver(realm: Realm) {
        self.objects = realm.objects(SessionPlan.self)
        // Setting up the observer
        notificationToken = self.objects?.observe { [weak self] (changes: RealmCollectionChange) in
            guard let self = self else { return }
            switch changes {
                case .initial(_):
//                    self.watchedObjects = results
                    print("LiveSessionPlans: Initial")
                    self.objectWillChange.send()
                case .update(_, _, _, _):
//                    self.watchedObjects = results
                    print("LiveSessionPlans: Update")
                    self.objectWillChange.send()
                case .error(let error):
                    // An error occurred while opening the Realm file on the background worker thread
                    print("LiveSessionPlans: \(error)")
            }
        }
    }

    deinit {
        notificationToken?.invalidate()
    }
}

class RealmUserToSessionObserver: ObservableObject {
    @Published var shares: Results<UserToSession>? = nil
    @Published var sharedIds: [String] = []
    @Published var notificationToken: NotificationToken? = nil
    
    func startObserver(realm: Realm) {
        self.shares = realm.objects(UserToSession.self)

        // Setting up the observer
        notificationToken = self.shares?.observe { [weak self] (changes: RealmCollectionChange) in
            guard let self = self else { return }
            switch changes {
                case .initial(let results):
                    print("RealmUserToSessionObserver: Initial")
                    for i in results {
                        if !sharedIds.contains(i.sessionId) {
                            sharedIds.append(i.sessionId)
                        }
                    }
                    print("Shared Ids = [ \(sharedIds) ]")
                    fireGetSessionSharesAsync(realm: realm)
                    fireGetActivityPlansAsync(realm: realm)
                    self.objectWillChange.send()
                case .update(let results, let de, _, _):
                    print("RealmUserToSessionObserver: Update")
                    for i in results {
                        if !sharedIds.contains(i.sessionId) {
                            sharedIds.append(i.sessionId)
                        }
                    }
                    print("Shared Ids = [ \(sharedIds) ]")
                    for d in de {
                        sharedIds.remove(at: d)
                    }
                    fireGetSessionSharesAsync(realm: realm)
                    fireGetActivityPlansAsync(realm: realm)
                    self.objectWillChange.send()
                case .error(let error):
                    // An error occurred while opening the Realm file on the background worker thread
                    print("RealmUserToSessionObserver: \(error)")
            }
        }
    }
    
    func fireGetSessionSharesAsync(realm: Realm?=nil) {
        firebaseDatabase(collection: DatabasePaths.sessionPlan.rawValue) { ref in
            for i in self.sharedIds {
                ref.queryOrdered(byChild: "id").queryEqual(toValue: i)
                    .observeSingleEvent(of: .value) { snapshot, _ in
                        let _ = snapshot.toLudiObjects(SessionPlan.self, realm: realm)
                    }
            }
        }
    }
    
    func fireGetActivityPlansAsync(realm: Realm?=nil) {
        firebaseDatabase(collection: DatabasePaths.activityPlan.rawValue) { ref in
            for i in self.sharedIds {
                ref.queryOrdered(byChild: "sessionId").queryEqual(toValue: i)
                    .observeSingleEvent(of: .value) { snapshot, _ in
                        let _ = snapshot.toLudiObjects(SessionPlan.self, realm: realm)
                    }
            }
        }
    }

    deinit {
        notificationToken?.invalidate()
    }
}


// Firebase

class FirebaseSessionPlanObserver: ObservableObject {
    private var firebaseSubscription: DatabaseHandle?
    @Published var isObserving = false
    private var query: DatabaseQuery? = nil
    private var ref: DatabaseReference? = nil
    
    @Published var reference: DatabaseReference = Database
        .database()
        .reference()
        .child(DatabasePaths.sessionPlan.rawValue)

    func startObserving(query: DatabaseQuery, realmInstance: Realm) {
        guard !isObserving else { return }
        self.query = query
        firebaseSubscription = query.observe(.value, with: { snapshot in
            let _ = snapshot.toLudiObjects(SessionPlan.self, realm: realmInstance)
        })
        isObserving = true
    }
    func startObserving(query: DatabaseReference, realmInstance: Realm) {
        guard !isObserving else { return }
        self.ref = query
        firebaseSubscription = query.observe(.value, with: { snapshot in
            let _ = snapshot.toLudiObjects(SessionPlan.self, realm: realmInstance)
        })
        isObserving = true
    }

    func stopObserving() {
        if let subscription = firebaseSubscription {
            query?.removeObserver(withHandle: subscription)
            ref?.removeObserver(withHandle: subscription)
            reference.removeObserver(withHandle: subscription)
            firebaseSubscription = nil
        }
        isObserving = false
    }
    
    deinit {
        stopObserving()
    }
}
