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
            case .chat: return Tool(title: "Chat", image: "comments", authLevel: 2, color: .black)
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


struct MenuButtonIcon: View {
    var icon: IconProvider // Assuming IconProvider conforms to SwiftUI's View

    @State private var isLocked = false

    var body: some View {
        VStack {
            
            Image(icon.tool.image)
                .resizable()
                .frame(width: 35, height: 35)
                .onTapGesture {
                    print("CodiChannel SendTopic: \(icon.tool.title)")
                    CodiChannel.MENU_TOGGLER.send(value: icon.tool.title)
                }
                .foregroundColor(isLocked ? .red : Color.primary)
            Spacer().frame(height: 8)
        }
        .onAppear {
            // Update isLocked state based on your conditions
        }
    }
}

struct MenuBarWindow<Content>: View where Content: View {
    let items: [() -> Content]
    
    @State private var offset = CGSize.zero
    @State private var isEnabled = true // Replace with your actual condition
    @State private var overrideColor = false // Replace with your actual condition
    @State private var color: Color = .white // Replace with your actual color
    
    @State private var position = CGPoint(x: 100, y: 100)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false

    var body: some View {
        VStack(spacing: 8) {
            Spacer().frame(height: 24)
            ForEach(0..<items.count, id: \.self) { index in
                self.items[index]()
            }
            Spacer().frame(height: 16)
        }
        .frame(maxWidth: 50, maxHeight: 50 * Double(items.count))
        .padding(8)
        .shadow(radius: 15)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .offset(x: offset.width, y: offset.height)
        .position(x: position.x + (isDragging ? dragOffset.width : 0),
                  y: position.y + (isDragging ? dragOffset.height : 0))
        .gesture(
            DragGesture()
                .updating($dragOffset, body: { (value, state, transaction) in
                    state = value.translation
                })
                .onChanged { _ in
                    self.isDragging = true
                }
                .onEnded { value in
                    // Update the final position when the drag ends
                    self.position = CGPoint(x: self.position.x + value.translation.width, y: self.position.y + value.translation.height)
                    self.isDragging = false
                }
        )
    }
}
