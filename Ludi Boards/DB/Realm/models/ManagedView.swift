//
//  ManagedView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import RealmSwift

class ManagedView: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var dateUpdated: Int = 0
    @Persisted var boardId: String = ""
    @Persisted var sport: String = "pool"
    @Persisted var toolType: String = "8BALL"
    @Persisted var toolColor: String = "TOOLCOLOR.BLACK.name"  // Assuming it's a string representation
    @Persisted var toolSize: String = "TOOLSIZE.MEDIUM.name"  // Assuming it's a string representation
    @Persisted var x: Double = 0.0
    @Persisted var y: Double = 0.0
    @Persisted var startX: Double = 0.0
    @Persisted var startY: Double = 0.0
    @Persisted var centerX: Double = 0.0
    @Persisted var centerY: Double = 0.0
    @Persisted var endX: Double = 0.0
    @Persisted var endY: Double = 0.0
    @Persisted var width: Int = 150
    @Persisted var height: Int = 150
    @Persisted var rotation: Double = 0.0
    @Persisted var lineDash: Int = 5
    @Persisted var translationX: Double = 0.0
    @Persisted var translationY: Double = 0.0
    @Persisted var lastUserId: String = "me"
    @Persisted var isLocked: Bool = false
    @Persisted var isDeleted: Bool = false
    @Persisted var headIsEnabled: Bool = true
    
    @Persisted var colorRed: Double = 48.0
    @Persisted var colorGreen: Double = 128.0
    @Persisted var colorBlue: Double = 20.0
    @Persisted var colorAlpha: Double = 0.75

}

class ManagedViewAction: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var orderIndex: Int = 0
    
    @Persisted var dateUpdated: Int = 0
    @Persisted var boardId: String = ""
    @Persisted var sport: String = "pool"
    @Persisted var toolType: String = "8BALL"
    @Persisted var toolColor: String = "TOOLCOLOR.BLACK.name"  // Assuming it's a string representation
    @Persisted var toolSize: String = "TOOLSIZE.MEDIUM.name"  // Assuming it's a string representation
    @Persisted var x: Double = 0.0
    @Persisted var y: Double = 0.0
    @Persisted var startX: Double = 0.0
    @Persisted var startY: Double = 0.0
    @Persisted var centerX: Double = 0.0
    @Persisted var centerY: Double = 0.0
    @Persisted var endX: Double = 0.0
    @Persisted var endY: Double = 0.0
    @Persisted var width: Int = 150
    @Persisted var height: Int = 150
    @Persisted var rotation: Double = 0.0
    @Persisted var lineDash: Int = 5
    @Persisted var translationX: Double = 0.0
    @Persisted var translationY: Double = 0.0
    @Persisted var lastUserId: String = "me"
    @Persisted var isLocked: Bool = false
    @Persisted var isDeleted: Bool = false
    @Persisted var headIsEnabled: Bool = true
    
    @Persisted var colorRed: Double = 48.0
    @Persisted var colorGreen: Double = 128.0
    @Persisted var colorBlue: Double = 20.0
    @Persisted var colorAlpha: Double = 0.75

}
