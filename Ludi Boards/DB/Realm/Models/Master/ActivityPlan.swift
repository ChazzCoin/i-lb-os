//
//  ActivityPlan.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import RealmSwift

class ActivityPlan: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var dateCreated: String = getTimeStamp()
    @Persisted var dateUpdated: String = getTimeStamp()
    @Persisted var dateOf: String = getTimeStamp()

    @Persisted var title: String = ""
    @Persisted var subTitle: String = ""
    @Persisted var objectiveDetails: String = ""
    @Persisted var activityDetails: String = ""
    @Persisted var timePeriod: String = ""
    @Persisted var duration: String = ""
    @Persisted var ageLevel: String = ""
    @Persisted var category: String = ""
    @Persisted var tags: List<String> = List<String>()
    
    @Persisted var equipment: String = ""
    @Persisted var spaceDimensions: String = ""
    
    @Persisted var principles: String = ""
    @Persisted var keyQualities: String = ""
    @Persisted var coachingPoints: String = ""
    @Persisted var guidedAnswers: String = ""
    @Persisted var answers: String = ""
    @Persisted var numOfPlayers: Int = 0
    @Persisted var numOfGroups: Int = 0
    @Persisted var numPerGroup: Int = 0
    
    @Persisted var sessionId: String = ""
    @Persisted var orgId: String = ""
    @Persisted var teamId: String = ""
    @Persisted var ownerId: String = ""
    @Persisted var createdBy: String = ""
    @Persisted var isHost: Bool = false
    @Persisted var isOpen: Bool = false
    @Persisted var isLocal: Bool = true
    @Persisted var isDeleted: Bool = false
    @Persisted var orderIndex: Int = 0
    
    @Persisted var width: Int = 3000
    @Persisted var height: Int = 4000
    @Persisted var backgroundRed: Double = 0.2
    @Persisted var backgroundGreen: Double = 0.78
    @Persisted var backgroundBlue: Double = 0.34
    @Persisted var backgroundAlpha: Double = 0.75
    @Persisted var backgroundLineStroke: Double = 10
    @Persisted var backgroundRotation: Double = -90
    @Persisted var backgroundLineRed: Double = 255.0
    @Persisted var backgroundLineGreen: Double = 255.0
    @Persisted var backgroundLineBlue: Double = 255.0
    @Persisted var backgroundLineAlpha: Double = 1.0
    @Persisted var backgroundView: String = "Sol"
    
}


func newActivityPlan() -> ActivityPlan {
    let temp = ActivityPlan()
    temp.id = "new"
    return temp
}
