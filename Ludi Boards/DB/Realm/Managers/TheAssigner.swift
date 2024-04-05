//
//  TheAssigner.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/3/24.
//

import Foundation
import RealmSwift

class Assign {
//    private var realm: Realm = newRealm()

    // MARK: - Assignments

    // Assign Team to Organization
    static func teamToOrganization(teamId: String, orgId: String, completion: @escaping (Error?) -> Void) {
        updateOrgId(for: Team.self, objectId: teamId, newOrgId: orgId, completion: completion)
    }

    // Assign SessionPlan to Organization
    static func sessionPlanToOrganization(sessionPlanId: String, orgId: String, completion: @escaping (Error?) -> Void) {
        updateOrgId(for: SessionPlan.self, objectId: sessionPlanId, newOrgId: orgId, completion: completion)
    }

    // Assign ActivityPlan to Organization
    static func activityPlanToOrganization(activityPlanId: String, orgId: String, completion: @escaping (Error?) -> Void) {
        updateOrgId(for: ActivityPlan.self, objectId: activityPlanId, newOrgId: orgId, completion: completion)
    }

    // Assign ActivityPlan to SessionPlan
    static func activityPlanToSessionPlan(activityPlanId: String, sessionPlanId: String, completion: @escaping (Error?) -> Void) {
        updateField(for: ActivityPlan.self, objectId: activityPlanId, fieldName: "sessionId", newValue: sessionPlanId, completion: completion)
    }

    // Assign SessionPlan to Team
    static func sessionPlanToTeam(sessionPlanId: String, teamId: String, completion: @escaping (Error?) -> Void) {
        updateField(for: SessionPlan.self, objectId: sessionPlanId, fieldName: "teamId", newValue: teamId, completion: completion)
    }

    // Assign ActivityPlan to Team
    static func activityPlanToTeam(activityPlanId: String, teamId: String, completion: @escaping (Error?) -> Void) {
        updateField(for: ActivityPlan.self, objectId: activityPlanId, fieldName: "teamId", newValue: teamId, completion: completion)
    }

    // Assign Event to Organization
    static func eventToOrganization(eventId: String, orgId: String, completion: @escaping (Error?) -> Void) {
        updateOrgId(for: Event.self, objectId: eventId, newOrgId: orgId, completion: completion)
    }

    // Assign Event to Team
    static func eventToTeam(eventId: String, teamId: String, completion: @escaping (Error?) -> Void) {
        updateField(for: Event.self, objectId: eventId, fieldName: "teamId", newValue: teamId, completion: completion)
    }

    // Assign Event to SessionPlan
    static func eventToSessionPlan(eventId: String, sessionPlanId: String, completion: @escaping (Error?) -> Void) {
        updateField(for: Event.self, objectId: eventId, fieldName: "sessionId", newValue: sessionPlanId, completion: completion)
    }

    // MARK: - Utility Methods

    static func updateOrgId<T: Object>(for objectType: T.Type, objectId: String, newOrgId: String, completion: @escaping (Error?) -> Void) where T: ObjectKeyIdentifiable {
        let realm = newRealm()
        guard let object = realm.object(ofType: objectType, forPrimaryKey: objectId) else {
            completion(NSError(domain: "Assigners", code: 404, userInfo: [NSLocalizedDescriptionKey: "\(objectType) not found"]))
            return
        }
        
        realm.safeWrite { r in
            object.setValue(newOrgId, forKey: "orgId")
            completion(nil)
        }
//        realm.invalidate()
    }

    
}
