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
