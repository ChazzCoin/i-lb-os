//
//  UserToBoard.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import RealmSwift

class UserToBoard: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var boardId: String = "null"
    @objc dynamic var ownerId: String = "null"
    @objc dynamic var userId: String = "null"
    @objc dynamic var userName: String = "null"
    @objc dynamic var userImg: String = "null"
    @objc dynamic var status: String = "accepted"
    @objc dynamic var isConnected: Bool = false

    override static func primaryKey() -> String? {
        return "id"
    }
}
