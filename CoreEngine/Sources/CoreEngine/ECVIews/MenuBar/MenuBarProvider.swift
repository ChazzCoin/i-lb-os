//
//  MenuBarProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import SwiftUI

public enum MenuBarProvider: CoreIcon {
    case menuBar
    case info
    case toolbox
    case lock
    case canvasGrid
    case navHome
    case buddyList
    case boardList
    case boardSettings
    case boardCreate
    case boardDetails
    case reset
    case trash
    case video
    case play
    case boardBackground
    case profile
    case share
    case router
    case note
    case chat
    case paint
    case image
    case webBrowser

    public var tool: Tool {
        switch self {
            // Main
            case .menuBar: return Tool(title: "Menubar", image: "line.horizontal.3", authLevel: 0, color: .white)
            case .info: return Tool(title: "Tips", image: "info.circle", authLevel: 0, color: .white)
            case .toolbox: return Tool(title: "Toolbox", image: "wrench", authLevel: 0, color: .white)
            case .lock: return Tool(title: "Lock", image: "lock.fill", authLevel: 0, color: .white)
            
            case .trash: return Tool(title: "Trash", image: "trash.fill", authLevel: 99, color: .white)
            case .video: return Tool(title: "Recording", image: "video", authLevel: 0, color: .white)
            case .play: return Tool(title: "Play", image: "play", authLevel: 0, color: .white)
            
            // Social
            case .profile: return Tool(title: "Profile", image: "person.crop.circle.fill", authLevel: 2, color: .white)
            case .chat: return Tool(title: "Chat", image: "message.fill", authLevel: 0, color: .white)
            case .note: return Tool(title: "Note", image: "note.text", authLevel: 2, color: .white)
            
            // The Board/Sessions/Activities
            case .boardSettings: return Tool(title: "Board Settings", image: "gearshape", authLevel: 0, color: .white)
            case .boardList: return Tool(title: "Boards", image: "books.vertical", authLevel: 0, color: .white)
            case .boardCreate: return Tool(title: "Create Board", image: "books.vertical", authLevel: 0, color: .white)
            case .boardDetails: return Tool(title: "Details Board", image: "note.text", authLevel: 0, color: .white)
            case .boardBackground: return Tool(title: "BoardBackground", image: "photo.fill", authLevel: 2, color: .white)
            
            // Unused
            case .reset: return Tool(title: "Reset", image: "backward.fill", authLevel: 2, color: .white)
            case .canvasGrid: return Tool(title: "Grid", image: "square.grid.3x3.fill", authLevel: 0, color: .white)
            case .navHome: return Tool(title: "NavPad", image: "location.north.line.fill", authLevel: 0, color: .white)
            case .buddyList: return Tool(title: "Buddy List", image: "person.2.fill", authLevel: 0, color: .white)
            case .share: return Tool(title: "Share", image: "square.and.arrow.up.fill", authLevel: 2, color: .white)
            case .router: return Tool(title: "Connect", image: "network", authLevel: 99, color: .white)
            case .paint: return Tool(title: "Paint", image: "paintbrush.fill", authLevel: 99, color: .white)
            case .image: return Tool(title: "Image", image: "photo.fill.on.rectangle.fill", authLevel: 2, color: .white)
            case .webBrowser: return Tool(title: "Web Browser", image: "safari.fill", authLevel: 99, color: .white)
        }
    }

    public static let allCases: [MenuBarProvider] = [
        .menuBar, .info, .toolbox, .lock, .video, .play, .canvasGrid, .navHome, .buddyList, .boardSettings, .boardList,
        .boardCreate, .boardDetails, .reset, .trash, .boardBackground,
        .profile, .share, .router, .note, .chat, .paint, .image, .webBrowser
    ]

    public static func parseByTitle(title: String) -> MenuBarProvider? {
        return allCases.first { $0.tool.title.lowercased() == title.lowercased() }
    }
}
