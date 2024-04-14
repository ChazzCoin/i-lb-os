//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/9/24.
//

import Foundation
import SwiftUI

public class NavStackWindowObservable : ObservableObject {
    
    public init() {}
    
    @Published public var isHidden = false
    @Published public var isLocked = false
    
    @Published public var navStackCount = 0
    @Published public var keyboardIsShowing = false
    @Published public var keyboardHeight = 0.0
    
    @Published public var screen: UIScreen = UIScreen.main
    @Published public var width = UIScreen.main.bounds.width * 0.9
    @Published public var height = UIScreen.main.bounds.height
    
    @Published public var fWidth = UIScreen.main.bounds.width * 0.5
    @Published public var fHeight = UIScreen.main.bounds.height * 0.5
    
    @Published public var currentScreenWidthModifier = 0.9
    @Published public var currentPositionModifier = 0.05
    @Published public var currentScreenSize = "full" // half, float
    
    @Published public var offset = CGSize.zero
    @Published public var position = CGPoint(x: 0, y: 0)
    @Published public var originOffPos = CGPoint(x: 0, y: 0)
    @Published public var offPos = CGPoint(x: 0, y: 0)
    @GestureState public var dragOffset = CGSize.zero
    @Published public var isDragging = false
    
    public func resetNavStack(gps: GlobalPositioningSystem) {
        self.width = UIScreen.main.bounds.width * 0.9
        self.height = UIScreen.main.bounds.height
        self.position = gps.getCoordinate(for: .center, offsetX: width * 0.05)
    }
    
    public func addToStack() {
        self.navStackCount = self.navStackCount + 1
    }
    public func removeFromStack() {
        self.navStackCount = self.navStackCount - 1
    }
    
    public func resetPosition(gps: GlobalPositioningSystem) {
        position = gps.getCoordinate(for: .center, offsetX: width * 0.05)
    }
    
    public func toggleWindowSize(gps: GlobalPositioningSystem) {
        if currentScreenSize == "half" {
            fullScreenPosition(gps: gps)
        } else {
            halfScreenPosition(gps: gps)
        }
    }

    public func fullScreenPosition(gps: GlobalPositioningSystem) {
        width = UIScreen.main.bounds.width * 0.9
        height = UIScreen.main.bounds.height
        position = gps.getCoordinate(for: .center, offsetX: width * 0.05)
        currentScreenSize = "full"
        offset = CGSize.zero
        originOffPos = CGPoint(x: 0, y: 0)
        offPos = CGPoint(x: 0, y: 0)
    }

    public func halfScreenPosition(gps: GlobalPositioningSystem) {
        width = UIScreen.main.bounds.width * 0.5
        height = UIScreen.main.bounds.height
        position = gps.getCoordinate(for: .center, offsetX: width * 0.5)
        currentScreenSize = "half"
    }
    
}
