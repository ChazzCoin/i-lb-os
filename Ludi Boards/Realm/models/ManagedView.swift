//
//  ManagedView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import RealmSwift

class ManagedView: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var dateUpdated: Int = 0
    @objc dynamic var boardId: String = ""
    @objc dynamic var sport: String = "pool"
    @objc dynamic var toolType: String = "8BALL"
    @objc dynamic var toolColor: String = "TOOLCOLOR.BLACK.name"  // Assuming it's a string representation
    @objc dynamic var toolSize: String = "TOOLSIZE.MEDIUM.name"  // Assuming it's a string representation
    @objc dynamic var x: Double = 0.0
    @objc dynamic var y: Double = 0.0
    @objc dynamic var width: Int = 0
    @objc dynamic var height: Int = 0
    @objc dynamic var rotation: Double = 0.0
    @objc dynamic var translationX: Double = 0.0
    @objc dynamic var translationY: Double = 0.0

    override static func primaryKey() -> String? {
        return "id"
    }
}
