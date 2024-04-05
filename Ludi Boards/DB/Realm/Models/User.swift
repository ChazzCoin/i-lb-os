//
//  User.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import RealmSwift
import FirebaseDatabase

class User: Object, ObjectKeyIdentifiable {
    @Persisted var id: String = CURRENT_USER_ID
    @Persisted var userId: String = UUID().uuidString
    @Persisted var auth: String = UserAuth.owner.name
    @Persisted var role: String = UserRole.temp.name
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
    
    // Initialize from a DataSnapshot
    static func fromSnap(snapshot: DataSnapshot) -> User? {
        let newUser = User()
        guard let value = snapshot.value as? [String: Any],
              let id = snapshot.key as? String,
              let name = value["name"] as? String,
              let userName = value["userName"] as? String else {
            return nil
        }
        newUser.id = id
        newUser.name = name
        newUser.userName = userName
        return newUser
    }
}
