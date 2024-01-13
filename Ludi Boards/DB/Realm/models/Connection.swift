//
//  Connection.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/13/24.
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
