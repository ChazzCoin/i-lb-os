//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/10/24.
//

import Foundation
import RealmSwift

public enum FriendStatus: String, CaseIterable {
    case accepted = "accepted"
    case rejected = "rejected"
    case pending = "pending"
}

public class FriendRequest: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var fromUserId: String = ""
    @Persisted public var toUserId: String = ""
    @Persisted public var status: String = FriendStatus.pending.rawValue
}

//public class Friends: Object, ObjectKeyIdentifiable {
//    
//    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
//    @Persisted public var dateCreated: String = getTimeStamp()
//    @Persisted public var dateUpdated: String = getTimeStamp()
//    @Persisted public var userId: String = ""
//    @Persisted public var friendIds: RealmSwift.List<String> = RealmSwift.List<String>()
//    
//}
