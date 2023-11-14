//
//  TeamLiveDat.swift
//  Ludi Sports
//
//  Created by Charles Romeo on 4/26/23.
//

import Foundation
import Firebase
import RealmSwift

class BoardSessionLiveData: NSObject {
    private let boardId: String
    private let realmInstance: Realm
    private var fireReferences: [String: DatabaseReference] = [:]
    private var notificationTokens: [NotificationToken] = []
    private var reference: DatabaseReference
    private var enabled = false
    
    init(boardId: String, realmInstance: Realm) {
        self.boardId = boardId
        self.realmInstance = realmInstance
        self.reference = Database.database().reference().child(DatabasePaths.managedViews.rawValue)
        super.init()
        createObservers()
        observeBoardId()
    }
    
    // Create Observer Pairs
    private func createObservers() {
        let referenceChild = reference.child(self.boardId)
        fireReferences[self.boardId] = referenceChild
        if enabled {
            referenceChild.observe(.value, with: { [weak self] snapshot in
                self?.onDataChange(snapshot: snapshot)
            })
        }
    }
    
    // Realm Observer
    private func observeBoardId() {
        let results = realmInstance.objects(ManagedView.self)
        for result in results {
            let token = result.observe { [weak self] _ in
                guard self != nil else { return }
//                self.realmInstance.object(ofType: ManagedView.self, forPrimaryKey: self.boardId)
            }
            notificationTokens.append(token)
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



