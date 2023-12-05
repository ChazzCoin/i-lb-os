//
//  ManagedViewAction.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import RealmSwift

@objcMembers class ManagedViewAction: Object {
    dynamic var id: String = UUID().uuidString
    dynamic var managedViewId: String = ""
    dynamic var boardId: String = ""
    dynamic var orderIndex: Int = 0
    dynamic var toolType: String = "8BALL"
    dynamic var toolColor: String = "TOOLCOLOR.BLACK.name"  // Assuming it's a string representation
    dynamic var toolSize: String = "TOOLSIZE.MEDIUM.name"  // Assuming it's a string representation
    dynamic var x: Double = 0.0
    dynamic var y: Double = 0.0
    dynamic var startX: Double = 0.0
    dynamic var startY: Double = 0.0
    dynamic var endX: Double = 0.0
    dynamic var endY: Double = 0.0
    dynamic var width: Int = 0
    dynamic var height: Int = 0
    dynamic var rotation: Double = 0.0
    dynamic var translationX: Double = 0.0
    dynamic var translationY: Double = 0.0
    dynamic var lastUserId: String = "me"
    
    dynamic var colorRed: Double = 48.0
    dynamic var colorGreen: Double = 128.0
    dynamic var colorBlue: Double = 20.0
    dynamic var colorAlpha: Double = 0.75
    dynamic var duration: Int = 2000 // duration in milliseconds

    override static func primaryKey() -> String? {
        return "id"
    }
}
