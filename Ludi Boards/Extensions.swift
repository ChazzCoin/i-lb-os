//
//  Extensions.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/27/23.
//

import Foundation
import CoreGraphics
import UIKit

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

