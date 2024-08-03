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

public class PlayerRefToTeam: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var teamId: String = "null"
    @Persisted public var teamName: String = "null"
    @Persisted public var userId: String = "null"
    @Persisted public var userName: String = "null"
    @Persisted public var role: String = UserRole.temp.name
    @Persisted public var auth: String = UserAuth.visitor.name
    @Persisted public var status: String = ShareStatus.active.name
}


public class TeamToOrganization: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var organizationId: String = "null"
    @Persisted public var organizationName: String = "null"
    @Persisted public var teamId: String = "null"
    @Persisted public var teamName: String = "null"
    @Persisted public var role: String = UserRole.temp.name
    @Persisted public var auth: String = UserAuth.visitor.name
    @Persisted public var status: String = ShareStatus.active.name
}


// For Teams connecting to PlayerRefs
public class PlayerTeamManager {
    public var realm: Realm = newRealm()

    public init() {}

    // 1. Attach/Save a new team/player connection
    public func attachPlayerToTeam(playerRefId: String, teamId: String, teamName: String) {
        realm.safeWrite { r in
            let connection = PlayerRefToTeam()
            connection.teamId = teamId
            connection.teamName = teamName
            connection.userId = playerRefId
            // You can add more fields here if needed
            r.create(PlayerRefToTeam.self, value: connection, update: .all)
        }
        print("Successfully attached player \(playerRefId) to team \(teamName) (ID: \(teamId)).")
    }

    // 2. Delete/Detach a player/team connection
    public func detachPlayerFromTeam(playerRefId: String, teamId: String) {
        if let connection = realm.objects(PlayerRefToTeam.self).filter("userId == %@ AND teamId == %@", playerRefId, teamId).first {
            realm.safeWrite { r in
                r.delete(connection)
            }
            print("Successfully detached player \(playerRefId) from team \(teamId).")
        } else {
            print("Connection not found for player \(playerRefId) and team \(teamId).")
        }
    }

    // 3. Find/Get connections based on player id
    public func findTeamsByPlayerId(playerRefId: String) -> Results<PlayerRefToTeam> {
        return realm.objects(PlayerRefToTeam.self).filter("userId == %@", playerRefId)
    }

    // 4. Find/Get connections based on team id
    public func findPlayersByTeamId(teamId: String) -> Results<PlayerRefToTeam> {
        return realm.objects(PlayerRefToTeam.self).filter("teamId == %@", teamId)
    }

    // 5. Update a player's role or status within a team
    public func updatePlayerRoleInTeam(playerRefId: String, teamId: String, newRole: String, newStatus: String) {
        if let connection = realm.objects(PlayerRefToTeam.self).filter("userId == %@ AND teamId == %@", playerRefId, teamId).first {
            realm.safeWrite { r in
                connection.role = newRole
                connection.status = newStatus
            }
            print("Successfully updated player \(playerRefId) in team \(teamId) with new role \(newRole) and status \(newStatus).")
        } else {
            print("Connection not found for player \(playerRefId) and team \(teamId).")
        }
    }
}
