//
//  SessionPlan.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import RealmSwift
import FirebaseDatabase

class SessionPlan: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var dateCreated: String = getTimeStamp()
    @Persisted var dateUpdated: String = getTimeStamp()
    @Persisted var dateOf: String = getTimeStamp()
    @Persisted var timePeriod: String = "24/7"
    @Persisted var duration: String = "24/7"
    @Persisted var ageLevel: String = "Any Age?"
    @Persisted var title: String = "Session: \(TimeProvider.getMonthDayYearTime())"
    @Persisted var subTitle: String = "A Basic Session"
    @Persisted var objectiveDetails: String = "To show off SOL!"
    @Persisted var sessionDetails: String = "Add some details here!"
    @Persisted var ownerId: String = "temp"
    @Persisted var isHost: Bool = false
    @Persisted var isOpen: Bool = false
    @Persisted var isLive: Bool = false
    
}

