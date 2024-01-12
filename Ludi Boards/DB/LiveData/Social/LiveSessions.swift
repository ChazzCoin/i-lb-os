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
import Combine

@propertyWrapper
struct LiveSessionPlans: DynamicProperty {
    @ObservedObject var observer: RealmSessionPlanObserver
    @ObservedObject var sharedObserver: RealmUserToSessionObserver
    @ObservedObject var firebaseObserver = FirebaseSessionPlanService()
    @State var objects: Results<SessionPlan>? = nil
    @State var sharedSess: Results<UserToSession>? = nil
    @State var sharedIds: [String] = []
    @State var realmInstance: Realm
    @State var filterSharedOnly = false
    @State var userId = ""
    
    @ObservedObject var logoutObserver = LogoutObserver()

    init(realmInstance: Realm = realm(), shared:Bool=false) {
        self.realmInstance = realmInstance
        self.filterSharedOnly = shared
        self.observer = RealmSessionPlanObserver()
        self.sharedObserver = RealmUserToSessionObserver()
        self.objects = self.observer.objects
        self.logoutListener()
    }
    
    func logoutListener() {
        self.logoutObserver.onLogout = {
            print("LiveSessionPlans: Logout Observer!!!!")
            self.destroy()
        }
    }
    
    func destroy() {
        print("LiveSessionPlans: Destroying Thyself")
        self.observer.destroy(deleteObjects: false)
        self.sharedObserver.destroy(deleteObjects: false)
        self.firebaseObserver.stopObserving()
        self.objects = nil
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
        safeFirebaseUserId() { id in
            self.userId = id
            self.observer.startObserver(realm: self.realmInstance)
            self.sharedObserver.startObserver(realm: self.realmInstance)
            fireGetSessionSharesAsync(id: id, realm: self.realmInstance)
            
            
            DispatchQueue.main.async {
                self.sharedSess = self.realmInstance.objects(UserToSession.self).filter("guestId == %@", id)
                if let temp = self.sharedSess {
                    for i in temp {
                        self.sharedIds.append(i.sessionId)
                    }
                }
            }
        }
        
    }
    
    func toNotShared() -> Results<SessionPlan>? {
//        DispatchQueue.main.async {
//            self.sharedSess = self.realmInstance.objects(UserToSession.self).filter("guestId == %@", self.userId)
//            if let temp = self.sharedSess {
//                for i in temp {
//                    self.sharedIds.append(i.sessionId)
//                }
//            }
//        }
        let obj = self.realmInstance.objects(SessionPlan.self).filter("NOT id IN %@", self.sharedIds)
        print("UserId: [ \(self.userId) ], Not Shared Ids: [ \(self.sharedIds) ], Not Shared Objs: [ \(obj) ]")
        return obj
    }
    
    func toShared() -> Results<SessionPlan>? {
//        DispatchQueue.main.async {
//            self.sharedSess = self.realmInstance.objects(UserToSession.self).filter("guestId == %@", self.userId)
//            if let temp = self.sharedSess {
//                for i in temp {
//                    self.sharedIds.append(i.sessionId)
//                }
//            }
//        }
        let obj = self.realmInstance.objects(SessionPlan.self).filter("id IN %@", self.sharedIds)
        print("UserId: [ \(self.userId) ], Shared Ids: [ \(self.sharedIds) ], Shared Objs: [ \(obj) ]")
        return obj
    }
    
//    func startFirebaseObservation(block: @escaping (DatabaseReference) -> DatabaseReference) {
//        firebaseObserver.startObserving(query: block(firebaseObserver.reference), realmInstance: self.realmInstance)
//    }
//    
//    func startFirebaseObservation(block: @escaping (DatabaseReference) -> DatabaseQuery) {
//        firebaseObserver.startObserving(query: block(firebaseObserver.reference), realmInstance: self.realmInstance)
//    }

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
        if !userIsVerifiedToProceed() { return }
        self.objects = realm.objects(SessionPlan.self)
        // Setting up the observer
        notificationToken = self.objects?.observe { [weak self] (changes: RealmCollectionChange) in
            guard let self = self else { return }
            switch changes {
                case .initial(_):
                    print("LiveSessionPlans: Initial")
                    DispatchQueue.main.async {
                        self.objectWillChange.send()
                    }
                    
                case .update(_, _, _, _):
                    print("LiveSessionPlans: Update")
                    DispatchQueue.main.async {
                        self.objectWillChange.send()
                    }
                case .error(let error):
                    print("LiveSessionPlans: \(error)")
                    destroy()
            }
        }
    }
    
    func destroy(deleteObjects:Bool=false) {
        notificationToken?.invalidate()
        if deleteObjects {
            deleteAll()
        }
    }
    
    func deleteAll() {
        if let objs = self.objects {
            realm().safeWrite { r in
                r.delete(objs)
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
    
    func startObserver(keepRunning:Bool=true, realm: Realm) {
        if !userIsVerifiedToProceed() { return }
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
                    if sharedIds.isEmpty {break}
                    FirebaseSessionPlanService.fireGetSessionAndActivitySharesAsync(sharedSessionIds: self.sharedIds, realm: realm)
                    if !keepRunning { destroy() }
                case .update(let results, _, _, _):
                    print("RealmUserToSessionObserver: Update")
                    for i in results {
                        if !sharedIds.contains(i.sessionId) {
                            sharedIds.append(i.sessionId)
                        }
                    }
                    print("Shared Ids = [ \(sharedIds) ]")
                    FirebaseSessionPlanService.fireGetSessionAndActivitySharesAsync(sharedSessionIds: self.sharedIds, realm: realm)
                    if !keepRunning { destroy() }
                case .error(let error):
                    print("RealmUserToSessionObserver: \(error)")
                    destroy()
            }
        }
        
    }
    
    func destroy(deleteObjects:Bool=false) {
        print("RealmUserToSessionObserver: Destroying Thyself.")
        self.shares = nil
        self.sharedIds = []
        notificationToken?.invalidate()
        notificationToken = nil
        if deleteObjects {
            deleteAll()
        }
    }
    
    func deleteAll() {
        if let objs = self.shares {
            newRealm().safeWrite { r in
                r.delete(objs)
            }
        }
    }

    deinit {
        notificationToken?.invalidate()
    }
}


