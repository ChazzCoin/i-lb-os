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

extension ManagedView {
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "dateUpdated": dateUpdated,
            "boardId": boardId,
            "sport": sport,
            "toolType": toolType,
            "toolColor": toolColor,
            "toolSize": toolSize,
            "x": x,
            "y": y,
            "width": width,
            "height": height,
            "rotation": rotation,
            "translationX": translationX,
            "translationY": translationY
        ]
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