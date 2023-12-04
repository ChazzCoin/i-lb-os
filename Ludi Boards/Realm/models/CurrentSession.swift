//
//  SessionPlan.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import RealmSwift

@objcMembers class CurrentSession: Object, Identifiable {
    dynamic var id: String = "SOL"
    dynamic var dateCreated: String = getTimeStamp()
    dynamic var dateUpdated: String = getTimeStamp()
    dynamic var sessionId: String = ""
    dynamic var activityId: String = ""
    dynamic var membership: Int = 0
    dynamic var isLoggedIn: Bool = false
    dynamic var hasInternet: Bool = true
    dynamic var isOpen: Bool = false
    dynamic var isLive: Bool = false

    override static func primaryKey() -> String {
        return "id"
    }
}
