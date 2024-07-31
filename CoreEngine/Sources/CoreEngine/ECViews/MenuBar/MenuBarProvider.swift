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
    case home
    case info
    case toolbox
    case lock
    case session
    case activity
    case boardSettings
    case profile
    case chat
    case reset
    case trash
    case canvasGrid
    case navHome
    case buddyList
    case boardList
    case video
    case play
    case boardBackground
    case share
    case router
    case note
    case paint
    case image
    case webBrowser

    public var tool: Tool {
        switch self {
            // Main
            case .menuBar: return Tool(title: "Menubar", image: "line.horizontal.3", authLevel: 0, color: .white)
            case .home: return Tool(title: "Home", image: "house", authLevel: 0, color: .white)
            case .info: return Tool(title: "Tips", image: "info.circle", authLevel: 0, color: .white)
            case .toolbox: return Tool(title: "Toolbox", image: "rectangle.badge.plus", authLevel: 0, color: .white)
            case .lock: return Tool(title: "Lock", image: "lock", authLevel: 0, color: .white)
            
            // The Board/Sessions/Activities
            case .session: return Tool(title: "Session", image: "folder.badge.gearshape", authLevel: 0, color: .white)
            case .activity: return Tool(title: "Activity", image: "doc.badge.ellipsis", authLevel: 0, color: .white)
            case .boardSettings: return Tool(title: "Board Settings", image: "rectangle.on.rectangle.badge.gearshape", authLevel: 0, color: .white)
            case .boardList: return Tool(title: "Boards", image: "books.vertical", authLevel: 0, color: .white)
            
            // Social
            case .profile: return Tool(title: "Profile", image: "person.text.rectangle", authLevel: 2, color: .white)
            case .chat: return Tool(title: "Chat", image: "message", authLevel: 0, color: .white)
            case .note: return Tool(title: "Note", image: "note.text", authLevel: 2, color: .white)
            
            case .trash: return Tool(title: "Trash", image: "trash", authLevel: 99, color: .white)
            case .video: return Tool(title: "Recording", image: "video", authLevel: 0, color: .white)
            case .play: return Tool(title: "Play", image: "play", authLevel: 0, color: .white)
            
            case .boardBackground: return Tool(title: "BoardBackground", image: "photo.fill", authLevel: 2, color: .white)
            
            // Unused
            case .reset: return Tool(title: "Reset", image: "backward.fill", authLevel: 2, color: .white)
            case .canvasGrid: return Tool(title: "Grid", image: "square.grid.3x3", authLevel: 0, color: .white)
            case .navHome: return Tool(title: "NavPad", image: "location.north.line", authLevel: 0, color: .white)
            case .buddyList: return Tool(title: "Buddy List", image: "person.2", authLevel: 0, color: .white)
            case .share: return Tool(title: "Share", image: "square.and.arrow.up", authLevel: 2, color: .white)
            case .router: return Tool(title: "Connect", image: "network", authLevel: 99, color: .white)
            case .paint: return Tool(title: "Paint", image: "paintbrush", authLevel: 99, color: .white)
            case .image: return Tool(title: "Image", image: "photo.fill.on.rectangle", authLevel: 2, color: .white)
            case .webBrowser: return Tool(title: "Web Browser", image: "safari", authLevel: 99, color: .white)
        }
    }

    public static let allCases: [MenuBarProvider] = [
        .menuBar, .info, .toolbox, .lock, .video, .play, .canvasGrid, .navHome, .buddyList, .boardSettings, .boardList,
        .home, .session, .reset, .trash, .boardBackground, .activity,
        .profile, .share, .router, .note, .chat, .paint, .image, .webBrowser
    ]

    public static func parseByTitle(title: String) -> MenuBarProvider? {
        return allCases.first { $0.tool.title.lowercased() == title.lowercased() }
    }
}
