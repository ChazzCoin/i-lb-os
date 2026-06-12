//
//  File.swift
//  
//
//  Created by Charles Romeo on 8/3/24.
//

import Foundation
import SwiftUI
import RealmSwift
import Combine
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
    @Published public var radius: Double
    @Published public var rotation: Double
    @Published public var lineDash: Int
    @Published public var translationX: Double
    @Published public var translationY: Double
    @Published public var lastUserId: String
    @Published public var isLocked: Bool
    @Published public var isDeleted: Bool
    @Published public var isNew: Bool
    @Published public var headIsEnabled: Bool
    
    @Published public var colorRed: Double
    @Published public var colorGreen: Double
    @Published public var colorBlue: Double
    @Published public var colorAlpha: Double

    @Published public var position: CGPoint
    @Published public var showDeleteAlert: Bool = false
    @Published public var ignoreUpdates: Bool = false
    @Published public var anchorsAreVisible: Bool = false
    @Published public var popUpIsVisible: Bool = false
    @Published public var useOriginal: Bool = false
    @Published public var isDragging: Bool = false
    
    @Published public var oXY: CGPoint = CGPoint(x: 0.0, y: 0.0)
    @Published public var cancel = Set<AnyCancellable>()

    // Tool-settings selection (same keys ManagedViewObject writes, standard store)
    @AppStorage("toolBarCurrentViewId") public var toolBarCurrentViewId: String = ""
    @AppStorage("toolSettingsIsShowing") public var toolSettingsIsShowing: Bool = false
    @AppStorage("selectedManagedViewId") public var selectedManagedViewId: String = ""
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
    public var isSquare: Bool {
        return subToolType == ViewEngine.Tool.ShapeTool.square.name
    }
    public var isTriangle: Bool {
        return subToolType == ViewEngine.Tool.ShapeTool.triangle.name
    }
    public func toToolType() -> any ToolCategory {
        if isLineStraight { return ViewEngine.Tool.ShapeTool.line_straight }
        if isLineCurved { return ViewEngine.Tool.ShapeTool.line_curved }
        if isCircle { return ViewEngine.Tool.ShapeTool.circle }
        if isSquare { return ViewEngine.Tool.ShapeTool.square }
        if isTriangle { return ViewEngine.Tool.ShapeTool.triangle }
        if let gen = ViewEngine.Tool.GeneralTool(rawValue: self.subToolType) {
            return gen
        }
        if let temp = ViewEngine.Tool.SoccerTool(rawValue: self.subToolType) {
            return temp
        }
        return ViewEngine.Tool.ShapeTool.line_straight
    }
    
    // Default initializer for creating a new ManagedView
    public init(_ toolType: any ToolCategory = ViewEngine.Tool.ShapeTool.circle) {
        self.realm = try! Realm()

        // Initialize properties with default values
        self.id = UUID().uuidString
        self.dateUpdated = 0
        self.boardId = ""
        self.sport = "tool"
        self.toolType = "shape"
        self.subToolType = toolType.name
        self.toolColor = ""
        self.toolSize = ""
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
        self.radius = 1000.0
        self.rotation = 0.0
        self.lineDash = 5
        self.translationX = 0.0
        self.translationY = 0.0
        self.lastUserId = "me"
        self.isLocked = false
        self.isDeleted = false
        self.isNew = true
        self.headIsEnabled = true
        
        self.colorRed = 48.0
        self.colorGreen = 128.0
        self.colorBlue = 20.0
        self.colorAlpha = 0.75
        
        self.position = CGPoint(x: 0.0, y: 0.0)
        setupByToolType(toolType)
    }
    
    public func setupByToolType(_ toolType: any ToolCategory, anchorX: Double = 0.0, anchorY: Double = 0.0) {
        switch toolType {
            case ViewEngine.Tool.ShapeTool.line_straight, ViewEngine.Tool.ShapeTool.line_curved:
                self.startX = anchorX
                self.startY = anchorY
                self.centerX = anchorX + 250.0
                self.centerY = anchorY
                self.endX = anchorX + 500.0
                self.endY = anchorY
            case ViewEngine.Tool.ShapeTool.square:
                self.x = anchorX
                self.y = anchorY
                self.centerX = anchorX + 500.0
                self.centerY = anchorY - 500.0
                self.startX = anchorX + 500.0
                self.startY = anchorY
                self.endX = anchorX
                self.endY = anchorY - 500.0
            case ViewEngine.Tool.ShapeTool.triangle:
                self.x = anchorX + 250.0
                self.y = anchorY
                self.startX = anchorX + 500.0
                self.startY = anchorY - 500.0
                self.centerX = anchorX
                self.centerY = anchorY - 500.0
            case ViewEngine.Tool.ShapeTool.circle:
                self.radius = 1000.0
                self.width = 200
                self.x = anchorX
                self.y = anchorY
                self.position = CGPoint(x: anchorX, y: anchorY)
            default:
                return
        }
    }

    // Copy a Realm row's values onto the published mirrors.
    private func absorb(from managedView: ManagedView) {
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
        self.radius = managedView.radius
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
        self.isNew = managedView.isNew
        self.position = CGPoint(x: managedView.x, y: managedView.y)
    }

    // Function to load an existing ManagedView by ID
    public func loadManagedView(byId managedViewId: String) {
        if let managedView = realm.object(ofType: ManagedView.self, forPrimaryKey: managedViewId) {
            absorb(from: managedView)
            if self.isNew {
                // First render: apply per-shape geometry defaults anchored at
                // the spawn point, persist them, and clear the flag so later
                // loads keep the user's saved positions.
                setupByToolType(toToolType(), anchorX: managedView.x, anchorY: managedView.y)
                self.isNew = false
                self.position = CGPoint(x: self.x, y: self.y)
                realm.safeWrite { _ in
                    managedView.x = self.x
                    managedView.y = self.y
                    managedView.startX = self.startX
                    managedView.startY = self.startY
                    managedView.centerX = self.centerX
                    managedView.centerY = self.centerY
                    managedView.endX = self.endX
                    managedView.endY = self.endY
                    managedView.radius = self.radius
                    managedView.width = self.width
                    managedView.isNew = false
                }
            }
            observeFromRealm()
        } else {
            print("ManagedView with ID \(managedViewId) not found.")
        }
    }

    // Live updates: settings-bar edits and any other Realm writes flow back
    // onto the published mirrors (the bar and the tool view hold separate
    // ManagedViewO instances).
    public var notificationToken: NotificationToken? = nil

    public func observeFromRealm() {
        notificationToken?.invalidate()
        guard let mv = realm.object(ofType: ManagedView.self, forPrimaryKey: self.id) else { return }
        notificationToken = mv.observe { [weak self] change in
            guard let self = self else { return }
            switch change {
                case .change(let object, _):
                    guard let mv = object as? ManagedView, !mv.isInvalidated else { return }
                    DispatchQueue.main.async {
                        if self.isDragging { return }
                        self.absorb(from: mv)
                    }
                case .deleted:
                    DispatchQueue.main.async { self.isDeleted = true }
                case .error(let error):
                    print("ManagedViewO observer error: \(error)")
            }
        }
    }

    deinit {
        notificationToken?.invalidate()
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
                    existingManagedView.radius = self.radius
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
                    existingManagedView.isNew = self.isNew
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
                    newManagedView.radius = self.radius
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
                    newManagedView.isNew = self.isNew

                    realm.add(newManagedView)
                }
            }
        } catch let error {
            print("Failed to save ManagedView: \(error.localizedDescription)")
        }
    }
    // Function to save changes back to Realm
    public func softDeleteFromRealm() {
        do {
            try realm.write {
                // Check if object exists
                if let existingManagedView = realm.object(ofType: ManagedView.self, forPrimaryKey: self.id) {
                    // Update existing object
                    existingManagedView.isDeleted = true
                    existingManagedView.isLocked = true
                }
            }
        } catch let error {
            print("Failed to save ManagedView: \(error.localizedDescription)")
        }
    }
    // Function to save changes back to Realm
    public func hardDeleteFromRealm() {
        do {
            try realm.write {
                // Check if object exists
                if let existingManagedView = realm.object(ofType: ManagedView.self, forPrimaryKey: self.id) {
                    realm.delete(existingManagedView)
                }
            }
        } catch let error {
            print("Failed to save ManagedView: \(error.localizedDescription)")
        }
    }
    
    public func toggleMenuWindow() {
        if anchorsAreVisible {
            self.toolBarCurrentViewId = self.id
            self.toolSettingsIsShowing = true
            self.selectedManagedViewId = self.id
            BroadcastTools.send(.NavStackMessage, value: NavStackMessage(viewName: "mvSettings", viewAction: WindowAction.open))
        } else {
            self.toolSettingsIsShowing = false
            self.selectedManagedViewId = ""
            BroadcastTools.send(.NavStackMessage, value: NavStackMessage(viewName: "mvSettings", viewAction: WindowAction.close))
        }
    }
    
    @MainActor
    func listenForSettings() {
        BroadcastTools.listenForWindowCalls(storeIn: &cancel, onEvent: { id, action in
            print("ID!!!!! \(id)")
            if id != "mvsettings" { return }
            if action == WindowAction.open {
                if self.anchorsAreVisible {
                    self.anchorsAreVisible = false
                    self.popUpIsVisible = false
                }
            }
            else if action == WindowAction.close {
                if self.anchorsAreVisible {
                    self.anchorsAreVisible = false
                    self.popUpIsVisible = false
                }
            }
            else if action == WindowAction.toggle {
                return
            }
        })
    }
}
