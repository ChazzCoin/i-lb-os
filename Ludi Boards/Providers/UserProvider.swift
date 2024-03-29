//
//  IconProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/7/24.
//

import Foundation

enum UserRole {
    case player
    case parent
    case coach
    case admin
    case assistant
    case volunteer
    case temp
    
    var name: String {
        switch self {
            case .player: return "player"
            case .parent: return "parent"
            case .coach: return "coach"
            case .admin: return "admin"
            case .assistant: return "assistant"
            case .volunteer: return "volunteer"
            case .temp: return "temp"
        }
    }
    
}

enum UserAuth {
    case visitor
    case viewer
    case editor
    case admin
    case owner
    
    var name: String {
        switch self {
            case .visitor: return "visitor"
            case .viewer: return "viewer"
            case .editor: return "editor"
            case .admin: return "admin"
            case .owner: return "owner"
        }
    }
    
}


enum ShareStatus {
    case pending
    case active
    case inactive
    
    var name: String {
        switch self {
            case .pending: return "pending"
            case .active: return "active"
            case .inactive: return "inactive"
        }
    }
    
}
