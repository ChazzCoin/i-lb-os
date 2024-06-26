//
//  FirebaseService.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/1/23.
//

import Foundation
import FirebaseDatabase
import RealmSwift
import SwiftUI
import CoreEngine

class ActivityPlanService: ObservableObject {
    @Published var activityId: String = ""
    @State var realmInstance: Realm
    @Published var reference: DatabaseReference = Database.database().reference()
    @Published var observerHandle: DatabaseHandle?
    @Published var isObserving = false

    init(realm: Realm) {
        self.realmInstance = realm
    }

    func startObserving(activityId: String) {
        
//        if !userIsVerifiedToProceed()
//            || !self.realmInstance.isLiveSessionPlan(activityId: activityId)
//            || activityId.isEmpty { return }
        
        guard !isObserving else { return }
        self.activityId = activityId
        observerHandle = reference.child(DatabasePaths.activityPlan.rawValue)
            .child(activityId).observe(.value, with: { snapshot in
                print("New Activity Arriving...")
                let _ = snapshot.toCoreObjects(ActivityPlan.self, realm: self.realmInstance)
            })

        isObserving = true
    }

    func stopObserving() {
        guard isObserving, let handle = observerHandle else { return }
        reference.removeObserver(withHandle: handle)
        isObserving = false
        observerHandle = nil
    }

    
    deinit {
        stopObserving()
    }
    
}
