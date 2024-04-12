//
//  OrganizationManager.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/3/24.
//

import Foundation
import RealmSwift
import CoreEngine

class OrganizationManager {
    let realm: Realm
    
    init(realm: Realm = newRealm()) {
        self.realm = realm
    }

    // Adds a User to an Organization by IDs
    func addUserToOrganization(userId: String, organizationId: String, completion: @escaping () -> Void) {
        if userId.isEmpty || organizationId.isEmpty { return }
        let userToOrg = UserToOrganization()
        userToOrg.userId = userId
        userToOrg.organizationId = organizationId
        
        userToOrg.role = UserRole.member.name // Example role
        userToOrg.auth = UserAuth.viewer.name // Example auth
        userToOrg.status = ShareStatus.active.name // Example status
        
        realm.safeWrite { r in
            r.create(UserToOrganization.self, value: userToOrg)
            completion()
        }
    }
    
    // Removes a User from an Organization by IDs
    func removeUserFromOrganization(userId: String, organizationId: String, completion: @escaping (Error?) -> Void) {
        let result = realm.objects(UserToOrganization.self).filter("userId == %@ AND organizationId == %@", userId, organizationId)
        
        realm.safeWrite { r in
            r.delete(result)
            completion(nil)
        }
    }
    
    // Users
    func getAllUsersInOrganization(organizationId: String) -> Results<CoreUser> {
        let userIds = realm
            .objects(UserToOrganization.self)
            .filter("organizationId == %@", organizationId)
            .map { $0.userId }
        return realm.objects(CoreUser.self).filter("id IN %@", Array(userIds))
    }
    // Teams
    func getTeamsForOrganization(orgId: String) -> Results<Team> {
        return realm.objects(Team.self).filter("orgId == %@", orgId)
    }
    // Sessions
    func getSessionPlansForOrganization(orgId: String) -> Results<SessionPlan> {
        return realm.objects(SessionPlan.self).filter("orgId == %@", orgId)
    }
    // Activities
    func getActivityPlansForOrganization(orgId: String) -> Results<ActivityPlan> {
        return realm.objects(ActivityPlan.self).filter("orgId == %@", orgId)
    }
    // Events
    func getEventsForOrganization(orgId: String) -> Results<CoreEvent> {
        return realm.objects(CoreEvent.self).filter("orgId == %@", orgId)
    }
}

// Sheet!


