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


//public extension CoreUser {
//    
//    func fuseSaveToFirebase() {
//        DatabasePaths.users.ref.child(self.id).setValue(self.toDict()) { error, _ in
//            if let error = error {
//                CoreUserQueue.addToUpdateQueue(item: self)
//                print("FusedDatabaseQueue -> Error updating user \(self.id): \(error)")
//                print("FusedDatabaseQueue -> Add User to UpdateQueue \(self.id)")
//            } else {
//                print("FusedDatabaseQueue -> Process Update Success.")
//            }
//        }
//    }
//    
//    func fuseDeleteFromFirebase() {
//        DatabasePaths.users.ref.child(self.id).removeValue() { error, _ in
//            if let error = error {
//                CoreUserQueue.addToDeleteQueue(item: self)
//                print("FusedDatabaseQueue -> Error deleting user \(self.id): \(error)")
//                print("FusedDatabaseQueue -> Add User to DeleteQueue \(self.id)")
//            } else {
//                print("FusedDatabaseQueue -> Process Delete Success.")
//            }
//        }
//    }
//    
//}

public class CoreUserQueue {
    
    
    
    
    // Add
//    public static func addToUpdateQueue(item: CoreUser)  {
//        MasterFusedQueue.WriteToUpdateQueue { q, _ in
//            q.userQueue.append(item)
//            print("CoreUserQueue: Added user update operation to queue.")
//        }
//    }
//    public static func addToDeleteQueue(item: CoreUser) {
//        MasterFusedQueue.WriteToDeleteQueue { q, _ in
//            q.userQueue.append(item)
//        }
//    }
//    // Pop
//    public static func popFromUpdateQueue(onPop: @escaping (CoreUser) -> Void) {
//        MasterFusedQueue.WriteToUpdateQueue { q, r in
//            if let temp = q.userQueue.pop() {
//                onPop(temp)
//            }
//        }
//    }
//    public static func popFromDeleteQueue(onPop: @escaping (CoreUser) -> Void) {
//        MasterFusedQueue.WriteToDeleteQueue { q, _ in
//            if let temp = q.userQueue.pop() {
//                onPop(temp)
//            }
//        }
//    }
//    
    
    
   
    
}


//
public extension List where Element: RealmCollectionValue {
    func toArray() -> [Element] {
        return Array(self)
    }
}
