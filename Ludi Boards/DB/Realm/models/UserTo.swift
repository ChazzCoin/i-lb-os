//
//  UserToBoard.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import RealmSwift

class UserToSession: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var sessionId: String = ""
    @Persisted var sessionName: String = ""
    @Persisted var userId: String = ""
    @Persisted var userName: String = ""
    @Persisted var role: String = UserRole.temp.name
    @Persisted var auth: String = UserAuth.visitor.name
    @Persisted var status: String = ShareStatus.active.name
}

class UserToOrganization: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var organizationId: String = "null"
    @Persisted var organizationName: String = "null"
    @Persisted var userId: String = "null"
    @Persisted var userName: String = "null"
    @Persisted var role: String = UserRole.temp.name
    @Persisted var auth: String = UserAuth.visitor.name
    @Persisted var status: String = ShareStatus.active.name
}

class UserToTeam: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var teamId: String = "null"
    @Persisted var teamName: String = "null"
    @Persisted var userId: String = "null"
    @Persisted var userName: String = "null"
    @Persisted var role: String = UserRole.temp.name
    @Persisted var auth: String = UserAuth.visitor.name
    @Persisted var status: String = ShareStatus.active.name
}

func firePostShareSession(sessionId: String, guestId: String, guestUserName:String) {
    // get current user id
    // get current user name
//    var share = UserToSession()
//    share.hostId = ""
//    share.hostUserName = ""
//    share.guestId = guestId
//    share.guestUserName = guestUserName
//    share.sessionId = sessionId
//    share.status = "edit" // view, removed
//    
//    firebaseDatabase { db in
//        db
//            .child(DatabasePaths.userToSession.rawValue)
//            .child(share.id)
//            .setValue(share.toDict())
//    }
}



