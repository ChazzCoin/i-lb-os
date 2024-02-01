//
//  Recording.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/31/24.
//

import Foundation
import RealmSwift

class Recording: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var dateCreated: String = TimeProvider.getCurrentTimestamp()
    @Persisted var boardId: String = ""
    @Persisted var duration: Double = 0.0
    @Persisted var name: String = "Recording \(TimeProvider.getCurrentTimestamp())"
    @Persisted var details: String = ""
}

class RecordingAction: Object, ObjectKeyIdentifiable {
    // Recording Attributes
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var recordingId: String = ""
    @Persisted var boardId: String = ""
    @Persisted var toolId: String = ""
    @Persisted var isInitialState: Bool = false
    @Persisted var orderIndex: Int = 0
    @Persisted var dateCreated: String = TimeProvider.getCurrentTimestamp()
    
    // Managed View Attributes
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


extension RecordingAction {
    
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
