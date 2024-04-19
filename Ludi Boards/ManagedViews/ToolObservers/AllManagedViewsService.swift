//
//  FirebaseService.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/1/23.
//

import Foundation
import FirebaseDatabase
import RealmSwift
import CoreEngine


class AllManagedViewsService: ObservableObject {
    let realmInstance: Realm
    @Published var reference: DatabaseReference = Database.database().reference()
    @Published var observerHandle: DatabaseHandle?
    @Published var isObserving = false
    
    @Published var isLoggedIn: Bool = false

    init(realm: Realm) {
        self.realmInstance = realm
        verifyLoginStatus()
    }
    
    func verifyLoginStatus() { self.isLoggedIn = UserTools.isLoggedIn }

    func startObserving(activityId: String) {
        if !self.isLoggedIn || activityId == "SOL" {return}
        guard !isObserving else { return }
        observerHandle = reference.child(DatabasePaths.managedViews.rawValue)
            .child(activityId).observe(.childAdded, with: { snapshot in
                let _ = snapshot.toCoreObjects(ManagedView.self, realm: self.realmInstance)
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

/*
 THIS HAS BEEN MIGRATED INTO THE MANAGED VIEW OBJECT
 */
@available(*, deprecated, renamed: "ObservableResults", message: "Migrated to Observed Results.")
class SingleManagedViewService: ObservableObject {
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
    
    private var nofityToken: NotificationToken? = nil
    @Published var managedViewNotificationToken: NotificationToken? = nil
    
    func isDeletedChecker() -> Bool { return isDeleted }
    
    func initialize(realm: Realm, activityId:String, viewId:String) {
        if activityId == "SOL" { return }
        self.realmInstance = realm
        self.activityId = activityId
        self.viewId = viewId
        verifyLoginStatus()
        observeRealmUser()
        startFirebaseObserver()
    }
    
    func verifyLoginStatus() {
        self.isLoggedIn = UserTools.userIsVerifiedToProceed()
    }

    func startFirebaseObserver() {
        
        if isObserving || self.activityId.isEmpty || self.viewId.isEmpty {return}
        if !self.realmInstance.isLiveSessionPlan(activityId: self.activityId) { return }
        
        observerHandle = reference.child(self.activityId).child(self.viewId).observe(.value, with: { snapshot in
            let _ = snapshot.toLudiObject(ManagedView.self, realm: self.realmInstance)
        })
        reference.child(self.activityId).child(self.viewId).observe(.childRemoved, with: { snapshot in
           if let mv = self.realmInstance.findByField(ManagedView.self, value: self.viewId) {
               if self.isDeleted {return}
               main { self.isDeleted = true }
               self.realmInstance.safeWrite { r in
                   mv.isDeleted = true
               }
           }
       })
        main { self.isObserving = true }
    }
    
    func observeFirebaseActivity(activityId: String) {
        
        if !self.isLoggedIn || !self.realmInstance.isLiveSessionPlan(activityId: activityId) { return }
        
        guard !isObserving else { return }
        observerHandle = reference.child(activityId).observe(.childAdded, with: { snapshot in
                let _ = snapshot.toLudiObjects(ManagedView.self, realm: self.realmInstance)
            })

        isObserving = true
    }

    func stopFirebaseObserving() {
        guard isObserving, let handle = observerHandle else { return }
        reference.removeObserver(withHandle: handle)
        isObserving = false
        observerHandle = nil
    }
    
    func updateFirebase(mv: ManagedView?) {
        guard let mv = mv else { return }
        if mv.boardId == "SOL" { return }
        // Check if the user is logged in
        if shouldDenyWriteRequest() {
            return
        }
        main { self.isWriting = true }
        reference.child(mv.boardId).child(mv.id).setValue(mv.toDict()) { (error: Error?, ref: DatabaseReference) in
            main { self.isWriting = false }
            if let error = error { print("Error updating Firebase: \(error)") }
        }
    }
    
    func shouldDenyWriteRequest() -> Bool {
        if self.isWriting {
            print("Denying MVS Request: Writing")
            return true
        }
        if !UserTools.userIsVerifiedToProceed() {
            print("Denying MVS Request: Login")
            return true
        }
        print("Allowing MVS Request")
        return false
    }
    
    func observeRealmUser() {
        if let user = realmInstance.object(ofType: CoreUser.self, forPrimaryKey: CURRENT_USER_ID) {
            self.realmInstance.executeWithRetry {
                self.nofityToken = user.observe { change in
                    main {
                        switch change {
                            case .change(let obj, _):
                                print("Obj: \(obj)")
                                let temp = obj as! CoreUser
                                
                            case .error(let error):
                                print("Error: \(error)")
                                self.nofityToken?.invalidate()
                                self.nofityToken = nil
                            case .deleted:
                                print("Object has been deleted.")
                                self.nofityToken?.invalidate()
                                self.nofityToken = nil
                        }
                    }
                }
            }
        }
    }
    
    // Observe From Realm
    func observeRealmManagedView(onDeleted: @escaping () -> Void={}, onChange: @escaping (ManagedView) -> Void) {
        if let mv = self.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: self.viewId) {
            self.realmInstance.executeWithRetry {
                self.managedViewNotificationToken = mv.observe { change in
                    main {
                        switch change {
                            case .change(let obj, _):
                                if let temp = obj as? ManagedView {
                                    if temp.id == self.viewId { onChange(temp) }
                                }
                            case .error(let error):
                                print("Error: \(error)")
                                self.managedViewNotificationToken?.invalidate()
                                self.managedViewNotificationToken = nil
                            case .deleted:
                                print("Object has been deleted.")
                                self.managedViewNotificationToken?.invalidate()
                                self.managedViewNotificationToken = nil
                                onDeleted()
                        }
                    }
                    
                }
            }
            
        }

    }

    
}
