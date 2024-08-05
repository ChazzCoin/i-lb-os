//
//  File.swift
//  
//
//  Created by Charles Romeo on 8/3/24.
//

import Foundation
import SwiftUI
import RealmSwift

// ViewModel for ManagedView
public class ManagedViewO: ObservableObject {
    // Observable properties for each attribute
    @Published public var id: String
    @Published public var dateUpdated: Int
    @Published public var boardId: String
    @Published public var sport: String
    @Published public var toolType: String
    @Published public var subToolType: String
    @Published public var toolColor: String
    @Published public var toolSize: String
    @Published public var x: Double
    @Published public var y: Double
    @Published public var startX: Double
    @Published public var startY: Double
    @Published public var centerX: Double
    @Published public var centerY: Double
    @Published public var endX: Double
    @Published public var endY: Double
    @Published public var width: Int
    @Published public var height: Int
    @Published public var rotation: Double
    @Published public var lineDash: Int
    @Published public var translationX: Double
    @Published public var translationY: Double
    @Published public var lastUserId: String
    @Published public var isLocked: Bool
    @Published public var isDeleted: Bool
    @Published public var headIsEnabled: Bool
    
    @Published public var colorRed: Double
    @Published public var colorGreen: Double
    @Published public var colorBlue: Double
    @Published public var colorAlpha: Double

    // Realm instance
    public var realm: Realm
    
    public var isTool: Bool { return sport == "tool" }
    public var isGeneral: Bool { return toolType == "general" }
    public var isShape: Bool { return toolType == "shape" }
    public var isSoccer: Bool { return toolType == "soccer" }
    
    public var isSportTool: Bool {
        return !isGeneral && !isShape
    }
    public var isLinedShape: Bool {
        return subToolType == ViewEngine.Tool.ShapeTool.line_straight.name
        || subToolType == ViewEngine.Tool.ShapeTool.line_curved.name
        || subToolType == ViewEngine.Tool.ShapeTool.line_dotted.name
        || subToolType == ViewEngine.Tool.ShapeTool.square.name
        || subToolType == ViewEngine.Tool.ShapeTool.triangle.name
    }

    public var isLineStraight: Bool {
        return subToolType == ViewEngine.Tool.ShapeTool.line_straight.name
    }
    public var isLineCurved: Bool {
        return subToolType == ViewEngine.Tool.ShapeTool.line_curved.name
    }
    public var isCircle: Bool {
        return subToolType == ViewEngine.Tool.ShapeTool.circle.name
    }
    
    // Default initializer for creating a new ManagedView
    public init() {
        self.realm = try! Realm()

        // Initialize properties with default values
        self.id = UUID().uuidString
        self.dateUpdated = 0
        self.boardId = ""
        self.sport = "tool"
        self.toolType = "shape"
        self.subToolType = "square"
        self.toolColor = "TOOLCOLOR.BLACK.name"
        self.toolSize = "TOOLSIZE.MEDIUM.name"
        self.x = 0.0
        self.y = 0.0
        self.startX = 100.0
        self.startY = 100.0
        self.centerX = 200.0
        self.centerY = 200.0
        self.endX = 300.0
        self.endY = 300.0
        self.width = 100
        self.height = 100
        self.rotation = 0.0
        self.lineDash = 5
        self.translationX = 0.0
        self.translationY = 0.0
        self.lastUserId = "me"
        self.isLocked = false
        self.isDeleted = false
        self.headIsEnabled = true
        
        self.colorRed = 48.0
        self.colorGreen = 128.0
        self.colorBlue = 20.0
        self.colorAlpha = 0.75
    }

    // Function to load an existing ManagedView by ID
    public func loadManagedView(byId managedViewId: String) {
        if let managedView = realm.object(ofType: ManagedView.self, forPrimaryKey: managedViewId) {
            // Update properties with the values from Realm
            self.id = managedView.id
            self.dateUpdated = managedView.dateUpdated
            self.boardId = managedView.boardId
            self.sport = managedView.sport
            self.toolType = managedView.toolType
            self.subToolType = managedView.subToolType
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
        } else {
            print("ManagedView with ID \(managedViewId) not found.")
        }
    }

    // Function to save changes back to Realm
    public func saveToRealm() {
        do {
            try realm.write {
                // Check if object exists
                if let existingManagedView = realm.object(ofType: ManagedView.self, forPrimaryKey: self.id) {
                    // Update existing object
                    existingManagedView.dateUpdated = self.dateUpdated
                    existingManagedView.boardId = self.boardId
                    existingManagedView.sport = self.sport
                    existingManagedView.toolType = self.toolType
                    existingManagedView.subToolType = self.subToolType
                    existingManagedView.toolColor = self.toolColor
                    existingManagedView.toolSize = self.toolSize
                    existingManagedView.x = self.x
                    existingManagedView.y = self.y
                    existingManagedView.startX = self.startX
                    existingManagedView.startY = self.startY
                    existingManagedView.centerX = self.centerX
                    existingManagedView.centerY = self.centerY
                    existingManagedView.endX = self.endX
                    existingManagedView.endY = self.endY
                    existingManagedView.width = self.width
                    existingManagedView.height = self.height
                    existingManagedView.rotation = self.rotation
                    existingManagedView.lineDash = self.lineDash
                    existingManagedView.translationX = self.translationX
                    existingManagedView.translationY = self.translationY
                    existingManagedView.lastUserId = self.lastUserId
                    existingManagedView.isLocked = self.isLocked
                    existingManagedView.isDeleted = self.isDeleted
                    existingManagedView.headIsEnabled = self.headIsEnabled
                    existingManagedView.colorRed = self.colorRed
                    existingManagedView.colorGreen = self.colorGreen
                    existingManagedView.colorBlue = self.colorBlue
                    existingManagedView.colorAlpha = self.colorAlpha
                } else {
                    // Create a new object if not found
                    let newManagedView = ManagedView()
                    newManagedView.id = self.id
                    newManagedView.dateUpdated = self.dateUpdated
                    newManagedView.boardId = self.boardId
                    newManagedView.sport = self.sport
                    newManagedView.toolType = self.toolType
                    newManagedView.subToolType = self.subToolType
                    newManagedView.toolColor = self.toolColor
                    newManagedView.toolSize = self.toolSize
                    newManagedView.x = self.x
                    newManagedView.y = self.y
                    newManagedView.startX = self.startX
                    newManagedView.startY = self.startY
                    newManagedView.centerX = self.centerX
                    newManagedView.centerY = self.centerY
                    newManagedView.endX = self.endX
                    newManagedView.endY = self.endY
                    newManagedView.width = self.width
                    newManagedView.height = self.height
                    newManagedView.rotation = self.rotation
                    newManagedView.lineDash = self.lineDash
                    newManagedView.translationX = self.translationX
                    newManagedView.translationY = self.translationY
                    newManagedView.lastUserId = self.lastUserId
                    newManagedView.isLocked = self.isLocked
                    newManagedView.isDeleted = self.isDeleted
                    newManagedView.headIsEnabled = self.headIsEnabled
                    newManagedView.colorRed = self.colorRed
                    newManagedView.colorGreen = self.colorGreen
                    newManagedView.colorBlue = self.colorBlue
                    newManagedView.colorAlpha = self.colorAlpha

                    realm.add(newManagedView)
                }
            }
        } catch let error {
            print("Failed to save ManagedView: \(error.localizedDescription)")
        }
    }
    
}
