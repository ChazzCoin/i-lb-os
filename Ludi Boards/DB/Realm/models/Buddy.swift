//
//  Buddy.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import RealmSwift

@objcMembers class Connection: Object, Identifiable {
    dynamic var id: String = UUID().uuidString
    dynamic var dateCreated: String = getTimeStamp()
    dynamic var dateUpdated: String = getTimeStamp()
    dynamic var userOneId: String = "pending"
    dynamic var userOneName: String = "pending"
    dynamic var userTwoId: String = "pending"
    dynamic var userTwoName: String = "pending"
    dynamic var status: String = "pending"
    dynamic var connectionId: String = "idOne:idTwo"

    override static func primaryKey() -> String? {
        return "id"
    }
}

@objcMembers class Friendship: Object, Identifiable {
    dynamic var id: String = UUID().uuidString
    dynamic var dateCreated: String = getTimeStamp()
    dynamic var dateUpdated: String = getTimeStamp()
    dynamic var fromUserId: String = ""
    dynamic var fromUserName: String = ""
    dynamic var toUserId: String = ""
    dynamic var toUserName: String = ""
    dynamic var status: String = "pending"
    dynamic var isDeleted: Bool = false

    override static func primaryKey() -> String? {
        return "id"
    }
}

@objcMembers class Buddy: Object, Identifiable {
    dynamic var id: String? = nil
    dynamic var dateCreated: String? = nil
    dynamic var dateUpdated: String? = nil
    dynamic var userId: String? = nil
    dynamic var userName: String? = nil
    dynamic var status: String? = "offline"
    dynamic var authLevel: Int = 0
    dynamic var isGuest: Bool = false

    override static func primaryKey() -> String? {
        return "id"
    }
}

func getSampleBuddies() -> [Buddy] {
    let budOne = Buddy()
    budOne.userName = "CoolKid123"
    budOne.status = "Online"
    
    let budTwo = Buddy()
    budTwo.userName = "RetroFan"
    budTwo.status = "Online"
    
    let budThree = Buddy()
    budThree.userName = "SkinnyLove"
    budThree.status = "Away"
    
    return [budOne, budTwo, budThree]
}
