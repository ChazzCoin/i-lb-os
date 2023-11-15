//
//  TeamLiveDat.swift
//  Ludi Sports
//
//  Created by Charles Romeo on 4/26/23.
//

import Foundation
import Firebase
import RealmSwift

protocol ValueEventListener {
    func onDataChange(snapshot: DataSnapshot)
    func onCancelled(error: Error)
}

class ManagedViewLiveData: NSObject {
    var viewId: String = ""
    private let realmInstance: Realm
    private var fireReferences: [String: DatabaseReference] = [:]
    private var reference: DatabaseReference
    private var enabled = false
    
    init(viewId: String, realmInstance: Realm) {
        self.viewId = viewId
        self.realmInstance = realmInstance
        self.reference = Database.database().reference().child(DatabasePaths.managedViews.rawValue)
        super.init()
        createObservers()
    }
    
    // Create Observer Pairs
    private func createObservers() {
        let referenceChild = reference.child(self.viewId)
        if enabled {
            referenceChild.observe(.value, with: { [weak self] snapshot in
                self?.onDataChange(snapshot: snapshot)
            })
        }
    }
    

    // Firebase Observer
    private func onDataChange(snapshot: DataSnapshot) {
        // Handle snapshot data conversion and update here
        var _ = snapshot.toLudiObject(ManagedView.self, realm: realmInstance)
    }
    
    // Enable/Disable Helpers
    func enable() {
        if enabled { return }
        enabled = true
        for (_, reference) in fireReferences {
            reference.observe(.value, with: { [weak self] snapshot in
                self?.onDataChange(snapshot: snapshot)
            })
        }
    }
    
    func disable() {
        if !enabled { return }
        enabled = false
        for (_, reference) in fireReferences {
            reference.removeAllObservers()
        }
    }
}



