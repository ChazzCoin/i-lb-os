//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/17/24.
//

import Foundation


public extension CoreName {
    
    
    class User {
        
        public enum Role: String, CaseIterable {
            case player = "player"
            case parent = "parent"
            case coach = "coach"
            case admin = "admin"
            case assistant = "assistant"
            case volunteer = "volunteer"
            case member = "member"
            case temp = "temp"
            public var name: String { rawValue }
        }

        public enum Auth: String, CaseIterable {
            case visitor = "visitor"
            case viewer = "viewer"
            case editor = "editor"
            case admin = "admin"
            case owner = "owner"
            public var name: String { rawValue }
        }
        
        public enum Action: String, CaseIterable {
            case save = "save"
            case delete = "delete"
            case load = "load"
            case share = "share"
            case add = "add"
            public var name: String { rawValue }
        }
    }
    

}
