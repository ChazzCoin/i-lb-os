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


class LiveCurrentUser: ObservableObject {
    let realmInstance: Realm = realm()
    @ObservedObject var logoutObserver = LogoutObserver()
    @Published var object: CurrentSolUser? = nil
    @Published var notificationToken: NotificationToken? = nil
    
    func start() {
        self.startObserver(primaryKey: "SOL", realm: self.realmInstance)
        refreshFromFirebase()
        self.logoutListener()
    }

    func startObserver(primaryKey: String, realm:Realm) {
        self.object = realm.object(ofType: CurrentSolUser.self, forPrimaryKey: primaryKey)
        // Setting up the observer
        
        realm.executeWithRetry {
            self.notificationToken = self.object?.observe { [weak self] change in
                guard let self = self else { return }
                switch change {
                    case .change:
                        print("LiveCurrentUser: onChange")
                        if ((self.object?.isInvalidated) != nil) {
                            self.destroy()
                            break
                        }
                        DispatchQueue.main.async {
                            self.objectWillChange.send()
                        }
                    case .deleted, .error:
                        self.destroy()
                        break
                }
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

    
    func loadByPrimaryKey(id:String, realm:Realm) {
        self.startObserver(primaryKey: id, realm: realm)
        self.logoutListener()
    }
    
    func logoutListener() {
        self.logoutObserver.onLogout = {
            print("LiveCurrentUser: Logout Observer!!!!")
            self.destroy()
        }
    }
    
    func refreshFromFirebase() {
        UserTools.syncUserDetails()
    }

}
class RealmCurrentUserObserver: ObservableObject {
    @Published var object: CurrentSolUser? = nil
    @Published var notificationToken: NotificationToken? = nil

    func startObserver(primaryKey: String, realm:Realm) {
        self.object = realm.object(ofType: CurrentSolUser.self, forPrimaryKey: primaryKey)
        // Setting up the observer
        
        realm.executeWithRetry {
            self.notificationToken = self.object?.observe { [weak self] change in
                guard let self = self else { return }
                switch change {
                    case .change:
                        print("LiveCurrentUser: onChange")
                        if ((self.object?.isInvalidated) != nil) {
                            self.destroy()
                            break
                        }
                        DispatchQueue.main.async {
                            self.objectWillChange.send()
                        }
                    case .deleted, .error:
                        self.destroy()
                        break
                }
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
