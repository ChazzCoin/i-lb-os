//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/5/24.
//

import Foundation


public extension Array where Element: Equatable {
    
    mutating func removeDuplicates() {
        self = self.reduce(into: []) { (result, element) in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
    
}
