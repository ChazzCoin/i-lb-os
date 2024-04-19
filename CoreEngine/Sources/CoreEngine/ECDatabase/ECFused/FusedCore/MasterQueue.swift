//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/11/24.
//

import Foundation
import RealmSwift

/*
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

public enum FusedQueueType : String, CaseIterable {
//    case create = "create"
    case delete = "delete"
    case update = "update"
    case cache = "cache"
}

public enum OperationType : String, CaseIterable {
//    case create = "create"
    case delete = "delete"
    case update = "update"
}

public class MasterFusedQueue {
    
    public static var updateQueue: FusedDatabaseQueue? { return newRealm().findByField(FusedDatabaseQueue.self, value: FusedQueueType.update.rawValue) }
    public static var deleteQueue: FusedDatabaseQueue? { return newRealm().findByField(FusedDatabaseQueue.self, value: FusedQueueType.delete.rawValue) }
    
    public static func initializeQueues() {
        MasterFusedQueue.initializeDatabaseQueues()
    }
    
    public static func runAllQueues() {
        if UserTools.userIsVerifiedForFirebaseRequest() {
            MasterFusedQueue.processFullQueue()
        }
    }
    
    public static func initializeDatabaseQueues() {
        if let _ = newRealm().findByField(FusedDatabaseQueue.self, value: FusedQueueType.update.rawValue) {
            return
        }
        // Create/Update Queue
        let updateQueue = FusedDatabaseQueue()
        updateQueue.id = FusedQueueType.update.rawValue
        // Delete Queue
        let deleteQueue = FusedDatabaseQueue()
        deleteQueue.id = FusedQueueType.delete.rawValue
        // Internal Caching Queue
        let cacheQueue = FusedDatabaseQueue()
        cacheQueue.id = FusedQueueType.cache.rawValue
        
        realmWriter { r in
            r.create(FusedDatabaseQueue.self, value: updateQueue, update: .all)
            r.create(FusedDatabaseQueue.self, value: deleteQueue, update: .all)
            r.create(FusedDatabaseQueue.self, value: cacheQueue, update: .all)
        }
    }
    public static func FusedQueue(queueType: FusedQueueType, safeQueue: @escaping (FusedDatabaseQueue, Realm) -> Void) {
        let realm = newRealm()
        if let queue = realm.findByField(FusedDatabaseQueue.self, value: queueType.rawValue) {
            safeQueue(queue, realm)
        }
    }
    public static func WriteToQueue(queueType: FusedQueueType, safeQueue: @escaping (FusedDatabaseQueue, Realm) -> Void) {
        let realm = newRealm()
        if let queue = realm.findByField(FusedDatabaseQueue.self, value: queueType.rawValue) {
            realm.safeWrite { r in
                safeQueue(queue, r)
                print("Successfully written to queue.")
            }
        }
    }
    public static func addToQueue<T>(queueType: FusedQueueType, item: T) {
        MasterFusedQueue.WriteToQueue(queueType: queueType) { q, _ in
            switch item {
                case let userItem as CoreUser:
                    q.userQueue.safeAddReplace(userItem)
                case let roomItem as Room:
                    q.roomQueue.safeAddReplace(roomItem)
                case let userInRoomItem as UserInRoom:
                    q.userInRoomQueue.safeAddReplace(userInRoomItem)
                case let playerItem as PlayerRef:
                    q.playersQueue.safeAddReplace(playerItem)
                case let organizationItem as Organization:
                    q.organizationsQueue.safeAddReplace(organizationItem)
                case let teamItem as Team:
                    q.teamsQueue.safeAddReplace(teamItem)
                case let chatItem as Chat:
                    q.chatQueue.safeAddReplace(chatItem)
                case let eventItem as CoreEvent:
                    q.eventsQueue.safeAddReplace(eventItem)
                case let sessionPlanItem as SessionPlan:
                    q.sessionPlanQueue.safeAddReplace(sessionPlanItem)
                case let activityPlanItem as ActivityPlan:
                    q.activityPlanQueue.safeAddReplace(activityPlanItem)
                case let userToSessionItem as UserToSession:
                    q.userToSessionQueue.safeAddReplace(userToSessionItem)
                case let userToActivityItem as UserToActivity:
                    q.userToActivityQueue.safeAddReplace(userToActivityItem)
                case let friendRequestsItem as FriendRequest:
                    print("Adding Friend Request to Queue.")
                    q.friendRequestsQueue.safeAddReplace(friendRequestsItem)
                default: print("No Update Queue Available for this Object: \(type(of: item))")
            }
        }
    }

    public static func processFullQueue() {
        processUpdateQueue()
        processDeleteQueue()
    }
    
    public static func processUpdateQueue() {
        FusedQueue(queueType: .update, safeQueue: { queue, r in
            // Loop Each Realm Object Type (Queue)
            DatabasePaths.allCases.forEach { path in
                // Get the Specific QueueList out of the Main Queue Wrapper.
                DatabasePaths.getQueue(path: path.rawValue, queueType: .update)?.forEach { item in
                    // Update Object in Firebase
                    if let id = item.getId() {
                        DatabasePaths
                            .getReference(path: path)?
                            .ref.child(id)
                            .setValue(item.toDict()) { error, _ in
                                if let error = error {
                                    print("FusedDatabaseQueue -> Error updating obj \(id): \(error)")
                                } else {
                                    print("FusedDatabaseQueue -> Process Update Success.")
                                }
                            }
                    }
                    
                }
                // Clear Specific QueueList
                DatabasePaths.clearQueue(path: path.rawValue, queueType: .update)
            }
        })
    }
    public static func processDeleteQueue() {
        FusedQueue(queueType: .delete, safeQueue: { queue, r in
            // Loop Each Realm Object Type (Queue)
            DatabasePaths.allCases.forEach { path in
                // Get the Specific QueueList out of the Main Queue Wrapper.
                DatabasePaths.getQueue(path: path.rawValue, queueType: .delete)?.forEach { item in
                    // Update Object in Firebase
                    if let id = item.getId() {
                        DatabasePaths
                            .getReference(path: path)?
                            .ref.child(id)
                            .removeValue() { error, _ in
                                if let error = error {
                                    print("FusedDatabaseQueue -> Error deleting obj \(id): \(error)")
                                } else {
                                    print("FusedDatabaseQueue -> Process Delete Success.")
                                }
                            }
                    }
                }
                // Clear Specific QueueList
                DatabasePaths.clearQueue(path: path.rawValue, queueType: .delete)
            }
        })
    }
}







//            // User Queue
//            userQueue.forEach { u in
//                DatabasePaths
//                    .getReference(path: DatabasePaths.users)?
//                    .ref.child(u.id)
//                    .setValue(u.toDict()) { error, _ in
//                        if let error = error {
//                            print("FusedDatabaseQueue -> Error updating user \(u.id): \(error)")
//                        } else {
//                            print("FusedDatabaseQueue -> Process Update Success.")
//                        }
//                    }
//            }
//            r.safeWrite { _ in
//                queue.userQueue.removeAll()
//            }
            //
