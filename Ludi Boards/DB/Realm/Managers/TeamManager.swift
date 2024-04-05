//
//  TeamManager.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/3/24.
//

import Foundation
import RealmSwift

class TeamManager {
    private var realm: Realm = newRealm()

    // Adds a User to a Team by IDs
    func addUserToTeam(userId: String, teamId: String, completion: @escaping (Error?) -> Void) {
        let user = realm.object(ofType: User.self, forPrimaryKey: userId)
        let team = realm.object(ofType: Team.self, forPrimaryKey: teamId)
        
        guard let user = user, let team = team else {
            completion(NSError(domain: "TeamUserManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "User or Team not found"]))
            return
        }
        
        let userToTeam = UserToTeam()
        userToTeam.userId = user.userId
        userToTeam.userName = user.name
        userToTeam.teamId = team.id
        userToTeam.teamName = team.name
        
        // Assuming UserRole, UserAuth, and ShareStatus are enums or similar constructs that define various roles, auth levels, and statuses.
        userToTeam.role = UserRole.member.name // Example role, adjust as necessary
        userToTeam.auth = UserAuth.viewer.name // Example auth, adjust as necessary
        userToTeam.status = ShareStatus.active.name // Example status, adjust as necessary
        
        realm.safeWrite { r in
            r.add(userToTeam)
            completion(nil)
        }
    }
    
    // Removes a User from a Team by IDs
    func removeUserFromTeam(userId: String, teamId: String, completion: @escaping (Error?) -> Void) {
        let result = realm.objects(UserToTeam.self).filter("userId == %@ AND teamId == %@", userId, teamId)
        
        realm.safeWrite { r in
            r.delete(result)
            completion(nil)
        }
    }
    
    // Users
    func getAllUsersInTeam(teamId: String) -> Results<User> {
        let userIds = realm
            .objects(UserToTeam.self)
            .filter("teamId == %@", teamId)
            .map { $0.userId }
        return realm.objects(User.self).filter("id IN %@", userIds)
    }
    // Sessions
    func getSessionPlansForTeam(teamId: String) -> Results<SessionPlan> {
        return realm.objects(SessionPlan.self).filter("teamId == %@", teamId)
    }
    // Activities
    func getActivityPlansForTeam(teamId: String) -> Results<ActivityPlan> {
        return realm.objects(ActivityPlan.self).filter("teamId == %@", teamId)
    }
    // Events
    func getEventsForTeam(teamId: String) -> Results<Event> {
        return realm.objects(Event.self).filter("teamId == %@", teamId)
    }
    
}
