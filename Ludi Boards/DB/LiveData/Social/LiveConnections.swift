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
struct LiveConnections: DynamicProperty {
    @ObservedObject private var observer: RealmObserver
    @ObservedObject private var firebaseObserver = FirebaseObserver()
    private var objects: Results<Connection>? = nil
    private var realmInstance: Realm
    var filterFriendsOnly = false
    var filterRequestsOnly = false

    init(realmInstance: Realm = realm(), friends:Bool=false, requests:Bool=false) {
        self.realmInstance = realmInstance
        self.filterFriendsOnly = friends
        self.filterRequestsOnly = requests
        self.observer = RealmObserver(realm: self.realmInstance)
        self.objects = self.observer.objects
    }

    var wrappedValue: Results<Connection>? {
        get { 
            if filterFriendsOnly {
                return toFriends()
            }
            if filterRequestsOnly {
                return toRequests()
            }
            return objects
        }
        set { objects = newValue }
    }
    
    var projectedValue: Binding<[Connection]> {
        Binding<[Connection]>(
            get: {
                if filterFriendsOnly {
                    return toFriends()?.toArray() ?? []
                }
                if filterRequestsOnly {
                    return toRequests()?.toArray() ?? []
                }
                return objects?.toArray() ?? []
                
            },
            set: { newValue in
                // Handle updates if needed
                // Note: This might be complex depending on how you intend to sync changes back to Realm
            }
        )
    }
    
    func toArray() -> [Connection?] {
        if let obj = objects {
            return Array(obj)
        }
        return []
    }
    
    func toFriends() -> Results<Connection>? {
        self.objects?.filter("status == 'Accepted'")
    }
    
    func toRequests() -> Results<Connection>? {
        self.objects?.filter("status == 'pending'")
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
    
    func refreshFromFirebase(block: @escaping (DatabaseReference) -> DatabaseReference) {
        firebaseDatabase { db in
            block(db).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    let objs = snapshot.toLudiObjects(Connection.self, realm: self.realmInstance)
                    print("Refreshed LiveConnections: \(String(describing: objs))")
                } else {
                    print("LiveConnections: Nothing Found")
                }
            }
        }
    }
    
    func refreshFromFirebase(block: @escaping (DatabaseReference) -> DatabaseQuery) {
        firebaseDatabase { db in
            block(db).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    let objs = snapshot.toLudiObjects(Connection.self, realm: self.realmInstance)
                    print("Refreshed LiveConnections: \(String(describing: objs))")
                } else {
                    print("LiveConnections: Nothing Found")
                }
            }
        }
    }

    private class RealmObserver: ObservableObject {
        @Published var objects: Results<Connection>
        private var notificationToken: NotificationToken?

        init(realm: Realm) {
            self.objects = realm.objects(Connection.self)

            // Setting up the observer
            notificationToken = self.objects.observe { [weak self] (changes: RealmCollectionChange) in
                guard let self = self else { return }
                switch changes {
                    case .initial(_):
                        // Results are now populated and can be accessed without blocking the UI
                        print("LiveConnections: Initial")
                        self.objectWillChange.send()
                    case .update(_, _, _, _):
                        print("LiveConnections: Update")
                        self.objectWillChange.send()
                    case .error(let error):
                        // An error occurred while opening the Realm file on the background worker thread
                        print("LiveConnections: \(error)")
                }
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

        func startObserving(query: DatabaseQuery, realmInstance: Realm) {
            guard !isObserving else { return }
            self.query = query
            firebaseSubscription = query.observe(.value, with: { snapshot in
                let _ = snapshot.toLudiObjects(Object.self, realm: realmInstance)
            })
            isObserving = true
        }
        func startObserving(query: DatabaseReference, realmInstance: Realm) {
            guard !isObserving else { return }
            self.ref = query
            firebaseSubscription = query.observe(.value, with: { snapshot in
                let _ = snapshot.toLudiObjects(Object.self, realm: realmInstance)
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

}