// Firebase

class FirebaseSessionPlanService: ObservableObject {
    @State var firebaseSubscription: DatabaseHandle? = nil
    @ObservedObject var sharedObserver = RealmUserToSessionObserver()
    @Published var isObserving = false
    @State var query: DatabaseQuery? = nil
    @State var ref: DatabaseReference? = nil

    func startObserving(query: DatabaseQuery, realmInstance: Realm) {
        if !userIsVerifiedToProceed() { return }
        guard !isObserving else { return }
        self.query = query
        firebaseSubscription = query.observe(.value, with: { snapshot in
            let _ = snapshot.toLudiObjects(SessionPlan.self, realm: realmInstance)
        })
        isObserving = true
    }
    func startObserving(query: DatabaseReference, realmInstance: Realm) {
        if !userIsVerifiedToProceed() { return }
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
            firebaseSubscription = nil
        }
        isObserving = false
    }
    
    // Personal Setup
    
    static func fireGetSessionAsync(realm: Realm?=nil) {
        safeFirebaseUserId() { uId in
            firebaseDatabase(collection: DatabasePaths.sessionPlan.rawValue) { ref in
                ref
                    .queryOrdered(byChild: "ownerId")
                    .queryEqual(toValue: uId)
                    .observeSingleEvent(of: .value) { snapshot, _ in
                        let _ = snapshot.toLudiObjects(SessionPlan.self, realm: realm)
                    }
            }
        }
        
    }
    
    // Shared Setup
    
    static func runFullFetchProcess(realm: Realm?=nil) {
        let realmInstance = realm ?? newRealm()
        fireGetSessionAsync(realm: realmInstance)
        fireGetUserToSessionAsync(realm: realmInstance)
    }
    
    static func fireGetUserToSessionAsync(realm: Realm?=nil) {
        safeFirebaseUserId() { uId in
            firebaseDatabase(collection: DatabasePaths.userToActivity.rawValue) { ref in
                ref
                    .queryOrdered(byChild: "guestId")
                    .queryEqual(toValue: uId)
                    .observeSingleEvent(of: .value) { snapshot, _ in
                        if let results = snapshot.toLudiObjects(UserToSession.self, realm: realm) {
                            if !results.isEmpty {
                                var ids: [String] = []
                                for item in results {
                                    ids.append(item.sessionId)
                                }
                                fireGetSessionAndActivitySharesAsync(sharedSessionIds: ids, realm: realm)
                            }
                        }
                    }
            }
        }
    }
    
    static func fireGetSessionAndActivitySharesAsync(sharedSessionIds: [String], realm: Realm?=nil) {
        firebaseDatabase { db in
            for i in sharedSessionIds {
                db.child(DatabasePaths.sessionPlan.rawValue)
                    .queryOrdered(byChild: "id")
                    .queryEqual(toValue: i)
                    .observeSingleEvent(of: .value) { snapshot, _ in
                        let _ = snapshot.toLudiObjects(SessionPlan.self, realm: realm)
                    }
                db.child(DatabasePaths.activityPlan.rawValue)
                    .queryOrdered(byChild: "sessionId")
                    .queryEqual(toValue: i)
                    .observeSingleEvent(of: .value) { snapshot, _ in
                        let _ = snapshot.toLudiObjects(ActivityPlan.self, realm: realm)
                    }
            }
        }
    }
    
    deinit {
        stopObserving()
    }
}
