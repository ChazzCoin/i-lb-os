//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/8/24.
//

import Foundation



public extension Array where Element: ManagedView {
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
