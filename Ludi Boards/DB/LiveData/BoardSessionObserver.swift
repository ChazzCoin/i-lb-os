//
//  BoardSessionObserver.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/16/24.
//

import Foundation
import RealmSwift
import SwiftUI
import FirebaseDatabase

class BoardSessionObserver: ObservableObject {
    let realmInstance: Realm
    let reference: DatabaseReference = Database.database().reference()
    
    let sessionRef: DatabaseReference
    let activityRef: DatabaseReference
    let managedViewRef: DatabaseReference
    
    @Published var sessionPlanHandler: DatabaseHandle?
    @Published var isObservingSessionPlan = false
    @Published var activityPlanHandler: DatabaseHandle?
    @Published var isObservingActivityPlan = false
    @Published var managedViewsAddHandler: DatabaseHandle?
    @Published var managedViewsRemoveHandler: DatabaseHandle?
    @Published var isObservingManagedViews = false
    
    @Published var sessionId: String = ""
    @Published var activityId: String = ""
    
    @Published private var managedViewTools: [ManagedView] = []

    init(realm: Realm?=nil) {
        self.realmInstance = realm ?? newRealm()
        self.sessionRef = self.reference.child(DatabasePaths.sessionPlan.rawValue)
        self.activityRef = self.reference.child(DatabasePaths.activityPlan.rawValue)
        self.managedViewRef = self.reference.child(DatabasePaths.managedViews.rawValue)
    }

    // Session Plan
    func observeSessionPlanById(sessionId: String) {
        if !userIsVerifiedToProceed() && !self.realmInstance.isLiveSessionPlan(sessionId: sessionId) { return }
        guard !isObservingSessionPlan else { return }
        self.sessionId = sessionId
        self.sessionPlanHandler = self.sessionRef
            .child(sessionId)
            .observe(.value, with: { snapshot in
                print("New Session Arriving...")
                let _ = snapshot.toLudiObject(SessionPlan.self, realm: self.realmInstance)
            })

        isObservingSessionPlan = true
    }
    
    func observeSessionPlanByOwnerId(ownerId: String? = getFirebaseUserId()) {
        guard let ownerId = ownerId else { return }
        guard !isObservingSessionPlan else { return }
        self.sessionPlanHandler = self.sessionRef
            .queryOrdered(byChild: "ownerId")
            .queryEqual(toValue: ownerId)
            .observe(.value, with: { snapshot in
                print("New Session Arriving...")
                let _ = snapshot.toLudiObject(SessionPlan.self, realm: self.realmInstance)
            })

        isObservingSessionPlan = true
    }
    
    func stopObservingSessionPlan() {
        guard self.isObservingSessionPlan, let handle = sessionPlanHandler else { return }
        self.sessionRef.removeObserver(withHandle: handle)
        self.isObservingSessionPlan = false
        self.sessionPlanHandler = nil
    }
    
    // Activity Plan
    func observeActivityPlanById(activityId: String) {
        if !userIsVerifiedToProceed() && !self.realmInstance.isLiveSessionPlan(activityId: activityId)  { return }
        guard !isObservingActivityPlan else { return }
        self.activityId = activityId
        self.activityPlanHandler = self.activityRef.child(DatabasePaths.activityPlan.rawValue)
            .child(activityId).observe(.value, with: { snapshot in
                print("New Activity Arriving...")
                let _ = snapshot.toLudiObject(ActivityPlan.self, realm: self.realmInstance)
            })

        isObservingActivityPlan = true
    }
    
    func stopObservingActivityPlan() {
        guard self.isObservingActivityPlan, let handle = activityPlanHandler else { return }
        self.activityRef.removeObserver(withHandle: handle)
        self.isObservingActivityPlan = false
        self.activityPlanHandler = nil
    }
    
    // Managed Views
    func observeManagedViewsByActivityId() {
        if self.activityId.isEmpty { return }
        if !userIsVerifiedToProceed() && !self.realmInstance.isLiveSessionPlan(activityId: activityId) { return }
        self.managedViewsAddHandler = self.managedViewRef
            .child(self.activityId)
            .observe(.childAdded, with: { snapshot in
                DispatchQueue.main.async {
                    if let temp = snapshot.value as? [String:Any] {
                        let mv = ManagedView(dictionary: temp)
                        if self.managedViewTools.hasView(mv) {
                            return
                        }
                        self.realmInstance.safeWrite { r in
                            r.create(ManagedView.self, value: mv, update: .all)
                        }
                        self.managedViewTools.safeAddManagedView(mv)
                    }
                }
            })
        
        self.managedViewsRemoveHandler = self.managedViewRef
            .child(self.activityId)
            .observe(.childRemoved, with: { snapshot in
                let temp = snapshot.toHashMap()
                if let tempId = temp["id"] as? String {
                    self.managedViewTools.safeRemoveById(tempId)
                }
            })
        self.isObservingManagedViews = true
    }
    
    func stopObservingManagedViews() {
        guard self.isObservingManagedViews, let handle = managedViewsRemoveHandler, let handle2 = managedViewsAddHandler else { return }
        self.managedViewRef.removeObserver(withHandle: handle)
        self.managedViewRef.removeObserver(withHandle: handle2)
        self.isObservingManagedViews = false
        self.managedViewsAddHandler = nil
        self.managedViewsRemoveHandler = nil
    }
    
    // Save To Firebase
    
    func savePlansToFirebase() {
        
        if !userIsVerifiedToProceed() { return }
        
        if self.sessionId == "SOL" || self.sessionId.isEmpty {return}
        if let sessionPlan = self.realmInstance.findByField(SessionPlan.self, field: "id", value: self.sessionId) {
            if sessionPlan.id == "SOL" {return}
            sessionPlan.fireSave(id: sessionPlan.id)
        }
        if self.activityId == "SOL" || self.activityId.isEmpty {return}
        if let activityPlan = self.realmInstance.findByField(ActivityPlan.self, field: "id", value: self.activityId) {
            if activityPlan.id == "SOL" {return}
            activityPlan.fireSave(id: activityPlan.id)
        }
    }
    
    // ALL
    
    func changeSession(sessionId: String) {
        self.sessionId = sessionId
        
    }
    
    func changeActivity(activityId: String) {
        self.activityId = activityId
        stopObservingActivityPlan()
        stopObservingManagedViews()
    }
    
//    func loadActivity(activityId: String) {
//        self.activityId = activityId
//        obser
//        
//    }
    
    func stopAll() {
        stopObservingSessionPlan()
        stopObservingActivityPlan()
        stopObservingManagedViews()
    }

    
}

