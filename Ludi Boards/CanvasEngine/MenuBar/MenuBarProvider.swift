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
            case .toolbox: return Tool(title: "Toolbox", image: "hammer.fill", authLevel: 0, color: .white)
            case .lock: return Tool(title: "Lock", image: "lock.fill", authLevel: 0, color: .white)
            case .canvasGrid: return Tool(title: "Grid", image: "square.grid.3x3.fill", authLevel: 0, color: .white)
            case .navHome: return Tool(title: "NavPad", image: "cursorarrow.rays", authLevel: 0, color: .white)
            case .buddyList: return Tool(title: "Buddy List", image: "person.2.fill", authLevel: 0, color: .white)
            case .boardList: return Tool(title: "Boards", image: "list.bullet.rectangle", authLevel: 0, color: .white)
            case .boardCreate: return Tool(title: "Create Board", image: "plus.square.fill", authLevel: 0, color: .white)
            case .boardDetails: return Tool(title: "Details Board", image: "slider.horizontal.3", authLevel: 0, color: .white)
            case .reset: return Tool(title: "Reset", image: "backward.fill", authLevel: 2, color: .white)
            case .trash: return Tool(title: "Trash", image: "trash.fill", authLevel: 99, color: .white)
            case .boardBackground: return Tool(title: "BoardBackground", image: "photo.fill", authLevel: 2, color: .white)
            case .profile: return Tool(title: "Profile", image: "person.crop.circle.fill", authLevel: 2, color: .white)
            case .share: return Tool(title: "Share", image: "square.and.arrow.up.fill", authLevel: 2, color: .white)
            case .router: return Tool(title: "Connect", image: "network", authLevel: 99, color: .white)
            case .note: return Tool(title: "Note", image: "note.text", authLevel: 2, color: .white)
            case .chat: return Tool(title: "Chat", image: "message.fill", authLevel: 0, color: .white)
            case .paint: return Tool(title: "Paint", image: "paintbrush.fill", authLevel: 99, color: .white)
            case .image: return Tool(title: "Image", image: "photo.fill.on.rectangle.fill", authLevel: 2, color: .white)
            case .webBrowser: return Tool(title: "Web Browser", image: "safari.fill", authLevel: 99, color: .white)
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
