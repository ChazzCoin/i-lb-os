//
//  Recording.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/31/24.
//

import Foundation
import RealmSwift

public class Recording: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var dateCreated: String = TimeProvider.getCurrentTimestamp()
    @Persisted public var boardId: String = ""
    @Persisted public var duration: Double = 0.0
    @Persisted public var name: String = "Recording \(TimeProvider.getCurrentTimestamp())"
    @Persisted public var details: String = ""
}

public class RecordingAction: Object, ObjectKeyIdentifiable {
    // Recording Attributes
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var recordingId: String = ""
    @Persisted public var boardId: String = ""
    @Persisted public var toolId: String = ""
    @Persisted public var isInitialState: Bool = false
    @Persisted public var orderIndex: Int = 0
    @Persisted public var dateCreated: String = TimeProvider.getCurrentTimestamp()
    
    // Managed View Attributes
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


public extension RecordingAction {
    
    func absorb(from managedView: ManagedView) {
        self.boardId = managedView.boardId
        self.toolId = managedView.id
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
    
    
    func absorb(from managedView: ManagedView, saveRealm: Realm, orderIndex: Int?=nil) {
        saveRealm.safeWrite { _ in
            if let oI = orderIndex { self.orderIndex = oI }
            self.boardId = managedView.boardId
            self.toolId = managedView.id
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
    
}
