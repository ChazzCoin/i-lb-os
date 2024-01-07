//
//  RealmState.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/5/24.
//

import Foundation
import RealmSwift
import SwiftUI
import Combine
import FirebaseDatabase


@propertyWrapper
struct LiveStateObjects<Object: RealmSwift.Object>: DynamicProperty {
    @ObservedObject private var observer: RealmObserver<Object>
    @ObservedObject private var firebaseObserver = FirebaseObserver()
    private var objects: Results<Object>? = nil
    private var realmInstance: Realm

    init(_ objectType: Object.Type, realmInstance: Realm = realm()) {
        self.realmInstance = realmInstance
        self.observer = RealmObserver(objectType, realm: self.realmInstance)
        self.objects = self.observer.objects
    }

    var wrappedValue: Results<Object>? {
        get { objects }
        set { objects = newValue }
    }
    
    var projectedValue: Binding<[Object]> {
        Binding<[Object]>(
            get: { objects?.toArray() ?? [] },
            set: { newValue in
                // Handle updates if needed
                // Note: This might be complex depending on how you intend to sync changes back to Realm
            }
        )
    }
    
    func toArray() -> [Object?] {
        if let obj = objects {
            return Array(obj)
        }
        return []
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
                    let objs = snapshot.toLudiObjects(Object.self, realm: self.realmInstance)
                    print("Refreshed RealmListState: \(String(describing: objs))")
                } else {
                    print("Nothing Found")
                }
            }
        }
    }
    
    func refreshFromFirebase(block: @escaping (DatabaseReference) -> DatabaseQuery) {
        firebaseDatabase { db in
            block(db).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    let objs = snapshot.toLudiObjects(Object.self, realm: self.realmInstance)
                    print("Refreshed RealmListState: \(String(describing: objs))")
                } else {
                    print("Nothing Found")
                }
            }
        }
    }

    private class RealmObserver<O: RealmSwift.Object>: ObservableObject {
        @Published var objects: Results<O>
        private var notificationToken: NotificationToken?

        init(_ objectType: O.Type, realm: Realm) {
            self.objects = realm.objects(O.self)

            // Setting up the observer
            notificationToken = self.objects.observe { [weak self] (changes: RealmCollectionChange) in
                guard let self = self else { return }
                switch changes {
                    case .initial(_):
                        // Results are now populated and can be accessed without blocking the UI
                        print("RealmListState: Initial")
                        self.objectWillChange.send()
                    case .update(_, _, _, _):
                        print("RealmListState: Update")
                        self.objectWillChange.send()
                    case .error(let error):
                        // An error occurred while opening the Realm file on the background worker thread
                        print("RealmListState: \(error)")
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

// Working - but not updating in real-time
@propertyWrapper
struct LiveStateObject<Object: RealmSwift.Object>: DynamicProperty {
    @ObservedObject var realmObjectObserver: RealmObjectObserver<Object>
    @ObservedObject var firebaseObserver: FirebaseObserver<Object>
    private var objectType: Object.Type
    private var realmInstance: Realm = realm()

    init(_ objectType: Object.Type) {
        self.objectType = objectType
        self._realmObjectObserver = ObservedObject(wrappedValue: RealmObjectObserver<Object>(realm: realmInstance))
        self._firebaseObserver = ObservedObject(wrappedValue: FirebaseObserver<Object>())
    }

    var wrappedValue: Object? {
        get { self.realmObjectObserver.object }
        set { self.realmObjectObserver.object = newValue }
    }

    var projectedValue: Binding<Object?> {
        Binding<Object?>(
            get: { self.realmObjectObserver.object },
            set: { newValue in
                // Handle updates if needed
            }
        )
    }

    func load(primaryKey: String) {
        self.realmObjectObserver.start(realm: self.realmInstance, primaryKey: primaryKey)
    }
    
    func load(field: String, value: String) {
        self.realmObjectObserver.start(realm: self.realmInstance, field: field, value: value)
    }
    
    func startFirebaseObservation(block: @escaping (DatabaseReference) -> DatabaseReference) {
        firebaseObserver.startObserving(query: block(firebaseObserver.reference), realm: self.realmInstance)
    }
    
    func startFirebaseObservation(block: @escaping (DatabaseReference) -> DatabaseQuery) {
        firebaseObserver.startObserving(query: block(firebaseObserver.reference), realm: self.realmInstance)
    }
    
    func refreshFromFirebase(block: @escaping (DatabaseReference) -> DatabaseReference) {
        firebaseDatabase { db in
            block(db).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    let objs = snapshot.toLudiObject(Object.self, realm: self.realmInstance)
                    print("Refreshed LiveStateObject: \(String(describing: objs))")
                } else {
                    print("Nothing Found")
                }
            }
        }
    }
    
    func refreshFromFirebase(block: @escaping (DatabaseReference) -> DatabaseQuery) {
        firebaseDatabase { db in
            block(db).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    let objs = snapshot.toLudiObjects(Object.self, realm: self.realmInstance)
                    print("Refreshed LiveStateObject: \(String(describing: objs))")
                } else {
                    print("LiveStateObject: Nothing Found")
                }
            }
        }
    }

    class RealmObjectObserver<O: RealmSwift.Object>: ObservableObject {
        @Published var object: O?
        @Published var realmInstance: Realm
        @Published var notificationToken: NotificationToken? = nil
        
        init(realm:Realm=realm()) {
            self.realmInstance = realm
        }
        
        func start(realm: Realm, primaryKey: String) {
            self.realmInstance = realm
            load(primaryKey: primaryKey)
        }
        
        func start(realm: Realm, field: String, value: String) {
            self.realmInstance = realm
            load(field: field, value: value)
        }
        
        private func load(primaryKey: String) {
            
            self.object = self.realmInstance.object(ofType: O.self, forPrimaryKey: primaryKey)
            notificationToken = self.object?.observe { [weak self] change in
                switch change {
                case .change:
                    print("LiveStateObject: Realm Update")
                    self?.objectWillChange.send()
                case .deleted, .error:
                    break
                }
            }
        }
        
        private func load(field: String, value: String) {
            self.object = self.realmInstance.findByField(O.self, field: field, value: value)
            notificationToken = self.object?.observe { [weak self] change in
                switch change {
                case .change:
                    print("LiveStateObject: Realm Update")
                    self?.objectWillChange.send()
                case .deleted, .error:
                    break
                }
            }
        }
        
        func stop() {
            notificationToken?.invalidate()
        }


        deinit {
            notificationToken?.invalidate()
        }
    }
    
    class FirebaseObserver<O: RealmSwift.Object>: ObservableObject {
        @Published var object: O?
        @Published var notificationToken: NotificationToken? = nil
        @Published var firebaseSubscription: DatabaseHandle? = nil
        @Published var query: DatabaseQuery? = nil
        @Published var reference: DatabaseReference = Database
            .database()
            .reference()

        func startObserving(query: DatabaseReference, realm: Realm) {
            self.reference = query
            firebaseSubscription = query.observe(.value, with: { snapshot in
                let _ = snapshot.toLudiObject(Object.self, realm: realm)
            })
        }
        
        func startObserving(query: DatabaseQuery, realm: Realm) {
            self.query = query
            firebaseSubscription = query.observe(.value, with: { snapshot in
                let _ = snapshot.toLudiObject(Object.self, realm: realm)
            })
        }

        func stopObserving() {
            if let subscription = firebaseSubscription {
                self.reference.removeObserver(withHandle: subscription)
                self.query?.removeObserver(withHandle: subscription)
                firebaseSubscription = nil
            }
        }

        deinit {
            notificationToken?.invalidate()
            stopObserving()
        }
    }
    
    
}

class LiveObject<T: Object>: ObservableObject {
    @Published var object: T? = nil
}
//

