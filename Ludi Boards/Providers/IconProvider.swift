//
//  IconProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/7/24.
//

import Foundation

enum SolIcon {
    case save
    case delete
    case load
    case share
    case add
    
    
    var icon: String {
        switch self {
            case .save: return "square.and.arrow.down"
            case .delete: return "trash"
            case .load: return "arrow.down.doc"
            case .share: return "square.and.arrow.up"
            case .add: return "plus.circle"
        }
    }
    
    var title: String {
        switch self {
            case .save: return "Save"
            case .delete: return "Delete"
            case .load: return "Load"
            case .share: return "Share"
            case .add: return "Add"
            default: return ""
        }
    }
    
    var confirmMessage: String {
        switch self {
            case .save: return "Are you sure you want to save this?"
            case .delete: return "Are you sure you want to delete this?"
            case .load: return "Are you sure you want to load this?"
            case .share: return "Are you sure you want to share this?"
            default: return ""
        }
    }
}
