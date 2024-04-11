//
//  Room.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/13/24.
//

import Foundation
import RealmSwift

public class UserInRoom: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var roomId: String = "null"
    @Persisted public var guestId: String = "null"
    @Persisted public var role: String = UserRole.temp.name
    @Persisted public var auth: String = UserAuth.visitor.name
    @Persisted public var status: String = RoomStatus.out_of_room.name
}

public class Room: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var dateCreated: String = getTimeStamp()
    @Persisted public var dateUpdated: String = getTimeStamp()
    
    @Persisted public var ownerId: String = ""
    @Persisted public var ownerName: String = ""
    @Persisted public var ownerImg: String = ""
    @Persisted public var status: String = ""
    
    @Persisted public var title: String = ""
    @Persisted public var subTitle: String = ""
    @Persisted public var roomDetails: String = ""
    @Persisted public var category: String = ""
    @Persisted public var tags: List<String> = List<String>()
    
    @Persisted public var isOpen: Bool = false
    @Persisted public var isLocal: Bool = true
    @Persisted public var isDeleted: Bool = false
}
