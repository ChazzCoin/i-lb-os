//
//  User.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import RealmSwift

class User: Object, ObjectKeyIdentifiable {
    @Persisted var id: String = CURRENT_USER_ID
    @Persisted var userId: String = UUID().uuidString
    @Persisted var auth: String = ""
    @Persisted var role: String = ""
    @Persisted var name: String = ""
    @Persisted var userName: String = ""
    @Persisted var email: String = ""
    @Persisted var imgUrl: String = ""
    @Persisted var dateCreated: String = getTimeStamp()
    @Persisted var dateUpdated: String = getTimeStamp()
    @Persisted var sessionId: String = ""
    @Persisted var activityId: String = ""
    @Persisted var membership: Int = 0
    @Persisted var isLoggedIn: Bool = false
    @Persisted var hasInternet: Bool = true
    @Persisted var isOpen: Bool = false
    @Persisted var isLive: Bool = false
    @Persisted var status: Bool = false
    
    override static func primaryKey() -> String {
        return "userId"
    }
}
