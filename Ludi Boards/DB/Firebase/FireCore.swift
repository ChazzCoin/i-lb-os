//
//  FireCore.swift
//
//  Created by Charles Romeo on 11/13/23.
//  Copyright © 2023 Ludi Software. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseDatabase
import CoreEngine

class FirebaseObserver<T:Object>: ObservableObject {
    @Published var realmInstance: Realm = newRealm()
    @Published var reference: DatabaseReference = Database.database().reference()
    @Published var observerHandle: DatabaseHandle?
    @Published var observerChildAdded: DatabaseHandle?
    @Published var observerChildDeleted: DatabaseHandle?
    @Published var observerChildChanged: DatabaseHandle?
    @Published var isObserving = false
    @Published var isDeleted: Bool = false
    
    @Published var objects: [T] = []
    
    init(collection:String) {
        self.reference = self.reference.child(collection)
    }

    func startObserving(realm: Realm=newRealm(), completion: @escaping (DataSnapshot) -> Void = { _ in }) {
        guard !isObserving else { return }
        
        observerHandle = self.reference.observe(.value, with: { snapshot in
            if let temp = snapshot.toLudiObjects(T.self, realm: realm) {
                self.objects.removeAll()
                self.objects = Array(temp)
                print("All objects: \(self.objects)")
            }
            completion(snapshot)
        })
        
        observerChildDeleted = self.reference.observe(.childRemoved, with: { snapshot in

            if snapshot.exists() {
                snapshot.parseSingleObject { obj in
                    if let objId = obj["id"] as? String {
                        
                        var temp = self.objects
                        for it in 0...temp.count {
                            if let t = temp[it]["id"] as? String {
                                if t == objId { temp.remove(at: it) }
                            }
                        }
                        
                        if let obj = self.realmInstance.findByField(T.self, value: objId) {
                            if obj.isInvalidated {return}
                            self.realmInstance.safeWrite { r in
                                r.delete(obj)
                            }
                        }
                        
                        self.objects = temp
                    }
                }
            }
        })
        
        isObserving = true
    }
    
    func startObserving(id: String, realm: Realm=newRealm(), onDelete: @escaping () -> Void = { }, onChange: @escaping (T) -> Void = { _ in }) {
        guard !isObserving else { return }
        // On Changed
        observerChildChanged = self.reference.child(id).observe(.value, with: { snapshot in
            if let results = snapshot.toLudiObject(T.self, realm: realm) {
                onChange(results)
            }
        })
        
        // On Delete
        observerChildDeleted = self.reference.observe(.childRemoved, with: { snapshot in
            if snapshot.exists() {
                if let obj = self.realmInstance.findByField(T.self, value: id) {
                    self.isDeleted = true
                    if obj.isInvalidated {return}
                    self.realmInstance.safeWrite { r in
                        r.delete(obj)
                    }
                }
                onDelete()
            }
        })
        isObserving = true
    }

    func stopObserving() {
        guard isObserving, let handle = observerHandle, let handle2 = observerChildDeleted, let handle3 = observerChildChanged else { return }
        reference.removeObserver(withHandle: handle)
        reference.removeObserver(withHandle: handle2)
        reference.removeObserver(withHandle: handle3)
        isObserving = false
        observerHandle = nil
    }
}
