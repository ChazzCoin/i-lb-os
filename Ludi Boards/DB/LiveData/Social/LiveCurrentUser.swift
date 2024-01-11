//
//  LiveCurrentUser.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/6/24.
//

import Foundation
import SwiftUI
import RealmSwift

@propertyWrapper
struct LiveUser: DynamicProperty {
    @State var object: CurrentSolUser?=nil
    
    init() {
        if let user = newRealm().findByField(CurrentSolUser.self, value: "SOL") {
            self.object = user
        }
    }
    
    var wrappedValue: CurrentSolUser? {
        get {
            return self.object
        }
        set {
            self.object = newValue
        }
    }
    
    var projectedValue: Binding<CurrentSolUser?> {
        Binding<CurrentSolUser?>(
            get: {
                return self.object
            },
            set: { newValue in
                // Handle updates if needed
                print("LiveCurrentUser: newValue = [ \(String(describing: newValue)) ]")
            }
        )
    }
}

@propertyWrapper
struct LiveCurrentUser: DynamicProperty {
    let realmInstance: Realm = realm()
    @ObservedObject private var observer: RealmCurrentUserObserver = RealmCurrentUserObserver()
    @ObservedObject var logoutObserver = LogoutObserver()
    
    init() {
        self.observer.startObserver(primaryKey: "SOL", realm: self.realmInstance)
        self.logoutListener()
    }

    var wrappedValue: CurrentSolUser? {
        get {
            return self.observer.object
        }
        set {
            self.observer.object = newValue
        }
    }
    
    var projectedValue: Binding<CurrentSolUser?> {
        Binding<CurrentSolUser?>(
            get: {
                return self.observer.object
            },
            set: { newValue in
                // Handle updates if needed
                print("LiveCurrentUser: newValue = [ \(String(describing: newValue)) ]")
            }
        )
    }
    
    func loadByPrimaryKey(id:String, realm:Realm) {
        self.observer.startObserver(primaryKey: id, realm: realm)
        self.logoutListener()
    }
    
    func logoutListener() {
        self.logoutObserver.onLogout = {
            print("LiveCurrentUser: Logout Observer!!!!")
            self.destroy()
        }
    }
    
    func destroy() {
        self.observer.destroy()
    }
    
    func refreshFromFirebase() {
        syncUserFromFirebaseDb() { _ in
            print("User Updated")
        }
    }

}
class RealmCurrentUserObserver: ObservableObject {
    @Published var object: CurrentSolUser? = nil
    @Published var notificationToken: NotificationToken? = nil

    func startObserver(primaryKey: String, realm:Realm) {
        self.object = realm.object(ofType: CurrentSolUser.self, forPrimaryKey: primaryKey)
        // Setting up the observer
        notificationToken = self.object?.observe { [weak self] change in
            guard let self = self else { return }
            switch change {
                case .change:
                    print("LiveCurrentUser: onChange")
                    if ((self.object?.isInvalidated) != nil) {
                        destroy()
                        break
                    }
                    DispatchQueue.main.async {
                        self.objectWillChange.send()
                    }
                case .deleted, .error:
                    destroy()
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
