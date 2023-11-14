//
//  BoardSession.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import RealmSwift

class BoardSession: Object {
    @objc dynamic var id: String = ""  // Assuming CodiRealmCore.newId is a method in your Swift code
    @objc dynamic var dateCreated: String = "CodiDateTime.now.toString()" // Assuming CodiDateTime.now.toString() is a method in your Swift code
    @objc dynamic var dateUpdated: String = "CodiDateTime.now.toString()" // Similar assumption as above
    @objc dynamic var screenWidth: Int = 1500
    @objc dynamic var screenHeight: Int = 2000
    @objc dynamic var backgroundImg: String? = "Soccer 2"
    @objc dynamic var sport: String? = "soccer"
    @objc dynamic var ownerId: String = "null"
    @objc dynamic var title: String = "unnamed"
    @objc dynamic var details: String = ""
    @objc dynamic var objective: String = ""
    @objc dynamic var isOpen: Bool = true

    override static func primaryKey() -> String? {
        return "id"
    }
}
