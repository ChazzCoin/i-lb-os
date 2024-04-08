//
//  SoccerToolProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/12/23.
//

import Foundation
import SwiftUI

// AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: temp))

public enum SoccerToolProvider: IconProvider {
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

    public var tool: Tool {
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
    
    public func getView(viewId: String, activityId: String) -> AnyView {
        switch self {
            case .playerDummy: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_dummy"))
            case .playerJersey: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_dummy"))
            case .steps: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_dummy"))
            case .playerWalking: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_dummy"))
            case .playerRunning: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_dummy"))
            case .goal: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_dummy"))
            case .flagPole: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_dummy"))
            case .tallCone: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_dummy"))
            case .shortCone: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_dummy"))
            case .ladder: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_dummy"))
            case .soccerBall: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_dummy"))
            case .curvedLine: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_dummy"))
            case .dottedLine: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_dummy"))
        }
    }

    public static let allCases = [
        playerDummy, playerJersey, steps, playerWalking, playerRunning,
        goal, flagPole, tallCone, shortCone, ladder, soccerBall,
        curvedLine, dottedLine
    ]

    public static let sport = "Soccer"

    public static func parseByTitle(title: String) -> SoccerToolProvider? {
        return allCases.first { $0.tool.title.lowercased() == title.lowercased() }
    }
}


public struct SoccerToolsView: View {
    public let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)
    public let soccerTools = SoccerToolProvider.allCases

    public var body: some View {
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

public struct ToolButtonIcon: View {
    public var icon: IconProvider // Assuming IconProvider conforms to SwiftUI's View

    @State public var isLocked = false
    
    public init(icon: IconProvider, isLocked: Bool = false) {
        self.icon = icon
        self.isLocked = isLocked
    }

    public var body: some View {
        Image(icon.tool.image)
            .resizable()
            .frame(width: 40, height: 40)
            .onDrag {
                return NSItemProvider(object: icon.tool.title as NSString)
            }
            .onTapAnimation {
                print("CodiChannel SendTopic: \(icon.tool.title)")
                CodiChannel.TOOL_ON_CREATE.send(value: icon.tool.title)
            }
            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
    }
}


public struct ToolButtonSettingsIcon: View {
    public var icon: IconProvider // Assuming IconProvider conforms to SwiftUI's View

    @State public var isLocked = false
    
    public init(icon: IconProvider, isLocked: Bool = false) {
        self.icon = icon
        self.isLocked = isLocked
    }

    public var body: some View {
        Image(icon.tool.image)
            .resizable()
            .frame(width: 100, height: 100)
            .onTapAnimation {
                print("CodiChannel SendTopic: \(icon.tool.title)")
            }
            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
    }
}
