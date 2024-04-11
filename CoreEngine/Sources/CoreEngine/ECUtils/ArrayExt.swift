//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/5/24.
//

import Foundation


public extension Array where Element == CoreUser {
    mutating func safeAppend(_ newUser: CoreUser) {
        // Check if the array already contains an element with the same id as newUser
        if !self.contains(where: { $0.id == newUser.id }) {
            self.append(newUser)
        }
    }
}

public extension Array where Element: Equatable {
    
    mutating func removeDuplicates() {
        self = self.reduce(into: []) { (result, element) in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
    
}
