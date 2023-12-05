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
    dynamic var translationX: Double = 0.0
    dynamic var translationY: Double = 0.0
    dynamic var lastUserId: String = "me"
    
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
    // Add a convenience initializer to initialize from a dictionary
//    convenience init(dictionary: [String: Any]) {
//        self.init()
//        let properties = self.objectSchema.properties.map { $0.name }
//        
//        for property in properties {
//            if let value = dictionary[property] {
//                self.setValue(value, forKey: property)
//            }
//        }
//    }
    
}

extension ManagedView {
    
    convenience init(dictionary: [String: Any]) {
        self.init()
        let properties = self.objectSchema.properties.map { $0.name }
        
        for property in properties {
            if let value = dictionary[property] {
                self.setValue(value, forKey: property)
            }
        }
    }
    
    func toDict() -> [String: Any] {
        let properties = self.objectSchema.properties.map { $0.name }
        var dictionary: [String: Any] = [:]
        for property in properties {
            dictionary[property] = self.value(forKey: property)
        }
        return dictionary
    }
}

func toManagedView(dictionary: [String: Any]) -> ManagedView? {
    let managedView = ManagedView()

    if let id = dictionary["id"] as? String {
        managedView.id = id
    }
    if let dateUpdated = dictionary["dateUpdated"] as? Int {
        managedView.dateUpdated = dateUpdated
    }
    if let lastUID = dictionary["lastUserId"] as? String {
        managedView.lastUserId = lastUID
    }
    if let boardId = dictionary["boardId"] as? String {
        managedView.boardId = boardId
    }
    if let sport = dictionary["sport"] as? String {
        managedView.sport = sport
    }
    if let toolType = dictionary["toolType"] as? String {
        managedView.toolType = toolType
    }
    if let toolColor = dictionary["toolColor"] as? String {
        managedView.toolColor = toolColor
    }
    if let toolSize = dictionary["toolSize"] as? String {
        managedView.toolSize = toolSize
    }
    if let x = dictionary["x"] as? Double {
        managedView.x = x
    }
    if let y = dictionary["y"] as? Double {
        managedView.y = y
    }
    
    if let sx = dictionary["startX"] as? Double {
        managedView.startX = sx
    }
    if let sy = dictionary["startY"] as? Double {
        managedView.startY = sy
    }
    
    if let ex = dictionary["endX"] as? Double {
        managedView.endX = ex
    }
    if let ey = dictionary["endY"] as? Double {
        managedView.endY = ey
    }
    
    if let width = dictionary["width"] as? Int {
        managedView.width = width
    }
    if let height = dictionary["height"] as? Int {
        managedView.height = height
    }
    if let rotation = dictionary["rotation"] as? Double {
        managedView.rotation = rotation
    }
    if let translationX = dictionary["translationX"] as? Double {
        managedView.translationX = translationX
    }
    if let translationY = dictionary["translationY"] as? Double {
        managedView.translationY = translationY
    }
    return managedView
}
