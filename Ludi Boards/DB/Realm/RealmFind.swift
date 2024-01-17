//
//  RealmFind.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/13/23.
//

import Foundation
import RealmSwift

extension Realm {
    func findByField<T: Object>(_ type: T.Type, field: String = "id", value: String?) -> T? {
        guard let value = value else { return nil }
        return objects(type).filter("\(field) == %@", value).first
    }
    
    func findAllByField<T: Object>(_ type: T.Type, field: String, value: Any) -> Results<T>? {
        return self.objects(type).filter("%K == %@", field, value)
    }
    
    func findAllNotByField<T: Object>(_ type: T.Type, field: String, value: Any) -> Results<T>? {
        return self.objects(type).filter("%K != %@", field, value)
    }
    
    func isLiveSessionPlan(sessionId: String) -> Bool {
        if let plan = self.findByField(SessionPlan.self, value: sessionId) {
            return plan.isLive
        }
        return false
    }
    
    func isLiveSessionPlan(activityId: String) -> Bool {
        var liveResult = false
        self.getSessionPlanByActivityId(activityId: activityId) { result in
            liveResult = result.isLive
        }
        return liveResult
    }
    
    func getSessionPlanByActivityId(activityId: String, onResult: (SessionPlan) -> Void) {
        if let act = self.findByField(ActivityPlan.self, value: activityId) {
            if let sess = self.findByField(SessionPlan.self, value: act.sessionId) {
                onResult(sess)
            }
        }
    }

}

func isLiveSessionPlan(sessionId: String) -> Bool {
    if let plan = newRealm().findByField(SessionPlan.self, value: sessionId) {
        return plan.isLive
    }
    return false
}

func isLiveSessionPlan(activityId: String) -> Bool {
    var liveResult = false
    newRealm().getSessionPlanByActivityId(activityId: activityId) { result in
        liveResult = result.isLive
    }
    return liveResult
}

extension Results {
    func toArray() -> [Element] {
        return Array(self)
    }
}
