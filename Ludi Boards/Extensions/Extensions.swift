//
//  Extensions.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/27/23.
//

import Foundation
import CoreGraphics
import UIKit
import CoreEngine





//
//extension Array where Element: ManagedView {
//    func hasView(_ item: ManagedView) -> Bool {
//        if self.firstIndex(where: { $0.id == item.id }) != nil {
//            // Item found, remove it
//            return true
//        }
//        // Item not found, add it
//        return false
//    }
//    mutating func safeAddManagedView(_ item: ManagedView) {
//        if self.firstIndex(where: { $0.id == item.id }) != nil {
//            // Item found, remove it
//            return
//        }
//        // Item not found, add it
//        self.append(item as! Element)
//    }
//    
//    mutating func safeRemove(_ item: ManagedView) {
//        if let index = self.firstIndex(where: { $0.id == item.id }) {
//            // Item found, remove it
//            self.remove(at: index)
//        }
//    }
//    mutating func safeRemoveById(_ id: String) {
//        if let index = self.firstIndex(where: { $0.id == id }) {
//            // Item found, remove it
//            self.remove(at: index)
//        }
//    }
//}
//
extension Array where Element: CoreUser {
    mutating func safeAdd(_ item: CoreUser) {
        if self.firstIndex(where: { $0.id == item.id }) != nil {
            // Item found, remove it
            return
        }
        // Item not found, add it
        self.append(item as! Element)
    }
    
    mutating func safeRemove(_ item: CoreUser) {
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







