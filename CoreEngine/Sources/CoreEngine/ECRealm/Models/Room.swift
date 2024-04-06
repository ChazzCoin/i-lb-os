//
//  Room.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/13/24.
//

import Foundation
import RealmSwift

public class Room: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var dateCreated: String = getTimeStamp()
    @Persisted public var dateUpdated: String = getTimeStamp()
    @Persisted public var roomId: String = ""
    @Persisted public var userId: String = ""
    @Persisted public var userName: String = ""
    @Persisted public var userImg: String = ""
    @Persisted public var status: String = ""

}
