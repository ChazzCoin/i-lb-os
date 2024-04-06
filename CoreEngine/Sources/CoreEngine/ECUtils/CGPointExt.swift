//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/5/24.
//

import Foundation


public extension CGPoint {
    
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
