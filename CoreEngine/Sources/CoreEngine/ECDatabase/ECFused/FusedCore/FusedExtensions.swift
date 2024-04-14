//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/11/24.
//

import Foundation
import FirebaseDatabase
import RealmSwift
import Realm


public extension DatabasePaths {
    
    var ref: DatabaseReference {
        return Database.database().reference().child(self.rawValue)
    }
    
    static func reference(path: String) -> DatabaseReference? {
        return Database.database().reference().child(path)
    }
   
    static func getReference(path: DatabasePaths) -> DatabaseReference? {
        switch path {
            case .users:
                return self.users.ref
            case .rooms:
                return self.rooms.ref
            case .chat:
                return self.chat.ref
            case .userInRoom:
                return self.userInRoom.ref
            case .sessionPlan:
                return self.sessionPlan.ref
            case .activityPlan:
                return self.activityPlan.ref
            case .organizations:
                return self.organizations.ref
            case .teams:
                return self.teams.ref
            case .userToSession:
                return self.userToSession.ref
            case .players:
                return self.players.ref
            case .notes:
                return self.notes.ref
            case .events:
                return self.events.ref
            case .managedViews:
                return self.managedViews.ref
            case .userToActivity:
                return self.userToActivity.ref
            case .friends:
                return self.friends.ref
            case .friendRequests:
                return self.friendRequests.ref
            default:
                return nil
        }
    }

    static func getQueue(path: String, queueType: FusedQueueType) -> [Object]? {
        let realm = newRealm()
        guard let q = realm.findByField(FusedDatabaseQueue.self, value: queueType.rawValue) else { return nil }
        
        switch path {
            case DatabasePaths.users.rawValue:
                return q.userQueue.toArray()
            case DatabasePaths.rooms.rawValue:
                return q.roomQueue.toArray()
            case DatabasePaths.managedViews.rawValue:
                return q.managedViewsQueue.toArray()
            case DatabasePaths.userInRoom.rawValue:
                return q.userInRoomQueue.toArray()
            case DatabasePaths.players.rawValue:
                return q.playersQueue.toArray()
            case DatabasePaths.organizations.rawValue:
                return q.organizationsQueue.toArray()
            case DatabasePaths.teams.rawValue:
                return q.teamsQueue.toArray()
            case DatabasePaths.chat.rawValue:
                return q.chatQueue.toArray()
            case DatabasePaths.events.rawValue:
                return q.eventsQueue.toArray()
            case DatabasePaths.sessionPlan.rawValue:
                return q.sessionPlanQueue.toArray()
            case DatabasePaths.activityPlan.rawValue:
                return q.activityPlanQueue.toArray()
            case DatabasePaths.userToSession.rawValue:
                return q.userToSessionQueue.toArray()
            case DatabasePaths.userToActivity.rawValue:
                return q.userToActivityQueue.toArray()
            case DatabasePaths.friends.rawValue:
                return q.friendsQueue.toArray()
            case DatabasePaths.friendRequests.rawValue:
                return q.friendRequestsQueue.toArray()
            default:
                return nil
        }
    }

    
  
    static func clearQueue(path: String, queueType: FusedQueueType) {
        let realm = newRealm()
        guard let q = realm.findByField(FusedDatabaseQueue.self, value: queueType.rawValue) else { return }
        switch path {
            case DatabasePaths.users.rawValue:
                realm.safeWrite { _ in q.userQueue.removeAll() }
            case DatabasePaths.rooms.rawValue:
                realm.safeWrite { _ in q.roomQueue.removeAll() }
            case DatabasePaths.managedViews.rawValue:
                realm.safeWrite { _ in q.managedViewsQueue.removeAll() }
            case DatabasePaths.userInRoom.rawValue:
                realm.safeWrite { _ in q.userInRoomQueue.removeAll() }
            case DatabasePaths.players.rawValue:
                realm.safeWrite { _ in q.playersQueue.removeAll() }
            case DatabasePaths.organizations.rawValue:
                realm.safeWrite { _ in q.organizationsQueue.removeAll() }
            case DatabasePaths.teams.rawValue:
                realm.safeWrite { _ in q.teamsQueue.removeAll() }
            case DatabasePaths.chat.rawValue:
                realm.safeWrite { _ in q.chatQueue.removeAll() }
            case DatabasePaths.events.rawValue:
                realm.safeWrite { _ in q.eventsQueue.removeAll() }
            case DatabasePaths.sessionPlan.rawValue:
                realm.safeWrite { _ in q.sessionPlanQueue.removeAll() }
            case DatabasePaths.activityPlan.rawValue:
                realm.safeWrite { _ in q.activityPlanQueue.removeAll() }
            case DatabasePaths.userToSession.rawValue:
                realm.safeWrite { _ in q.userToSessionQueue.removeAll() }
            case DatabasePaths.userToActivity.rawValue:
                realm.safeWrite { _ in q.userToActivityQueue.removeAll() }
            case DatabasePaths.friends.rawValue:
                realm.safeWrite { _ in q.friendsQueue.removeAll() }
            case DatabasePaths.friendRequests.rawValue:
                realm.safeWrite { _ in q.friendRequestsQueue.removeAll() }
            default:
                break
        }
    }

   
}
