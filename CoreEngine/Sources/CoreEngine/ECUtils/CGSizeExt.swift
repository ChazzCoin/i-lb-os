//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/5/24.
//

import Foundation


public extension CGSize {
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
