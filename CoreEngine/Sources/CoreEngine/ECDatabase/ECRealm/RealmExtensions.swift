//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/10/24.
//

import Foundation
import RealmSwift


extension List where Element: RealmCollectionValue {
    
    @discardableResult
    func pop() -> Element? {
        // Ensure there is an element to pop.
        guard !self.isEmpty else { return nil }
        
        // Get the last element.
        let lastElement = self.last
        
        // Perform the removal in a write transaction if the list is managed.
        if let realm = self.realm {
            try? realm.write {
                self.removeLast()
            }
        } else {
            // If the list is not managed, just remove the last element.
            self.removeLast()
        }
        
        // Return the popped element.
        return lastElement
    }
}


struct RealmListUtility {

    static func safeAdd(item: String, to list: List<String>) {
        if !list.contains(item) {
            // Item not found, add it
            list.append(item)
        }
    }
    
    static func safeRemove(item: String, from list: List<String>) {
        if let index = list.index(of: item) {
            // Item found, remove it
            list.remove(at: index)
        }
    }
}



public extension List {
    func safeAddString(_ item: Element) {
        guard let item = item as? String, let list = self as? List<String> else {
            print("safeAdd is only supported for List<String>")
            return
        }
        
        if !list.contains(item) {
            list.append(item)
        }
    }
    
    func safeRemoveString(_ item: Element) {
        guard let item = item as? String, let list = self as? List<String> else {
            print("safeRemove is only supported for List<String>")
            return
        }
        
        if let index = list.index(of: item) {
            list.remove(at: index)
        }
    }
}
