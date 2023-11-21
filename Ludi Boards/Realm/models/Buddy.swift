//
//  Buddy.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import RealmSwift

@objcMembers class Buddy: Object, Identifiable {
    dynamic var id: String = UUID().uuidString
    dynamic var dateCreated: String? = ""
    dynamic var dateUpdated: String? = ""
    dynamic var userId: String? = ""
    dynamic var userName: String? = ""
    dynamic var name: String? = ""
    dynamic var status: String? = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}

func getSampleBuddies() -> [Buddy] {
    var budOne = Buddy()
    budOne.userName = "CoolKid123"
    budOne.status = "Online"
    
    var budTwo = Buddy()
    budTwo.userName = "RetroFan"
    budTwo.status = "Away"
    
    return [budOne, budTwo]
}
