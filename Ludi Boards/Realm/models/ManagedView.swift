//
//  ManagedView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import RealmSwift

@objcMembers class ManagedView: Object, Identifiable {
    dynamic var id: String = UUID().uuidString
    dynamic var dateUpdated: Int = 0
    dynamic var boardId: String = ""
    dynamic var sport: String = "pool"
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
    dynamic var lineDash: Int = 5
    dynamic var translationX: Double = 0.0
    dynamic var translationY: Double = 0.0
    dynamic var lastUserId: String = "me"
    dynamic var isLocked: Bool = false
    
    dynamic var colorRed: Double = 48.0
    dynamic var colorGreen: Double = 128.0
    dynamic var colorBlue: Double = 20.0
    dynamic var colorAlpha: Double = 0.75

    override static func primaryKey() -> String? {
        return "id"
    }
    func toDictionary() -> [String: Any] {
        let properties = self.objectSchema.properties.map { $0.name }
        var dictionary: [String: Any] = [:]
        for property in properties {
            dictionary[property] = self.value(forKey: property)
        }
        return dictionary
    }

}
