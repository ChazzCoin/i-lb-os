//
//  ActivityPlan.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import RealmSwift

@objcMembers class ActivityPlan: Object, Identifiable {
    dynamic var id: String = UUID().uuidString
    dynamic var sessionId: String = "SOL"
    dynamic var dateCreated: String = getTimeStamp()
    dynamic var dateUpdated: String = getTimeStamp()
    dynamic var dateOf: String = getTimeStamp()
    dynamic var timePeriod: String = ""
    dynamic var duration: String = "24/7"
    dynamic var ageLevel: String = "ALL"
    dynamic var title: String = "SOL Activity Plan"
    dynamic var subTitle: String = "SOL Board!"
    dynamic var objectiveDetails: String = ""
    dynamic var activityDetails: String = ""
    
    dynamic var ownerId: String = ""
    dynamic var isHost: Bool = false
    dynamic var isOpen: Bool = false
    dynamic var orderIndex: Int = 0
    
    dynamic var width: Int = 3000
    dynamic var height: Int = 4000
    dynamic var backgroundRed: Double = 0.2
    dynamic var backgroundGreen: Double = 0.78
    dynamic var backgroundBlue: Double = 0.34
    dynamic var backgroundAlpha: Double = 0.75
    dynamic var backgroundLineStroke: Double = 10
    dynamic var backgroundRotation: Double = -90
    dynamic var backgroundLineRed: Double = 255.0
    dynamic var backgroundLineGreen: Double = 255.0
    dynamic var backgroundLineBlue: Double = 255.0
    dynamic var backgroundLineAlpha: Double = 1.0
    dynamic var backgroundView: String = "SoccerFieldFullView"

    override static func primaryKey() -> String? {
        return "id"
    }
    
}
