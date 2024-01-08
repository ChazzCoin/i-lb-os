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
struct LiveSolUser: DynamicProperty {
    let realmInstance: Realm = realm()
    @ObservedObject private var observer: RealmObserver = RealmObserver()
    @State var userId: String = ""

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
    }
    
    func fireGetSolUserAsync() {
        firebaseDatabase(collection: DatabasePaths.users.rawValue) { ref in
            ref.queryOrdered(byChild: "userId").queryEqual(toValue: self.userId)
                .observeSingleEvent(of: .value) { snapshot, _ in
                    let results = snapshot.toLudiObjects(SolUser.self, realm: self.realmInstance)
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

        deinit {
            notificationToken?.invalidate()
        }
    }
}
