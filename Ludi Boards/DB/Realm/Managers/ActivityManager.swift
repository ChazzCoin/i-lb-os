//
//  ActivityManager.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/3/24.
//

import Foundation
import RealmSwift
import CoreEngine

class ActivityUserManager {
    private var realm: Realm = newRealm()

    // Adds a User to an ActivityPlan by IDs
    func addUserToActivity(userId: String, activityId: String, completion: @escaping (Error?) -> Void) {
        let user = realm.object(ofType: CoreUser.self, forPrimaryKey: userId)
        let activityPlan = realm.object(ofType: ActivityPlan.self, forPrimaryKey: activityId)
        
        guard let user = user, let activityPlan = activityPlan else {
            completion(NSError(domain: "ActivityUserManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "User or ActivityPlan not found"]))
            return
        }
        
        let userToActivity = UserToActivity()
        userToActivity.userId = user.userId
        userToActivity.userName = user.name
        userToActivity.activityId = activityPlan.id
        userToActivity.activityName = activityPlan.title
        
        userToActivity.role = UserRole.temp.name // Example role, adjust as needed
        userToActivity.auth = UserAuth.visitor.name // Example auth, adjust as needed
        userToActivity.status = ShareStatus.active.name // Example status, adjust as needed
        
        realm.safeWrite { r in
            r.add(userToActivity)
            completion(nil)
        }
    }
    
    // Removes a User from an ActivityPlan by IDs
    func removeUserFromActivity(userId: String, activityId: String, completion: @escaping (Error?) -> Void) {
        let result = realm.objects(UserToActivity.self).filter("userId == %@ AND activityId == %@", userId, activityId)
        
        realm.safeWrite { r in
            r.delete(result)
            completion(nil)
        }
    }
    
    // Finds all Users part of an ActivityPlan by ID
    func getAllUsersInActivity(activityId: String) -> Results<CoreUser> {
        let userIds = realm
            .objects(UserToActivity.self)
            .filter("activityId == %@", activityId)
            .map { $0.userId }
        return realm.objects(CoreUser.self).filter("id IN %@", userIds)
    }
}
