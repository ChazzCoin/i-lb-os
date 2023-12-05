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
    dynamic var title: String = "SOL Activity"
    dynamic var subTitle: String = "Your First SOL Board!"
    dynamic var objectiveDetails: String = ""
    dynamic var activityDetails: String = ""
    
    dynamic var isOpen: Bool = false
    dynamic var orderIndex: Int = 0
    
    dynamic var width: Int = 3000
    dynamic var height: Int = 4000
    dynamic var backgroundRed: Double = 48.0
    dynamic var backgroundGreen: Double = 128.0
    dynamic var backgroundBlue: Double = 20.0
    dynamic var backgroundAlpha: Double = 0.75
    dynamic var backgroundLineStroke: Double = 10
    dynamic var backgroundRotation: Double = -90
    dynamic var backgroundLineRed: Double = 0.0
    dynamic var backgroundLineGreen: Double = 0.0
    dynamic var backgroundLineBlue: Double = 0.0
    dynamic var backgroundLineAlpha: Double = 1.0
    dynamic var backgroundView: String = "SoccerFieldFullView"

    override static func primaryKey() -> String? {
        return "id"
    }
    
    func toDict() -> [String: Any] {
        let properties = self.objectSchema.properties.map { $0.name }
        var dictionary: [String: Any] = [:]
        for property in properties {
            dictionary[property] = self.value(forKey: property)
        }
        return dictionary
    }
}
