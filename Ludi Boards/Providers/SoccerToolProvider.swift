//
//  SoccerToolProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/12/23.
//

import Foundation
import SwiftUI

enum SoccerToolProvider: IconProvider {
    case playerDummy
    case playerJersey
    case steps
    case playerWalking
    case playerRunning
    case goal
    case flagPole
    case tallCone
    case shortCone
    case ladder
    case soccerBall
    case curvedLine
    case dottedLine

    var tool: Tool {
        switch self {
            case .playerDummy: return Tool(title: "Player Body", image: "tools_soccer_dummy", authLevel: 0, color: .black)
            case .playerJersey: return Tool(title: "Player Jersey", image: "tools_soccer_jersey", authLevel: 0, color: .black)
            case .steps: return Tool(title: "Steps", image: "tools_soccer_steps", authLevel: 0, color: .black)
            case .playerWalking: return Tool(title: "Player Walking", image: "tools_soccer_walking", authLevel: 0, color: .black)
            case .playerRunning: return Tool(title: "Player Running", image: "tools_soccer_running", authLevel: 0, color: .black)
            case .goal: return Tool(title: "Goal", image: "tools_soccer_goal", authLevel: 0, color: .black)
            case .flagPole: return Tool(title: "Flat Pole", image: "tools_soccer_flag", authLevel: 0, color: .black)
            case .tallCone: return Tool(title: "Tall Cone", image: "tools_soccer_tall_cone", authLevel: 0, color: .black)
            case .shortCone: return Tool(title: "Short Cone", image: "tools_soccer_mat", authLevel: 0, color: .black)
            case .ladder: return Tool(title: "Ladder", image: "tools_soccer_ladder", authLevel: 0, color: .black)
            case .soccerBall: return Tool(title: "Soccer Ball", image: "tools_soccer_soccer_ball", authLevel: 0, color: .black)
            case .curvedLine: return Tool(title: "Curved Line", image: "tools_soccer_curved_line", authLevel: 0, color: .black)
            case .dottedLine: return Tool(title: "Dotted Line", image: "tools_soccer_dotted_line", authLevel: 0, color: .black)
        }
    }

    static let allCases = [
        playerDummy, playerJersey, steps, playerWalking, playerRunning,
        goal, flagPole, tallCone, shortCone, ladder, soccerBall,
        curvedLine, dottedLine
    ]

    static let sport = "Soccer"

    static func parseByTitle(title: String) -> SoccerToolProvider? {
        return allCases.first { $0.tool.title.lowercased() == title.lowercased() }
    }
}


struct SoccerToolsView: View {
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)
    private let soccerTools = SoccerToolProvider.allCases

    var body: some View {
        // Grid
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(soccerTools, id: \.self) { tool in
                    ToolButtonIcon(icon: tool)
                }
            }
            .padding()
        }
    }
}

struct ToolButtonIcon: View {
    var icon: IconProvider // Assuming IconProvider conforms to SwiftUI's View

    @State private var isLocked = false

    var body: some View {
        Image(icon.tool.image)
            .resizable()
            .frame(width: 40, height: 40)
            .onTapAnimation {
                print("CodiChannel SendTopic: \(icon.tool.title)")
                CodiChannel.TOOL_ON_CREATE.send(value: icon.tool.title)
            }
            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
    }
}
