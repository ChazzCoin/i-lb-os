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
    
    @Persisted var title: String = "Session: \(TimeProvider.getMonthDayYearTime())"
    @Persisted var subTitle: String = "A Basic Session"
    @Persisted var objectiveDetails: String = "To show off SOL!"
    @Persisted var sessionDetails: String = "Add some details here!"
    @Persisted var timePeriod: String = ""
    @Persisted var duration: String = ""
    @Persisted var ageLevel: String = ""
    @Persisted var intensity: String = ""
    @Persisted var keyQualities: String = ""
    @Persisted var numOfPlayers: Int = 0
    @Persisted var principles: String = ""
    @Persisted var goal: String = ""
    @Persisted var stages: String = ""
    @Persisted var category: String = ""
    @Persisted var tags: List<String> = List<String>()
    
    @Persisted var ownerId: String = ""
    @Persisted var orgId: String = ""
    @Persisted var teamId: String = ""
    
    @Persisted var isHost: Bool = false
    @Persisted var isOpen: Bool = false
    @Persisted var isLive: Bool = false
    @Persisted var isDeleted: Bool = false
}

