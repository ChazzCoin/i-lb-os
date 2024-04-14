//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/12/24.
//

import Foundation
import RealmSwift
import FirebaseDatabase

/*
    -> ANYTHING WITH THE NAME 'FUSE' IN IT...
        - It is 'fusing' together Realm and Firebase in some fashion.
            This could mean it is syncing them or parsing objects,
            either way, its using both to do what it needs to do.
 
     -> Adding Models to the FusedQueue
         1. Add List<Model> of the model object here.
             -> @Persisted public var modelQueue: List<Model> = List()
         2. Add the DatabasePath in the enum.
             -> case model: "model"
             -> path()
             -> objectType()
         3. Add the new path to every DatabasePath function and in the Extensions as well.
             -> getReference()
             -> getQueue()
             -> clearQueue()
         4. Add Models to MasterFusedQueue function
             -> addToQueue()
         5. You have now enabled fused caching for your new model object.
 
 */


public struct GlobalFused {
    public static let realmInstance = RealmInstance.instance
    public static let fireInstance = Database.database().reference()
}

public func fusedWriter(_ realm: Realm = newRealm(), _ action: @escaping (Realm) -> Object) {
    realm.safeWrite { r in FusedTools.saveToFirebase(item: action(r)) }
}

public func fusedCreator<O: Object>(_ obj: O.Type, _ realm: Realm = newRealm(), _ action: @escaping (Realm) -> O) {
    realm.safeWrite { r in
        let item = action(r)
        r.create(O.self, value: item, update: .all)
        FusedTools.saveToFirebase(item: item)
    }
}

public class FusedTools {
    
    // MASTER -> Realm & Firebase FusedSaved
    public static func fusedWriter(_ realm: Realm = newRealm(), action: @escaping (Realm) -> Object) {
        realm.safeWrite { r in FusedTools.saveToFirebase(item: action(r)) }
    }
    public static func fusedCreator<O: Object>(_ obj: O.Type, _ realm: Realm = newRealm(), _ action: @escaping (Realm) -> O) {
        realm.safeWrite { r in
            let item = action(r)
            r.create(O.self, value: item, update: .all)
            FusedTools.saveToFirebase(item: item)
        }
    }
    // Queries
    
    // MASTER -> Realm & Firebase FusedSearchSave
    public static func findByField<T:Object>(_ obj: T.Type, value: String, field: String="id", realm: Realm=newRealm(), onReturn: @escaping (List<T>) -> Void={ _ in }) {
        if let realmItems = realm.findAllByField(obj, field: field, value: value) {
            if !realmItems.isEmpty {
                onReturn(realmItems.toRealmList())
                return
            }
        }
        pullByFieldFromFirebase(obj, value: value, field: field, realm: realm, onReturn: onReturn)
    }
    
    public static func pullFromFirebase<T:Object>(_ obj: T.Type, id: String, realm: Realm=newRealm(), onReturn: @escaping (List<T>) -> Void={ _ in }) {
        DatabasePaths.path(forObjectType: obj)?.ref.child(id).pull(obj, onReturn: onReturn)
    }
    public static func fuseFromFirebase<T:Object>(_ obj: T.Type, id: String, realm: Realm=newRealm(), onReturn: @escaping (List<T>) -> Void={ _ in }) -> DatabaseHandle? {
        return DatabasePaths.path(forObjectType: obj)?.ref.child(id).fuse(obj, onReturn: onReturn)
    }
    public static func pullByFieldFromFirebase<T:Object>(_ obj: T.Type, value: String, field: String="id", realm: Realm=newRealm(), onReturn: @escaping (List<T>) -> Void={ _ in }) {
        DatabasePaths.path(forObjectType: obj)?.ref.pullByField(obj, value: value, field: field, onReturn: onReturn)
    }
    func fuseByFieldFromFirebase<T:Object>(_ obj: T.Type, value: String, field: String="id", realm: Realm=newRealm(), onReturn: @escaping (List<T>) -> Void={ _ in }) -> DatabaseHandle? {
        DatabasePaths.path(forObjectType: obj)?.ref.fuseByField(obj, value: value, field: field, onReturn: onReturn)
    }
    
    // Firebase Only + Caching
    public static func saveToFirebase<T: Object>(item: T) {
        if !UserTools.userIsVerifiedForFirebaseRequest() {
            MasterFusedQueue.addToQueue(queueType: .update, item: item)
            return
        }
        guard let path = DatabasePaths.path(forObjectType: T.self) else {
            MasterFusedQueue.addToQueue(queueType: .update, item: item)
            return
        }
        if let id = item.getId() {
            DatabasePaths
                .getReference(path: path)?
                .ref.child(id)
                .setValue(item.toDict()) { error, _ in
                    if let error = error {
                        print("FusedDatabaseQueue -> Error updating obj \(id): \(error)")
                        MasterFusedQueue.addToQueue(queueType: .update, item: item)
                    } else {
                        print("FusedDatabaseQueue -> Process Update Success.")
                    }
                }
        }
    }
    
    public static func deleteFromFirebase(item: Object, path: DatabasePaths) {
        if !UserTools.userIsVerifiedForFirebaseRequest() {
            MasterFusedQueue.addToQueue(queueType: .delete, item: item)
            return
        }
        if let id = item.getId() {
            DatabasePaths
                .getReference(path: path)?
                .ref.child(id)
                .setValue(item.toDict()) { error, _ in
                    if let error = error {
                        print("FusedDatabaseQueue -> Error updating obj \(id): \(error)")
                        MasterFusedQueue.addToQueue(queueType: .delete, item: item)
                    } else {
                        print("FusedDatabaseQueue -> Process Update Success.")
                    }
                }
        }
    }
}
