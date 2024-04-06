//
//  SessionPlan.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import RealmSwift
import FirebaseDatabase

public class SessionPlan: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var dateCreated: String = getTimeStamp()
    @Persisted public var dateUpdated: String = getTimeStamp()
    @Persisted public var dateOf: String = getTimeStamp()
    
    @Persisted public var title: String = "Session: \(TimeProvider.getMonthDayYearTime())"
    @Persisted public var subTitle: String = ""
    @Persisted public var objectiveDetails: String = ""
    @Persisted public var sessionDetails: String = ""
    @Persisted public var timePeriod: String = ""
    @Persisted public var duration: String = ""
    @Persisted public var ageLevel: String = ""
    @Persisted public var intensity: String = ""
    @Persisted public var keyQualities: String = ""
    @Persisted public var numOfPlayers: Int = 0
    @Persisted public var principles: String = ""
    @Persisted public var goal: String = ""
    @Persisted public var stages: String = ""
    @Persisted public var category: String = ""
    @Persisted public var tags: List<String> = List<String>()
    
    @Persisted public var ownerId: String = ""
    @Persisted public var orgId: String = ""
    @Persisted public var teamId: String = ""
    @Persisted public var createdBy: String = ""
    
    @Persisted public var isHost: Bool = false
    @Persisted public var isOpen: Bool = false
    @Persisted public var isLive: Bool = false
    @Persisted public var isDeleted: Bool = false
}

