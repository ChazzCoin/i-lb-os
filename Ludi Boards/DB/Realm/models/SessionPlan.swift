//
//  SessionPlan.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import RealmSwift

class SessionPlan: Object, ObjectKeyIdentifiable {
    @Persisted var id: String = UUID().uuidString
    @Persisted var dateCreated: String = getTimeStamp()
    @Persisted var dateUpdated: String = getTimeStamp()
    @Persisted var dateOf: String = getTimeStamp()
    @Persisted var timePeriod: String = "24/7"
    @Persisted var duration: String = "24/7"
    @Persisted var ageLevel: String = "Any Age?"
    @Persisted var title: String = "SOL Demo Plan"
    @Persisted var subTitle: String = "A Basic Session"
    @Persisted var objectiveDetails: String = "To show off SOL!"
    @Persisted var sessionDetails: String = "Add some details here!"
    @Persisted var ownerId: String = "temp"
    @Persisted var isHost: Bool = false
    @Persisted var isOpen: Bool = false
    
    override static func primaryKey() -> String {
        return "id"
    }
    
}

