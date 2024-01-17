//
//  UserToBoard.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import RealmSwift

class UserToSession: Object, ObjectKeyIdentifiable {
    @Persisted var id: String = UUID().uuidString
    @Persisted var sessionId: String = "null"
    @Persisted var hostId: String = "null"
    @Persisted var hostUserName: String = "null"
    @Persisted var guestId: String = "null"
    @Persisted var guestUserName: String = "null"
    @Persisted var status: String = "view"
    @Persisted var isConnected: Bool = false
    @Persisted var authLevel: String = "guest"

    override static func primaryKey() -> String? {
        return "id"
    }
}

class Share: Object, Identifiable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var sharedId: String = "null"
    @objc dynamic var hostId: String = "null"
    @objc dynamic var hostUserName: String = "null"
    @objc dynamic var guestId: String = "null"
    @objc dynamic var guestUserName: String = "null"
    @objc dynamic var status: String = "pending"
    @objc dynamic var isConnected: Bool = false
    @objc dynamic var authLevel: String = "guest"

    override static func primaryKey() -> String? {
        return "id"
    }
}

//

func firePostShareSession(sessionId: String, guestId: String, guestUserName:String) {
    // get current user id
    // get current user name
    var share = UserToSession()
    share.hostId = ""
    share.hostUserName = ""
    share.guestId = guestId
    share.guestUserName = guestUserName
    share.sessionId = sessionId
    share.status = "edit" // view, removed
    
    firebaseDatabase { db in
        db
            .child(DatabasePaths.userToSession.rawValue)
            .child(share.id)
            .setValue(share.toDict())
    }
}



