//
//  ManagedView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import RealmSwift

public class ManagedPlayerRef: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var toolId: String = ""
    @Persisted public var playerRefId: String = ""
    @Persisted public var status: String = "1"
}


public class ManagedView: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var dateUpdated: Int = 0
    @Persisted public var boardId: String = ""
    @Persisted public var sport: String = "tool"
    @Persisted public var toolType: String = "shape"
    @Persisted public var subToolType: String = "square"
    @Persisted public var toolColor: String = ""  // Assuming it's a string representation
    @Persisted public var toolSize: String = "500.0"  // Assuming it's a string representation
    @Persisted public var x: Double = 0.0
    @Persisted public var y: Double = 0.0
    @Persisted public var startX: Double = 0.0
    @Persisted public var startY: Double = 0.0
    @Persisted public var centerX: Double = 0.0
    @Persisted public var centerY: Double = 0.0
    @Persisted public var endX: Double = 0.0
    @Persisted public var endY: Double = 0.0
    @Persisted public var radius: Double = 0.0
    @Persisted public var width: Int = 100
    @Persisted public var height: Int = 100
    @Persisted public var rotation: Double = 0.0
    @Persisted public var lineDash: Int = 5
    @Persisted public var translationX: Double = 0.0
    @Persisted public var translationY: Double = 0.0
    @Persisted public var lastUserId: String = "me"
    @Persisted public var isLocked: Bool = false
    @Persisted public var isDeleted: Bool = false
    @Persisted public var isNew: Bool = true
    @Persisted public var headIsEnabled: Bool = true
    
    @Persisted public var colorRed: Double = 48.0
    @Persisted public var colorGreen: Double = 128.0
    @Persisted public var colorBlue: Double = 20.0
    @Persisted public var colorAlpha: Double = 0.75

    // Roster link (RD-5 / TASK-011). Denormalised so a player disc can show its
    // number without a cross-module lookup. `playerId` references a RosterPlayer.
    @Persisted public var playerId: String = ""
    @Persisted public var jerseyNumber: Int = 0
    @Persisted public var teamSide: String = ""   // "home" / "away"

    func areAllAttributesZero() -> Bool {
        return x == 0.0 &&
               y == 0.0 &&
               startX == 0.0 &&
               startY == 0.0 &&
               centerX == 0.0 &&
               centerY == 0.0 &&
               endX == 0.0 &&
               endY == 0.0
    }
}

public class ManagedViewAction: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var viewId: String = ""
    @Persisted public var boardId: String = ""
    @Persisted public var dateCreated: String = "getTimeStamp()"
    @Persisted public var isStart: Bool = false
    @Persisted public var orderIndex: Int = 0
    
    @Persisted public var dateUpdated: Int = 0
    @Persisted public var sport: String = "pool"
    @Persisted public var toolType: String = "8BALL"
    @Persisted public var toolColor: String = "TOOLCOLOR.BLACK.name"  // Assuming it's a string representation
    @Persisted public var toolSize: String = "TOOLSIZE.MEDIUM.name"  // Assuming it's a string representation
    @Persisted public var x: Double = 0.0
    @Persisted public var y: Double = 0.0
    @Persisted public var startX: Double = 0.0
    @Persisted public var startY: Double = 0.0
    @Persisted public var centerX: Double = 0.0
    @Persisted public var centerY: Double = 0.0
    @Persisted public var endX: Double = 0.0
    @Persisted public var endY: Double = 0.0
    @Persisted public var width: Int = 150
    @Persisted public var height: Int = 150
    @Persisted public var rotation: Double = 0.0
    @Persisted public var lineDash: Int = 5
    @Persisted public var translationX: Double = 0.0
    @Persisted public var translationY: Double = 0.0
    @Persisted public var lastUserId: String = "me"
    @Persisted public var isLocked: Bool = false
    @Persisted public var isDeleted: Bool = false
    @Persisted public var headIsEnabled: Bool = true
    
    @Persisted public var colorRed: Double = 48.0
    @Persisted public var colorGreen: Double = 128.0
    @Persisted public var colorBlue: Double = 20.0
    @Persisted public var colorAlpha: Double = 0.75

}

public extension ManagedView {
    func absorbRecordingAction(from managedView: RecordingAction, saveRealm: Realm) {
        saveRealm.safeWrite { _ in
            self.toolType = managedView.toolType
            self.toolColor = managedView.toolColor
            self.toolSize = managedView.toolSize
            self.x = managedView.x
            self.y = managedView.y
            self.startX = managedView.startX
            self.startY = managedView.startY
            self.centerX = managedView.centerX
            self.centerY = managedView.centerY
            self.endX = managedView.endX
            self.endY = managedView.endY
            self.width = managedView.width
            self.height = managedView.height
            self.rotation = managedView.rotation
            self.lineDash = managedView.lineDash
            self.translationX = managedView.translationX
            self.translationY = managedView.translationY
            self.lastUserId = "recorder"
            self.isLocked = managedView.isLocked
            self.isDeleted = managedView.isDeleted
            self.headIsEnabled = managedView.headIsEnabled
            self.colorRed = managedView.colorRed
            self.colorGreen = managedView.colorGreen
            self.colorBlue = managedView.colorBlue
            self.colorAlpha = managedView.colorAlpha
        }
    }
    
    public func absorbAction(from managedView: ManagedViewAction, saveRealm: Realm) {
        saveRealm.safeWrite { _ in
            self.toolType = managedView.toolType
            self.toolColor = managedView.toolColor
            self.toolSize = managedView.toolSize
            self.x = managedView.x
            self.y = managedView.y
            self.startX = managedView.startX
            self.startY = managedView.startY
            self.centerX = managedView.centerX
            self.centerY = managedView.centerY
            self.endX = managedView.endX
            self.endY = managedView.endY
            self.width = managedView.width
            self.height = managedView.height
            self.rotation = managedView.rotation
            self.lineDash = managedView.lineDash
            self.translationX = managedView.translationX
            self.translationY = managedView.translationY
            self.lastUserId = "recorder"
            self.isLocked = managedView.isLocked
            self.isDeleted = managedView.isDeleted
            self.headIsEnabled = managedView.headIsEnabled
            self.colorRed = managedView.colorRed
            self.colorGreen = managedView.colorGreen
            self.colorBlue = managedView.colorBlue
            self.colorAlpha = managedView.colorAlpha
        }
    }
}

public extension ManagedViewAction {
    
    public func absorb(from managedView: ManagedView) {
            self.viewId = managedView.id
            self.boardId = managedView.boardId
            self.sport = managedView.sport
            self.toolType = managedView.toolType
            self.toolColor = managedView.toolColor
            self.toolSize = managedView.toolSize
            self.x = managedView.x
            self.y = managedView.y
            self.startX = managedView.startX
            self.startY = managedView.startY
            self.centerX = managedView.centerX
            self.centerY = managedView.centerY
            self.endX = managedView.endX
            self.endY = managedView.endY
            self.width = managedView.width
            self.height = managedView.height
            self.rotation = managedView.rotation
            self.lineDash = managedView.lineDash
            self.translationX = managedView.translationX
            self.translationY = managedView.translationY
            self.lastUserId = managedView.lastUserId
            self.isLocked = managedView.isLocked
            self.isDeleted = managedView.isDeleted
            self.headIsEnabled = managedView.headIsEnabled
            self.colorRed = managedView.colorRed
            self.colorGreen = managedView.colorGreen
            self.colorBlue = managedView.colorBlue
            self.colorAlpha = managedView.colorAlpha
        }
    
}
