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
            case .toolbox: return Tool(title: "Toolbox", image: "toolbox", authLevel: 0, color: .black)
            case .lock: return Tool(title: "Lock", image: "hand_point_up", authLevel: 0, color: .black)
            case .canvasGrid: return Tool(title: "Grid", image: "game_board", authLevel: 0, color: .black)
            case .navHome: return Tool(title: "NavPad", image: "arrows_up_down_left_right", authLevel: 0, color: .black)
            case .boardList: return Tool(title: "Boards", image: "square_list", authLevel: 0, color: .black)
            case .boardCreate: return Tool(title: "Create Board", image: "layer_plus", authLevel: 0, color: .black)
            case .boardDetails: return Tool(title: "Details Board", image: "square_sliders", authLevel: 0, color: .black)
            case .reset: return Tool(title: "Reset", image: "backward", authLevel: 2, color: .black)
            case .trash: return Tool(title: "Trash", image: "trash_can", authLevel: 99, color: .black)
            case .boardBackground: return Tool(title: "BoardBackground", image: "aperture", authLevel: 2, color: .black)
            case .profile: return Tool(title: "Profile", image: "circle_user", authLevel: 2, color: .black)
            case .share: return Tool(title: "Share", image: "share_from_square", authLevel: 2, color: .black)
            case .router: return Tool(title: "Connect", image: "router", authLevel: 99, color: .black)
            case .note: return Tool(title: "Note", image: "note", authLevel: 2, color: .black)
            case .chat: return Tool(title: "Chat", image: "comments", authLevel: 0, color: .black)
            case .paint: return Tool(title: "Paint", image: "file", authLevel: 99, color: .black)
            case .image: return Tool(title: "Image", image: "camera", authLevel: 2, color: .black)
            case .webBrowser: return Tool(title: "Web Browser", image: "film", authLevel: 99, color: .black)
        }
    }

    static let allCases: [MenuBarProvider] = [
        .toolbox, .lock, .canvasGrid, .navHome, .boardList, 
        .boardCreate, .boardDetails, .reset, .trash, .boardBackground,
        .profile, .share, .router, .note, .chat, .paint, .image, .webBrowser
    ]

    static func parseByTitle(title: String) -> MenuBarProvider? {
        return allCases.first { $0.tool.title.lowercased() == title.lowercased() }
    }
}
