//
//  User.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import RealmSwift
import FirebaseDatabase

public let CURRENT_USER_ID = "CORE"

public class CoreUser: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = CURRENT_USER_ID
    @Persisted public var userId: String = UUID().uuidString
    @Persisted public var auth: String = UserAuth.owner.name
    @Persisted public var role: String = UserRole.temp.name
    @Persisted public var name: String = ""
    @Persisted public var userName: String = ""
    @Persisted public var handle: String = ""
    @Persisted public var email: String = ""
    @Persisted public var imgUrl: String = ""
    @Persisted public var dateCreated: String = getTimeStamp()
    @Persisted public var dateUpdated: String = getTimeStamp()
    @Persisted public var membership: Int = 0
    @Persisted public var isOpen: Bool = false
    @Persisted public var status: Bool = false
    
    // Link to friend requests the user has sent or received
//    @Persisted(originProperty: "fromUserId") var sentRequests: LinkingObjects<FriendRequest>
//    @Persisted(originProperty: "toUser") var receivedRequests: LinkingObjects<FriendRequest>
    @Persisted public var linkedFriends: List<CoreUser> = List()
    
    public static let COLLECTION_NAME = DatabasePaths.users.rawValue
    
    // Initialize from a DataSnapshot
    public static func fromSnap(snapshot: DataSnapshot) -> CoreUser? {
        let newUser = CoreUser()
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
