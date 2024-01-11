//
//  SessionPlan.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import RealmSwift

let CURRENT_USER_ID = "SOL"

class CurrentSolUser: Object, ObjectKeyIdentifiable {
    @Persisted var id: String = CURRENT_USER_ID
    @Persisted var userId: String = UUID().uuidString
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
        return "id"
    }
}

class SolUser: Object, ObjectKeyIdentifiable {
    @Persisted var id: String = CURRENT_USER_ID
    @Persisted var userId: String = UUID().uuidString
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

extension Realm {
    
    func setCurrentSolUserId(newId:String) {
        if let temp = self.findByField(CurrentSolUser.self, value: CURRENT_USER_ID) {
            self.safeWrite { r in
                temp.userId = newId
            }
        }
    }
    
    func getCurrentSolUser() -> CurrentSolUser? {
        return self.findByField(CurrentSolUser.self, value: CURRENT_USER_ID)
    }
    
    func getCurrentSolUser(action: @escaping (CurrentSolUser) -> Void) {
        if let temp = self.findByField(CurrentSolUser.self, value: CURRENT_USER_ID) {
            action(temp)
        }
    }
    
    func updateGetCurrentSolUser(action: @escaping (CurrentSolUser) -> Void) {
        if let temp = self.findByField(CurrentSolUser.self, value: CURRENT_USER_ID) {
            self.safeWrite { r in
                action(temp)
            }
            
        }
    }
    
    func userIsLoggedIn() -> Bool {
        if let user = self.findByField(CurrentSolUser.self, value: CURRENT_USER_ID) {
//            print("!! USER: \(user)")
            return user.isLoggedIn
        }
        return false
    }
    
    func safeSetupCurrentSolUser() {
        if let _ = self.findByField(CurrentSolUser.self, value: CURRENT_USER_ID) {
            return
        }
        let newCS = CurrentSolUser()
        self.safeWrite { r in
            r.create(CurrentSolUser.self, value: newCS)
        }
    }
    
}
