//
//  LiveCurrentUser.swift
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
struct LiveSolUser: DynamicProperty {
    let realmInstance: Realm = realm()
    @ObservedObject private var observer: RealmObserver = RealmObserver()
    @State var userId: String = ""
    @ObservedObject var logoutObserver = LogoutObserver()
    
    var wrappedValue: SolUser? {
        get {
            return self.realmInstance.findByField(SolUser.self, field: "userId", value: self.userId)
        }
        set {
            print("LiveSolUser: setting value = [ \(String(describing: self.observer.object)) ]")
            self.observer.object = newValue
        }
    }
    
    var projectedValue: Binding<SolUser?> {
        Binding<SolUser?>(
            get: { self.realmInstance.findByField(SolUser.self, field: "userId", value: self.userId) },
            set: { newValue in
                // Handle updates if needed
                print("LiveSolUser: newValue = [ \(String(describing: newValue)) ]")
            }
        )
    }
    
    func loadByUserId(id:String) {
        self.userId = id
        self.observer.startObserver(primaryKey: id, realm: self.realmInstance)
        fireGetSolUserAsync()
        self.logoutListener()
    }
    
    func logoutListener() {
        self.logoutObserver.onLogout = {
            print("LiveSolUser: Logout Observer!!!!")
            self.destroy()
        }
    }
    
    func destroy() {
        print("LiveSolUser: Destroying Thyself")
        self.observer.destroy(deleteObjects: true)
    }
    
    func fireGetSolUserAsync() {
        firebaseDatabase(collection: DatabasePaths.users.rawValue) { ref in
            ref.queryOrdered(byChild: "userId").queryEqual(toValue: self.userId)
                .observeSingleEvent(of: .value) { snapshot, _ in
                    print("Sol User Incoming: [ \(snapshot) ]")
                    let _ = snapshot.toLudiObjects(SolUser.self, realm: self.realmInstance)
                }
        }
    }

    private class RealmObserver: ObservableObject {
        @Published var object: SolUser? = nil
        @Published var notificationToken: NotificationToken? = nil

        func startObserver(primaryKey: String, realm:Realm) {
            self.object = realm.findByField(SolUser.self, field: "userId", value: primaryKey)
            // Setting up the observer
            notificationToken = self.object?.observe { [weak self] change in
                guard let self = self else { return }
                switch change {
                    case .change:
                        print("LiveSolUser: onChange")
                        self.objectWillChange.send()
                    case .deleted, .error:
                        break
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
            if let obj = self.object {
                realm().safeWrite { r in
                    r.delete(obj)
                }
            }
        }
        
        deinit {
            notificationToken?.invalidate()
        }
    }
}

class FirebaseSolUserService: ObservableObject {
    private var firebaseSubscription: DatabaseHandle?
    @Published var isObserving = false
    private var query: DatabaseQuery? = nil
    private var ref: DatabaseReference? = nil
    
    @Published var reference: DatabaseReference = Database
        .database()
        .reference()
        .child("users")

    func startObserving(query: DatabaseQuery, realmInstance: Realm) {
        if !isLoggedIntoFirebase() { return }
        guard !isObserving else { return }
        self.query = query
        firebaseSubscription = query.observe(.value, with: { snapshot in
            let _ = snapshot.toLudiObjects(Connection.self, realm: realmInstance)
        })
        isObserving = true
    }
    func startObserving(query: DatabaseReference, realmInstance: Realm) {
        if !isLoggedIntoFirebase() { return }
        guard !isObserving else { return }
        self.ref = query
        firebaseSubscription = query.observe(.value, with: { snapshot in
            let _ = snapshot.toLudiObjects(Connection.self, realm: realmInstance)
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
