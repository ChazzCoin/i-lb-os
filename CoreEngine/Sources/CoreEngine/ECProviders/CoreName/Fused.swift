//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/17/24.
//

import Foundation


public extension CoreName {
    
    class Fused {
        
        enum QueueType : String, CaseIterable {
            case delete = "delete"
            case update = "update"
            case cache = "cache"
            public var name: String { rawValue }
        }
        enum OperationType : String, CaseIterable {
            case delete = "delete"
            case update = "update"
            public var name: String { rawValue }
        }
        
    }
    
    
}
