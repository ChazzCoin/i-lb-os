//
//  MenuBarProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import SwiftUI

struct Tool {
    let title: String
    let image: String // Using SwiftUI's Image type for image resources
    let authLevel: Int
    let color: Color
}

protocol IconProvider {
    var tool: Tool { get }
}

enum MenuBarProvider: IconProvider {
    case toolbox
    case lock
    case canvasGrid
    case navHome
    case buddyList
    case boardList
    case boardCreate
    case boardDetails
    case reset
    case trash
    case boardBackground
    case profile
    case share
    case router
    case note
    case chat
    case paint
    case image
    case webBrowser

    var tool: Tool {
        switch self {
            case .toolbox: return Tool(title: "Toolbox", image: "toolbox", authLevel: 0, color: .white)
            case .lock: return Tool(title: "Lock", image: "hand_point_up", authLevel: 0, color: .white)
            case .canvasGrid: return Tool(title: "Grid", image: "game_board", authLevel: 0, color: .white)
            case .navHome: return Tool(title: "NavPad", image: "arrows_up_down_left_right", authLevel: 0, color: .white)
            case .buddyList: return Tool(title: "Buddy List", image: "face_plus", authLevel: 0, color: .white)
            case .boardList: return Tool(title: "Boards", image: "square_list", authLevel: 0, color: .white)
            case .boardCreate: return Tool(title: "Create Board", image: "layer_plus", authLevel: 0, color: .white)
            case .boardDetails: return Tool(title: "Details Board", image: "square_sliders", authLevel: 0, color: .white)
            case .reset: return Tool(title: "Reset", image: "backward", authLevel: 2, color: .white)
            case .trash: return Tool(title: "Trash", image: "trash_can", authLevel: 99, color: .white)
            case .boardBackground: return Tool(title: "BoardBackground", image: "aperture", authLevel: 2, color: .white)
            case .profile: return Tool(title: "Profile", image: "circle_user", authLevel: 2, color: .white)
            case .share: return Tool(title: "Share", image: "hand_holding_medical", authLevel: 2, color: .white)
            case .router: return Tool(title: "Connect", image: "router", authLevel: 99, color: .white)
            case .note: return Tool(title: "Note", image: "note", authLevel: 2, color: .white)
            case .chat: return Tool(title: "Chat", image: "comments", authLevel: 0, color: .white)
            case .paint: return Tool(title: "Paint", image: "file", authLevel: 99, color: .white)
            case .image: return Tool(title: "Image", image: "camera", authLevel: 2, color: .white)
            case .webBrowser: return Tool(title: "Web Browser", image: "film", authLevel: 99, color: .white)
        }
    }

    static let allCases: [MenuBarProvider] = [
        .toolbox, .lock, .canvasGrid, .navHome, .buddyList, .boardList, 
        .boardCreate, .boardDetails, .reset, .trash, .boardBackground,
        .profile, .share, .router, .note, .chat, .paint, .image, .webBrowser
    ]

    static func parseByTitle(title: String) -> MenuBarProvider? {
        return allCases.first { $0.tool.title.lowercased() == title.lowercased() }
    }
}
