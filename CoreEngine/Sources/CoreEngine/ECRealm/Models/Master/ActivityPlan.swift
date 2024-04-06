//
//  ActivityPlan.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import RealmSwift

public class ActivityPlan: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var dateCreated: String = getTimeStamp()
    @Persisted public var dateUpdated: String = getTimeStamp()
    @Persisted public var dateOf: String = getTimeStamp()

    @Persisted public var title: String = ""
    @Persisted public var subTitle: String = ""
    @Persisted public var objectiveDetails: String = ""
    @Persisted public var activityDetails: String = ""
    @Persisted public var timePeriod: String = ""
    @Persisted public var duration: String = ""
    @Persisted public var ageLevel: String = ""
    @Persisted public var category: String = ""
    @Persisted public var tags: List<String> = List<String>()
    
    @Persisted public var equipment: String = ""
    @Persisted public var spaceDimensions: String = ""
    
    @Persisted public var principles: String = ""
    @Persisted public var keyQualities: String = ""
    @Persisted public var coachingPoints: String = ""
    @Persisted public var guidedAnswers: String = ""
    @Persisted public var answers: String = ""
    @Persisted public var numOfPlayers: Int = 0
    @Persisted public var numOfGroups: Int = 0
    @Persisted public var numPerGroup: Int = 0
    
    @Persisted public var sessionId: String = ""
    @Persisted public var orgId: String = ""
    @Persisted public var teamId: String = ""
    @Persisted public var ownerId: String = ""
    @Persisted public var createdBy: String = ""
    @Persisted public var isHost: Bool = false
    @Persisted public var isOpen: Bool = false
    @Persisted public var isLocal: Bool = true
    @Persisted public var isDeleted: Bool = false
    @Persisted public var orderIndex: Int = 0
    
    @Persisted public var width: Int = 3000
    @Persisted public var height: Int = 4000
    @Persisted public var backgroundRed: Double = 0.2
    @Persisted public var backgroundGreen: Double = 0.78
    @Persisted public var backgroundBlue: Double = 0.34
    @Persisted public var backgroundAlpha: Double = 0.75
    @Persisted public var backgroundLineStroke: Double = 10
    @Persisted public var backgroundRotation: Double = -90
    @Persisted public var backgroundLineRed: Double = 255.0
    @Persisted public var backgroundLineGreen: Double = 255.0
    @Persisted public var backgroundLineBlue: Double = 255.0
    @Persisted public var backgroundLineAlpha: Double = 1.0
    @Persisted public var backgroundView: String = "Sol"
    
    public let managedViews = LinkingObjects(fromType: ManagedView.self, property: "activityId")
}


public func newActivityPlan() -> ActivityPlan {
    let temp = ActivityPlan()
    temp.id = "new"
    return temp
}
