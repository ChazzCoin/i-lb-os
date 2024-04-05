//
//  Room.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/13/24.
//

import Foundation
import RealmSwift

class Room: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var dateCreated: String = getTimeStamp()
    @Persisted var dateUpdated: String = getTimeStamp()
    @Persisted var roomId: String = ""
    @Persisted var userId: String = ""
    @Persisted var userName: String = ""
    @Persisted var userImg: String = ""
    @Persisted var status: String = ""

}
