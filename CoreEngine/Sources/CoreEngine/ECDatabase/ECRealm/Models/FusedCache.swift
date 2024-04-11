//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/10/24.
//

import Foundation
import RealmSwift


public class FusedDatabaseQueue: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = FusedQueueType.create.rawValue
    @Persisted public var userQueue: List<CoreUser> = List()
    @Persisted public var managedViewsQueue: List<ManagedView> = List()
    @Persisted public var roomQueue: List<Room> = List()
    @Persisted public var userInRoomQueue: List<UserInRoom> = List()
}
