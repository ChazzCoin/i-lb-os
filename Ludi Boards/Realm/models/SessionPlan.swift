//
//  SessionPlan.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import RealmSwift

@objcMembers class SessionPlan: Object, Identifiable {
    dynamic var id: String = "SOL"
    dynamic var dateCreated: String = getTimeStamp()
    dynamic var dateUpdated: String = getTimeStamp()
    dynamic var dateOf: String = getTimeStamp()
    dynamic var timePeriod: String = "24/7"
    dynamic var duration: String = "24/7"
    dynamic var ageLevel: String = "Any Age?"
    dynamic var title: String = "SOL Demo Plan"
    dynamic var subTitle: String = "A Basic Session"
    dynamic var objectiveDetails: String = "To show off SOL!"
    dynamic var sessionDetails: String = "Add some details here!"
    dynamic var isHost: Bool = true
    dynamic var isOpen: Bool = false
    
    override static func primaryKey() -> String {
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

