//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/17/24.
//

import Foundation


public extension CoreName {
    
    class Status {
        
        enum Room: String, CaseIterable {
            case inRoom = "inRoom"
            case outOfRoom = "outOfRoom"
            case inactive = "inactive"
            case waitingApproval = "waitingApproval"
            public var name: String { rawValue }
        }

        enum Share: String, CaseIterable {
            case pending = "pending"
            case active = "active"
            case inactive = "inactive"
            public var name: String { rawValue }
        }

        enum Roster: String, CaseIterable {
            case pending = "pending"
            case pendingDocuments = "pendingDocuments"
            case active = "active"
            case inactive = "inactive"
            case suspended = "suspended"
            public var name: String { rawValue }
        }

    }
    
}
