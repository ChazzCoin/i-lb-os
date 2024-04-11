//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/10/24.
//

import Foundation
import RealmSwift


public enum FusedQueueType : String, CaseIterable {
    case create = "create"
    case delete = "delete"
    case update = "update"
}

public enum OperationType : String, CaseIterable {
    case create = "create"
    case delete = "delete"
    case update = "update"
}


public extension CoreUser {
    
    func fuseSaveToFirebase() {
        DatabasePaths.users.ref.child(self.id).setValue(self.toDict()) { error, _ in
            if let error = error {
                CoreUserQueue.addToUpdateQueue(item: self)
                print("FusedDatabaseQueue -> Error updating user \(self.id): \(error)")
                print("FusedDatabaseQueue -> Add User to UpdateQueue \(self.id)")
            } else {
                print("FusedDatabaseQueue -> Process Update Success.")
            }
        }
    }
    
    func fuseDeleteFromFirebase() {
        DatabasePaths.users.ref.child(self.id).removeValue() { error, _ in
            if let error = error {
                CoreUserQueue.addToDeleteQueue(item: self)
                print("FusedDatabaseQueue -> Error deleting user \(self.id): \(error)")
                print("FusedDatabaseQueue -> Add User to DeleteQueue \(self.id)")
            } else {
                print("FusedDatabaseQueue -> Process Delete Success.")
            }
        }
    }
    
}

public class CoreUserQueue {
    
    public static func FusedUpdateQueue(safeQueue: @escaping (FusedDatabaseQueue, Realm) -> Void) {
        let realm = newRealm()
        if let queue = realm.findByField(FusedDatabaseQueue.self, value: FusedQueueType.update.rawValue) {
            safeQueue(queue, realm)
        }
    }
    public static func FusedDeleteQueue(safeQueue: @escaping (FusedDatabaseQueue, Realm) -> Void) {
        let realm = newRealm()
        if let queue = realm.findByField(FusedDatabaseQueue.self, value: FusedQueueType.delete.rawValue) {
            safeQueue(queue, realm)
        }
    }
    public static func WriteToUpdateQueue(safeQueue: @escaping (FusedDatabaseQueue, Realm) -> Void) {
        let realm = newRealm()
        if let queue = realm.findByField(FusedDatabaseQueue.self, value: FusedQueueType.update.rawValue) {
            realm.safeWrite { r in
                safeQueue(queue, r)
            }
        }
    }
    
    public static func WriteToDeleteQueue(safeQueue: @escaping (FusedDatabaseQueue, Realm) -> Void) {
        let realm = newRealm()
        if let queue = realm.findByField(FusedDatabaseQueue.self, value: FusedQueueType.delete.rawValue) {
            realm.safeWrite { r in
                safeQueue(queue, r)
            }
        }
    }
    
    public static func initializeDatabaseQueue() {
        if let _ = newRealm().findByField(FusedDatabaseQueue.self, value: FusedQueueType.update.rawValue) {
            return
        }
        let updateQueue = FusedDatabaseQueue()
        updateQueue.id = FusedQueueType.update.rawValue
        
        let deleteQueue = FusedDatabaseQueue()
        deleteQueue.id = FusedQueueType.delete.rawValue
        
        newRealm().safeWrite { r in
            r.create(FusedDatabaseQueue.self, value: updateQueue, update: .all)
            r.create(FusedDatabaseQueue.self, value: deleteQueue, update: .all)
        }
    }
    // Add
    public static func addToUpdateQueue(item: CoreUser)  {
        WriteToUpdateQueue { q, _ in
            q.userQueue.append(item)
            print("CoreUserQueue: Added user update operation to queue.")
        }
    }
    public static func addToDeleteQueue(item: CoreUser) {
        WriteToDeleteQueue { q, _ in
            q.userQueue.append(item)
        }
    }
    // Pop
    public static func popFromUpdateQueue(onPop: @escaping (CoreUser) -> Void) {
        WriteToUpdateQueue { q, r in
            if let temp = q.userQueue.pop() {
                onPop(temp)
            }
        }
    }
    public static func popFromDeleteQueue(onPop: @escaping (CoreUser) -> Void) {
        WriteToDeleteQueue { q, _ in
            if let temp = q.userQueue.pop() {
                onPop(temp)
            }
        }
    }
    
    public static func processFullQueue() {
        processUpdateQueue()
        processDeleteQueue()
    }
    
    public static func processUpdateQueue() {
        FusedUpdateQueue(safeQueue: { queue, r in
            let userQueue = queue.userQueue.toArray()
            userQueue.forEach { u in
                DatabasePaths.users.ref.child(u.id).setValue(u.toDict()) { error, _ in
                    if let error = error {
                        print("FusedDatabaseQueue -> Error updating user \(u.id): \(error)")
                    } else {
                        print("FusedDatabaseQueue -> Process Update Success.")
                    }
                }
            }
            r.safeWrite { _ in
                queue.userQueue.removeAll()
            }
        })
    }
    public static func processDeleteQueue() {
        FusedDeleteQueue(safeQueue: { queue, r in
            let userQueue = queue.userQueue.toArray()
            userQueue.forEach { u in
                DatabasePaths.users.ref.child(u.id).removeValue()
            }
            r.safeWrite { _ in
                queue.userQueue.removeAll()
            }
        })
    }
    
}

public protocol FusedQueueProtocol {
    
    static var queueName: String { get }
    static func initializeDatabaseQueue()
    static func addToQueue<T: Object>(item: T, operationType: OperationType) where T: ObjectKeyIdentifiable
    static func removeFromQueue(item: Object)
    static func getItemObject(queueItem: Object) -> Object?
    static func popFromQueue() -> Object?
    static func objectIsInQueue(id: String) -> Bool
    static func processQueueItems()
    // New function to process all items in the queue
//    public static func processQueueItems() {
//        if let queueObject = newRealm().object(ofType: FusedDatabaseQueue.self, forPrimaryKey: queueName) {
//            
//            // Queue List
//            let items = queueObject.queue.toArray()
//            
//            // Loop Each Item in Queue
//            items.forEach { qItem in
//                
//                if let qObject = getItemObject(queueItem: qItem) {
//                    switch OperationType(rawValue: qItem.operationType) {
//                        case .create: DatabasePaths.reference(path: qItem.collectionName)?.setValue(qObject.toDict())
//                        case .delete: DatabasePaths.reference(path: qItem.collectionName)?.delete(id: qItem.itemId)
//                        case .update: DatabasePaths.reference(path: qItem.collectionName)?.setValue(qObject.toDict())
//                        default: break
//                    }
//                }
//                removeFromQueue(item: qItem)
//            }
//        }
//    }
}
//
public extension List where Element: RealmCollectionValue {
    func toArray() -> [Element] {
        return Array(self)
    }
}
