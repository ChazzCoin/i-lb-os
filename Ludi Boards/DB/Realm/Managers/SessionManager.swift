//
//  SessionManager.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/3/24.
//

import Foundation
import RealmSwift
import CoreEngine

class SessionUserManager {
    private var realm: Realm = newRealm()

    // Adds a User to a SessionPlan by IDs
    func addUserToSession(userId: String, sessionId: String, completion: @escaping (Error?) -> Void) {
        let user = realm.object(ofType: CoreUser.self, forPrimaryKey: userId)
        let sessionPlan = realm.object(ofType: SessionPlan.self, forPrimaryKey: sessionId)
        
        guard let user = user, let sessionPlan = sessionPlan else {
            completion(NSError(domain: "SessionUserManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "User or SessionPlan not found"]))
            return
        }
        
        let userToSession = UserToSession()
        userToSession.userId = user.userId
        userToSession.userName = user.name
        userToSession.sessionId = sessionPlan.id
        userToSession.sessionName = sessionPlan.title
        
        userToSession.role = UserRole.temp.name // Example role, adjust as needed
        userToSession.auth = UserAuth.visitor.name // Example auth, adjust as needed
        userToSession.status = ShareStatus.active.name // Example status, adjust as needed
        
        realm.safeWrite { r in
            r.add(userToSession)
            completion(nil)
        }
    }
    
    // Removes a User from a SessionPlan by IDs
    func removeUserFromSession(userId: String, sessionId: String, completion: @escaping (Error?) -> Void) {
        let result = realm.objects(UserToSession.self).filter("userId == %@ AND sessionId == %@", userId, sessionId)
        
        realm.safeWrite { r in
            r.delete(result)
            completion(nil)
        }
    }
    
    // Users
    func getAllUsersInSession(sessionId: String) -> Results<CoreUser> {
        let userIds = realm
            .objects(UserToSession.self)
            .filter("sessionId == %@", sessionId)
            .map { $0.userId }
        return realm.objects(CoreUser.self).filter("id IN %@", userIds)
    }
    // Activities
    func getActivityPlansForSessionPlan(sessionId: String) -> Results<ActivityPlan> {
        return realm.objects(ActivityPlan.self).filter("sessionId == %@", sessionId)
    }
    // Events
    func getEventsForSessionPlan(sessionId: String) -> Results<CoreEvent> {
        return realm.objects(CoreEvent.self).filter("sessionId == %@", sessionId)
    }
    
}
