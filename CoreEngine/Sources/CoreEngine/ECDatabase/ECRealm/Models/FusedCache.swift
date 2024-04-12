//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/10/24.
//

import Foundation
import RealmSwift


extension List where Element: Object {
    func safeAddReplace(_ item: Element) {
        let itemId = item.getId() // Assuming getId() is available and returns a unique identifier.
        
        if let index = self.enumerated().first(where: { $1.getId() == itemId })?.offset {
            // If an item with the same ID exists, remove it. Insert the new item at the same index.
            self.remove(at: index)
            self.insert(item, at: index)
        } else {
            // If no item with the same ID exists, just append the new item.
            self.append(item)
        }
    }
}


public extension Array where Element == Object {
    
    mutating func safeAddReplace(item: Object) {
        for ind in self.indices {
            if self[ind].getId() == item.getId() {
                //todo: check dateUpdated
                self.remove(at: ind)
                self.append(item)
                return
            }
        }
        self.append(item)
    }
    
}

public class FusedDatabaseQueue: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = FusedQueueType.update.rawValue
    @Persisted public var userQueue: List<CoreUser> = List()
    @Persisted public var managedViewsQueue: List<ManagedView> = List()
    @Persisted public var roomQueue: List<Room> = List()
    @Persisted public var userInRoomQueue: List<UserInRoom> = List()
    @Persisted public var playersQueue: List<PlayerRef> = List()
    @Persisted public var organizationsQueue: List<Organization> = List()
    @Persisted public var teamsQueue: List<Team> = List()
    @Persisted public var chatQueue: List<Chat> = List()
    @Persisted public var eventsQueue: List<CoreEvent> = List()
    @Persisted public var sessionPlanQueue: List<SessionPlan> = List()
    @Persisted public var activityPlanQueue: List<ActivityPlan> = List()
    @Persisted public var userToSessionQueue: List<UserToSession> = List()
    @Persisted public var userToActivityQueue: List<UserToActivity> = List()
    
    
}
