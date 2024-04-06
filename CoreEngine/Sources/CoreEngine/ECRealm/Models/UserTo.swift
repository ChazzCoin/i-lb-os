//
//  UserToBoard.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import RealmSwift

public class PlayerToRoster: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var playerId: String = ""
    @Persisted public var teamId: String = ""
    @Persisted public var year: String = ""
    @Persisted public var role: String = UserRole.player.name
    @Persisted public var auth: String = UserAuth.viewer.name
    @Persisted public var status: String = RosterStatus.active.name
    @Persisted public var isArchive: Bool = false
}

public class UserToSession: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var sessionId: String = ""
    @Persisted public var sessionName: String = ""
    @Persisted public var userId: String = ""
    @Persisted public var userName: String = ""
    @Persisted public var role: String = UserRole.temp.name
    @Persisted public var auth: String = UserAuth.visitor.name
    @Persisted public var status: String = ShareStatus.active.name
}

public class UserToActivity: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var activityId: String = ""
    @Persisted public var activityName: String = ""
    @Persisted public var userId: String = ""
    @Persisted public var userName: String = ""
    @Persisted public var role: String = UserRole.temp.name
    @Persisted public var auth: String = UserAuth.visitor.name
    @Persisted public var status: String = ShareStatus.active.name
}

public class UserToOrganization: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var organizationId: String = "null"
    @Persisted public var organizationName: String = "null"
    @Persisted public var userId: String = "null"
    @Persisted public var userName: String = "null"
    @Persisted public var role: String = UserRole.temp.name
    @Persisted public var auth: String = UserAuth.visitor.name
    @Persisted public var status: String = ShareStatus.active.name
}

public class UserToTeam: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var teamId: String = "null"
    @Persisted public var teamName: String = "null"
    @Persisted public var userId: String = "null"
    @Persisted public var userName: String = "null"
    @Persisted public var role: String = UserRole.temp.name
    @Persisted public var auth: String = UserAuth.visitor.name
    @Persisted public var status: String = ShareStatus.active.name
}


