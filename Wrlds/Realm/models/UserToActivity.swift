//
//  UserToBoard.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import RealmSwift

class UserToSession: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var sessionId: String = "null"
    @objc dynamic var hostId: String = "null"
    @objc dynamic var hostUserName: String = "null"
    @objc dynamic var guestId: String = "null"
    @objc dynamic var guestUserName: String = "null"
    @objc dynamic var status: String = "pending"
    @objc dynamic var isConnected: Bool = false
    @objc dynamic var authLevel: String = "guest"

    override static func primaryKey() -> String? {
        return "id"
    }
}

class Share: Object, Identifiable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var sharedId: String = "null"
    @objc dynamic var hostId: String = "null"
    @objc dynamic var hostUserName: String = "null"
    @objc dynamic var guestId: String = "null"
    @objc dynamic var guestUserName: String = "null"
    @objc dynamic var status: String = "pending"
    @objc dynamic var isConnected: Bool = false
    @objc dynamic var authLevel: String = "guest"

    override static func primaryKey() -> String? {
        return "id"
    }
}

//





