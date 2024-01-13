//
//  Extensions.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/27/23.
//

import Foundation
import CoreGraphics
import UIKit

extension Array where Element: Equatable {
    
    mutating func removeDuplicates() {
        self = self.reduce(into: []) { (result, element) in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
    
}


extension Array where Element: UserToSession {
    mutating func safeAdd(_ item: UserToSession) {
        if self.firstIndex(where: { $0.id == item.id }) != nil {
            // Item found, remove it
            return
        }
        // Item not found, add it
        self.append(item as! Element)
    }
    
    mutating func safeRemove(_ item: Share) {
        if let index = self.firstIndex(where: { $0.id == item.id }) {
            // Item found, remove it
            self.remove(at: index)
        }
    }
}
//
extension Array where Element: ManagedView {
    func hasView(_ item: ManagedView) -> Bool {
        if self.firstIndex(where: { $0.id == item.id }) != nil {
            // Item found, remove it
            return true
        }
        // Item not found, add it
        return false
    }
    mutating func safeAddManagedView(_ item: ManagedView) {
        if self.firstIndex(where: { $0.id == item.id }) != nil {
            // Item found, remove it
            return
        }
        // Item not found, add it
        self.append(item as! Element)
    }
    
    mutating func safeRemove(_ item: ManagedView) {
        if let index = self.firstIndex(where: { $0.id == item.id }) {
            // Item found, remove it
            self.remove(at: index)
        }
    }
    mutating func safeRemoveById(_ id: String) {
        if let index = self.firstIndex(where: { $0.id == id }) {
            // Item found, remove it
            self.remove(at: index)
        }
    }
}
//
extension Array where Element: SolUser {
    mutating func safeAdd(_ item: SolUser) {
        if self.firstIndex(where: { $0.id == item.id }) != nil {
            // Item found, remove it
            return
        }
        // Item not found, add it
        self.append(item as! Element)
    }
    
    mutating func safeRemove(_ item: SolUser) {
        if let index = self.firstIndex(where: { $0.id == item.id }) {
            // Item found, remove it
            self.remove(at: index)
        }
    }
}
extension Array where Element: Room {
    mutating func safeAdd(_ item: Room) {
        if self.firstIndex(where: { $0.id == item.id }) != nil {
            // Item found, remove it
            return
        }
        // Item not found, add it
        self.append(item as! Element)
    }
    
    mutating func safeRemove(_ item: Room) {
        if let index = self.firstIndex(where: { $0.id == item.id }) {
            // Item found, remove it
            self.remove(at: index)
        }
    }
}
extension Array where Element: SessionPlan {
    mutating func safeAdd(_ item: SessionPlan) {
        if self.firstIndex(where: { $0.id == item.id }) != nil {
            // Item found, remove it
            return
        }
        // Item not found, add it
        self.append(item as! Element)
    }
    
    mutating func safeRemove(_ item: SessionPlan) {
        if let index = self.firstIndex(where: { $0.id == item.id }) {
            // Item found, remove it
            self.remove(at: index)
        }
    }
}
extension Array where Element: ActivityPlan {
    mutating func safeAdd(_ item: ActivityPlan) {
        if self.firstIndex(where: { $0.id == item.id }) != nil {
            // Item found, remove it
            return
        }
        // Item not found, add it
        self.append(item as! Element)
    }
    
    mutating func safeRemove(_ item: ActivityPlan) {
        if let index = self.firstIndex(where: { $0.id == item.id }) {
            // Item found, remove it
            self.remove(at: index)
        }
    }
}

extension CGSize {
    // Clamping the CGSize within certain width and height limits
    func clamped(to limits: CGSize) -> CGSize {
        let clampedWidth = max(min(self.width, limits.width), 0) // Ensuring width is not negative
        let clampedHeight = max(min(self.height, limits.height), 0) // Ensuring height is not negative
        return CGSize(width: clampedWidth, height: clampedHeight)
    }
    
    // Adding to the width and height
    func add(width deltaWidth: CGFloat, height deltaHeight: CGFloat) -> CGSize {
        return CGSize(width: self.width + deltaWidth, height: self.height + deltaHeight)
    }
    
    // Subtracting from the width and height
    func subtract(width deltaWidth: CGFloat, height deltaHeight: CGFloat) -> CGSize {
        return CGSize(width: self.width - deltaWidth, height: self.height - deltaHeight)
    }

    // Increase width
    func wider(by deltaWidth: CGFloat) -> CGSize {
        return CGSize(width: self.width + deltaWidth, height: self.height)
    }
    func right(by deltaWidth: CGFloat) -> CGSize {
        return CGSize(width: self.width + deltaWidth, height: self.height)
    }

    // Increase height
    func taller(by deltaHeight: CGFloat) -> CGSize {
        return CGSize(width: self.width, height: self.height + deltaHeight)
    }
    func up(by deltaHeight: CGFloat) -> CGSize {
        return CGSize(width: self.width, height: self.height + deltaHeight)
    }

    // Decrease width
    func narrower(by deltaWidth: CGFloat) -> CGSize {
        return CGSize(width: self.width - deltaWidth, height: self.height)
    }
    func left(by deltaWidth: CGFloat) -> CGSize {
        return CGSize(width: self.width - deltaWidth, height: self.height)
    }

    // Decrease height
    func shorter(by deltaHeight: CGFloat) -> CGSize {
        return CGSize(width: self.width, height: self.height - deltaHeight)
    }
    func down(by deltaHeight: CGFloat) -> CGSize {
        return CGSize(width: self.width, height: self.height - deltaHeight)
    }
}
extension CGFloat {
    func bounded(byMin minValue: CGFloat, andMax maxValue: CGFloat) -> CGFloat {
        return Swift.max(Swift.min(self, maxValue), minValue)
    }
}

extension CGPoint {
    
    func toCGSize() -> CGSize {
        return CGSize(width: self.x, height: self.y)
    }
    
    func clamped(to rect: CGRect) -> CGPoint {
        let clampedX = max(min(self.x, rect.maxX), rect.minX)
        let clampedY = max(min(self.y, rect.maxY), rect.minY)
        return CGPoint(x: clampedX, y: clampedY)
    }
    
    func add(x deltaX: CGFloat, y deltaY: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + deltaX, y: self.y + deltaY)
    }
    func subtract(x deltaX: CGFloat, y deltaY: CGFloat) -> CGPoint {
        return CGPoint(x: self.x - deltaX, y: self.y - deltaY)
    }
    
    func up(y deltaY: CGFloat) -> CGPoint {
        return CGPoint(x: self.x, y: self.y - deltaY)
    }
    func down(y deltaY: CGFloat) -> CGPoint {
        return CGPoint(x: self.x, y: self.y + deltaY)
    }
    
    func left(x deltaX: CGFloat) -> CGPoint {
        return CGPoint(x: self.x - deltaX, y: self.y)
    }
    func right(x deltaX: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + deltaX, y: self.y)
    }
}


extension DispatchQueue {
    static func executeAfter(seconds: TimeInterval, on queue: DispatchQueue = .main, action: @escaping () -> Void) {
        queue.asyncAfter(deadline: .now() + seconds, execute: action)
    }
}


extension Double {
    func bound(to range: ClosedRange<Double>) -> Double {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

