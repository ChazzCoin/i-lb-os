//
//  ManagedViewAction.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import RealmSwift

class ManagedViewAction: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var managedViewId: String = ""
    @objc dynamic var boardId: String = ""
    @objc dynamic var orderIndex: Int = 0
    @objc dynamic var x: Float = 0.0
    @objc dynamic var y: Float = 0.0
    @objc dynamic var width: Int = 0
    @objc dynamic var height: Int = 0
    @objc dynamic var color: String = ""
    @objc dynamic var size: String = ""
    @objc dynamic var duration: Int = 2000 // duration in milliseconds

    override static func primaryKey() -> String? {
        return "id"
    }
}
