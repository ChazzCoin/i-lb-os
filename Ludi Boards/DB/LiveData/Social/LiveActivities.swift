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
struct LiveActivityPlans: DynamicProperty {
    @ObservedObject private var observer: RealmObserver
    @ObservedObject private var firebaseObserver = FirebaseObserver()
    @State var objects: Results<ActivityPlan>? = nil
    var realmInstance: Realm
    @State var filterBySession = false
    @State var sessionId = ""
    
    @ObservedObject var logoutObserver = LogoutObserver()

    init(realmInstance: Realm = realm()) {
        self.realmInstance = realmInstance
        self.observer = RealmObserver(realm: self.realmInstance)
        self.logoutListener()
    }
    
    func logoutListener() {
        self.logoutObserver.onLogout = {
            print("LiveActivityPlans: Logout Observer!!!!")
            self.destroy()
        }
    }
    
    func destroy() {
        print("LiveActivityPlans: Destroying Thyself")
        self.observer.destroy(deleteObjects: false)
        self.firebaseObserver.stopObserving()
        self.objects = nil
    }

    var wrappedValue: Results<ActivityPlan>? {
        get {
            if self.filterBySession {
                return filterSessions()
            }
            return objects
        }
        set { objects = newValue }
    }
    
    var projectedValue: Binding<[ActivityPlan]> {
        Binding<[ActivityPlan]>(
            get: {
                if self.filterBySession {
                    return filterSessions()?.toArray() ?? []
                }
                return objects?.toArray() ?? []
            },
            set: { newValue in }
        )
    }
    
    func toArray() -> [ActivityPlan?] {
        if let obj = objects {
            return Array(obj)
        }
        return []
    }
    
    func filterSessions() -> Results<ActivityPlan>? {
        self.objects?.filter("sessionId == '\(self.sessionId)'")
    }
    
    func loadSessionById(sessionId: String) {
        self.sessionId = sessionId
        self.filterBySession = true
        self.objects = self.observer.objects
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

    private class RealmObserver: ObservableObject {
        @Published var objects: Results<ActivityPlan>
        private var notificationToken: NotificationToken?

        init(realm: Realm) {
            self.objects = realm.objects(ActivityPlan.self)

            // Setting up the observer
            notificationToken = self.objects.observe { [weak self] (changes: RealmCollectionChange) in
                guard let self = self else { return }
                switch changes {
                    case .initial(_):
                        // Results are now populated and can be accessed without blocking the UI
                        print("LiveActivityPlans: Initial")
                        self.objectWillChange.send()
                    case .update(_, _, _, _):
                        print("LiveActivityPlans: Update")
                        self.objectWillChange.send()
                    case .error(let error):
                        // An error occurred while opening the Realm file on the background worker thread
                        print("LiveActivityPlans: \(error)")
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
            realm().safeWrite { r in
                r.delete(self.objects)
            }
        }

        deinit {
            notificationToken?.invalidate()
        }
    }
    
    private class FirebaseObserver: ObservableObject {
        private var firebaseSubscription: DatabaseHandle?
        @Published var isObserving = false
        private var query: DatabaseQuery? = nil
        private var ref: DatabaseReference? = nil
        
        @Published var reference: DatabaseReference = Database
            .database()
            .reference()
            .child(DatabasePaths.activityPlan.rawValue)

        func startObserving(query: DatabaseQuery, realmInstance: Realm) {
            if !isLoggedIntoFirebase() { return }
            guard !isObserving else { return }
            self.query = query
            firebaseSubscription = query.observe(.value, with: { snapshot in
                let _ = snapshot.toLudiObjects(ActivityPlan.self, realm: realmInstance)
            })
            isObserving = true
        }
        func startObserving(query: DatabaseReference, realmInstance: Realm) {
            if !isLoggedIntoFirebase() { return }
            guard !isObserving else { return }
            self.ref = query
            firebaseSubscription = query.observe(.value, with: { snapshot in
                let _ = snapshot.toLudiObjects(ActivityPlan.self, realm: realmInstance)
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
    
    //
    
    

}
