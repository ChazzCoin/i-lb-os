//
//  FirebaseService.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/1/23.
//

import Foundation
import FirebaseDatabase
import RealmSwift


//
class ManagedViewsService: ObservableObject {
    let realmInstance: Realm
    @Published var reference: DatabaseReference = Database.database().reference()
    @Published var observerHandle: DatabaseHandle?
    @Published var isObserving = false
    
    @Published var isLoggedIn: Bool = false

    init(realm: Realm) {
        self.realmInstance = realm
        verifyLoginStatus()
    }
    
    func verifyLoginStatus() {
        self.isLoggedIn = realmInstance.userIsLoggedIn()
    }

    func startObserving(activityId: String) {
        if !self.isLoggedIn {return}
        guard !isObserving else { return }
        observerHandle = reference.child(DatabasePaths.managedViews.rawValue)
            .child(activityId).observe(.childAdded, with: { snapshot in
                let _ = snapshot.toLudiObjects(ManagedView.self, realm: self.realmInstance)
            })

        isObserving = true
    }

    func stopObserving() {
        guard isObserving, let handle = observerHandle else { return }
        reference.removeObserver(withHandle: handle)
        isObserving = false
        observerHandle = nil
    }
}

class ManagedViewService: ObservableObject {
    @Published var realmInstance: Realm = realm()
    @Published var reference: DatabaseReference = Database
        .database()
        .reference()
        .child(DatabasePaths.managedViews.rawValue)
    @Published var observerHandle: DatabaseHandle?
    @Published var isObserving = false
    @Published var activityId = ""
    @Published var viewId = ""
    @Published var isDeleted: Bool = false
    
    @Published var isLoggedIn: Bool = false
    @Published var isWriting: Bool = false
    
//    @Published var onChange: () -> Void = {}
    
    private var nofityToken: NotificationToken? = nil
    @Published var managedViewNotificationToken: NotificationToken? = nil
    
    func initialize(realm: Realm, activityId:String, viewId:String) {
        self.realmInstance = realm
        self.activityId = activityId
        self.viewId = viewId
        verifyLoginStatus()
        observeUser()
        start()
    }
    
    func verifyLoginStatus() {
        self.isLoggedIn = isLoggedIntoFirebase()
    }

    func start() {
//        if !self.isLoggedIn {return}
        guard !isObserving else { return }
        
        if self.activityId.isEmpty || self.viewId.isEmpty {return}
        
        observerHandle = reference.child(self.activityId).child(self.viewId).observe(.value, with: { snapshot in
            let _ = snapshot.toLudiObject(ManagedView.self, realm: self.realmInstance)
        })
        reference.child(self.activityId).child(self.viewId).observe(.childRemoved, with: { snapshot in
           if let mv = self.realmInstance.findByField(ManagedView.self, value: self.viewId) {
               if self.isDeleted {return}
               self.isDeleted = true
               self.realmInstance.safeWrite { r in
                   mv.isDeleted = true
               }
           }
       })
        isObserving = true
    }
    
    func observeActivity(activityId: String) {
        if !self.isLoggedIn {return}
        guard !isObserving else { return }
        observerHandle = reference.child(activityId).observe(.childAdded, with: { snapshot in
                let _ = snapshot.toLudiObjects(ManagedView.self, realm: self.realmInstance)
            })

        isObserving = true
    }

    func stop() {
        guard isObserving, let handle = observerHandle else { return }
        reference.removeObserver(withHandle: handle)
        isObserving = false
        observerHandle = nil
    }
    
    func updateFirebase(mv: ManagedView?) {
        guard let mv = mv else { return }
        // Check if the user is logged in
        if shouldDenyWriteRequest() {
            return
        }

        self.isWriting = true
        reference.child(mv.boardId).child(mv.id).setValue(mv.toDict()) { (error: Error?, ref: DatabaseReference) in
            self.isWriting = false
            if let error = error { print("Error updating Firebase: \(error)") }
        }
    }
    
    func shouldDenyWriteRequest() -> Bool {
        if self.isWriting {
            print("Denying MVS Request: Writing")
            return true
        }
        if !isLoggedIntoFirebase() {
            print("Denying MVS Request: Login")
            return true
        }
        print("Allowing MVS Request")
        return false
    }
    
    func observeUser() {
        if let user = realmInstance.object(ofType: CurrentSolUser.self, forPrimaryKey: CURRENT_USER_ID) {
            nofityToken = user.observe { change in
                switch change {
                    case .change(let obj, _):
                        print("Obj: \(obj)")
                        let temp = obj as! CurrentSolUser
                        self.isLoggedIn = temp.isLoggedIn
                    case .error(let error):
                        print("Error: \(error)")
                    case .deleted:
                        print("Object has been deleted.")
                }
            }
        }
    }
    
    func onChange() -> () -> Void {
        return {
            
        }
    }
    
    // Observe From Realm
    func observeManagedView(onChange: @escaping (ManagedView?) -> Void) {
        if let mv = self.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: self.viewId) {
            self.managedViewNotificationToken = mv.observe { change in
                switch change {
                    case .change(let obj, _):
                        let temp = obj as! ManagedView
                        onChange(temp)
                    case .error(let error):
                        print("Error: \(error)")
                    case .deleted:
                        onChange(nil)
                        print("Object has been deleted.")
                }
            }
        }

    }

    
}
