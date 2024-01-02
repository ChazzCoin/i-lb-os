//
//  SessionPlan.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import RealmSwift

let CURRENT_USER_ID = "SOL"

@objcMembers class CurrentSolUser: Object, Identifiable {
    dynamic var id: String = CURRENT_USER_ID
    dynamic var userId: String = UUID().uuidString
    dynamic var userName: String = ""
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

extension Realm {
    
    func setCurrentSolUserId(newId:String) {
        if let temp = self.findByField(CurrentSolUser.self, value: CURRENT_USER_ID) {
            self.safeWrite { r in
                temp.userId = newId
            }
        }
    }
    
    func getCurrentSolUserId() -> CurrentSolUser? {
        return self.findByField(CurrentSolUser.self, value: CURRENT_USER_ID)
    }
    
    func loadGetCurrentSolUser(action: (CurrentSolUser) -> Void) {
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
