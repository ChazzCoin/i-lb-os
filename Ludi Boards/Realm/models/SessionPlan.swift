//
//  SessionPlan.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import RealmSwift

@objcMembers class SessionPlan: Object, Identifiable {
    dynamic var id: String = UUID().uuidString
    dynamic var dateCreated: String? = ""
    dynamic var dateUpdated: String? = ""
    dynamic var dateOf: String? = ""
    dynamic var timePeriod: String? = ""
    dynamic var duration: String? = ""
    dynamic var ageLevel: String? = ""
    dynamic var title: String? = ""
    dynamic var subTitle: String? = ""
    dynamic var objectiveDetails: String? = ""
    dynamic var sessionDetails: String? = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}
