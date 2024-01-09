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
struct LiveCurrentUser: DynamicProperty {
    let realmInstance: Realm = realm()
    @ObservedObject private var observer: RealmCurrentUserObserver = RealmCurrentUserObserver()
    @ObservedObject var logoutObserver = LogoutObserver()

    var wrappedValue: CurrentSolUser? {
        get {
            return self.realmInstance.findByField(CurrentSolUser.self, value: "SOL")
        }
        set {
            print("LiveCurrentUser: setting value = [ \(String(describing: self.observer.object)) ]")
            self.observer.object = newValue
        }
    }
    
    var projectedValue: Binding<CurrentSolUser?> {
        Binding<CurrentSolUser?>(
            get: { self.realmInstance.findByField(CurrentSolUser.self, value: "SOL") },
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
