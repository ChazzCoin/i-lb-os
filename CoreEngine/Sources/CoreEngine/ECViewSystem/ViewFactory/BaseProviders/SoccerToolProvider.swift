//
//  SoccerToolProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/12/23.
//

import Foundation
import SwiftUI

// AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: temp))

/*
    The Model Base Tool Provider!
 */
public class SoccerToolProvider: ManagedToolProvider, CoreIcon, CoreTool {
    
    // Individual Tools
    public static let playerDummy: String = "playerDummy"
    public static let playerJersey: String = "playerJersey"
    public static let steps: String = "steps"
    public static let playerWalking: String = "playerWalking"
    public static let playerRunning: String = "playerRunning"
    public static let goal: String = "goal"
    public static let flagPole: String = "flagPole"
    public static let tallCone: String = "tallCone"
    public static let shortCone: String = "shortCone"
    public static let ladder: String = "ladder"
    public static let soccerBall: String = "soccerBall"
    public static let curvedLine: String = "curvedLine"
    public static let dottedLine: String = "dottedLine"
    
    public let sport: String = CoreName.Genre.soccer.name
    public let type = ManagedViewTools.basic
    public var subType: String = ""
    init(subType: String) {
        self.subType = subType
    }

    public var managedTool: ManagedTool {
        switch subType {
            case SoccerToolProvider.playerDummy: return ManagedTool(title: "Player Body", image: "tools_soccer_dummy", type: type, subType: subType, sport: sport)
            case SoccerToolProvider.playerJersey: return ManagedTool(title: "Player Jersey", image: "tools_soccer_jersey", type: type, subType: subType, sport: sport)
            case SoccerToolProvider.steps: return ManagedTool(title: "Steps", image: "tools_soccer_steps", type: type, subType: subType, sport: sport)
            case SoccerToolProvider.playerWalking: return ManagedTool(title: "Player Walking", image: "tools_soccer_walking", type: type, subType: subType, sport: sport)
            case SoccerToolProvider.playerRunning: return ManagedTool(title: "Player Running", image: "tools_soccer_running", type: type, subType: subType, sport: sport)
            case SoccerToolProvider.goal: return ManagedTool(title: "Goal", image: "tools_soccer_goal", type: type, subType: subType, sport: sport)
            case SoccerToolProvider.flagPole: return ManagedTool(title: "Flat Pole", image: "tools_soccer_flag", type: type, subType: subType, sport: sport)
            case SoccerToolProvider.tallCone: return ManagedTool(title: "Tall Cone", image: "tools_soccer_tall_cone", type: type, subType: subType, sport: sport)
            case SoccerToolProvider.shortCone: return ManagedTool(title: "Short Cone", image: "tools_soccer_mat", type: type, subType: subType, sport: sport)
            case SoccerToolProvider.ladder: return ManagedTool(title: "Ladder", image: "tools_soccer_ladder", type: type, subType: subType, sport: sport)
            case SoccerToolProvider.soccerBall: return ManagedTool(title: "Soccer Ball", image: "tools_soccer_soccer_ball", type: type, subType: subType, sport: sport)
            case SoccerToolProvider.curvedLine: return ManagedTool(title: "Curved Line", image: "tools_soccer_curved_line", type: type, subType: subType, sport: sport)
            case SoccerToolProvider.dottedLine: return ManagedTool(title: "Dotted Line", image: "tools_soccer_dotted_line", type: type, subType: subType, sport: sport)
            default: return ManagedTool(title: "Player Body", image: "tools_soccer_dummy", type: type, subType: subType, sport: sport)
        }
    }
    public var tool: Tool {
        switch subType {
            case SoccerToolProvider.playerDummy: return Tool(title: "Player Body", image: "tools_soccer_dummy", authLevel: 0, color: .black)
            case SoccerToolProvider.playerJersey: return Tool(title: "Player Jersey", image: "tools_soccer_jersey", authLevel: 0, color: .black)
            case SoccerToolProvider.steps: return Tool(title: "Steps", image: "tools_soccer_steps", authLevel: 0, color: .black)
            case SoccerToolProvider.playerWalking: return Tool(title: "Player Walking", image: "tools_soccer_walking", authLevel: 0, color: .black)
            case SoccerToolProvider.playerRunning: return Tool(title: "Player Running", image: "tools_soccer_running", authLevel: 0, color: .black)
            case SoccerToolProvider.goal: return Tool(title: "Goal", image: "tools_soccer_goal", authLevel: 0, color: .black)
            case SoccerToolProvider.flagPole: return Tool(title: "Flat Pole", image: "tools_soccer_flag", authLevel: 0, color: .black)
            case SoccerToolProvider.tallCone: return Tool(title: "Tall Cone", image: "tools_soccer_tall_cone", authLevel: 0, color: .black)
            case SoccerToolProvider.shortCone: return Tool(title: "Short Cone", image: "tools_soccer_mat", authLevel: 0, color: .black)
            case SoccerToolProvider.ladder: return Tool(title: "Ladder", image: "tools_soccer_ladder", authLevel: 0, color: .black)
            case SoccerToolProvider.soccerBall: return Tool(title: "Soccer Ball", image: "tools_soccer_soccer_ball", authLevel: 0, color: .black)
            case SoccerToolProvider.curvedLine: return Tool(title: "Curved Line", image: "tools_soccer_curved_line", authLevel: 0, color: .black)
            case SoccerToolProvider.dottedLine: return Tool(title: "Dotted Line", image: "tools_soccer_dotted_line", authLevel: 0, color: .black)
            default: return Tool(title: "Player Body", image: "tools_soccer_dummy", authLevel: 0, color: .black)
        }
    }
//
    public func view(viewId: String, activityId: String) -> AnyView {
        switch subType {
            case SoccerToolProvider.playerDummy: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_dummy"))
            case SoccerToolProvider.playerJersey: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_jersey"))
            case SoccerToolProvider.steps: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_steps"))
            case SoccerToolProvider.playerWalking: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_walking"))
            case SoccerToolProvider.playerRunning: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_running"))
            case SoccerToolProvider.goal: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_goal"))
            case SoccerToolProvider.flagPole: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_flag"))
            case SoccerToolProvider.tallCone: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_tall_cone"))
            case SoccerToolProvider.shortCone: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_mat"))
            case SoccerToolProvider.ladder: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_ladder"))
            case SoccerToolProvider.soccerBall: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_soccer_ball"))
            case SoccerToolProvider.curvedLine: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_curved_line"))
            case SoccerToolProvider.dottedLine: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_dotted_line"))
            default: return AnyView(ManagedViewBasicTool(viewId: viewId, activityId: activityId, toolType: "tools_soccer_jersey"))
        }
    }

    public static var allCases = [
        playerDummy, playerJersey, steps, playerWalking, playerRunning,
        goal, flagPole, tallCone, shortCone, ladder, soccerBall,
        curvedLine, dottedLine
    ]

    

//    public static func parseByTitle(title: String) -> SoccerToolProvider? {
//        return allCases.first { $0.tool.title.lowercased() == title.lowercased() }
//    }
}

// Parent List of Soccer Icons
public struct SoccerToolsView: View {
    public let soccerTools = SoccerToolProvider.allCases
    public var body: some View {
        BorderedView(color: .AIMYellow) {
            ForEach(soccerTools, id: \.self) { tool in
                ToolButtonIcon(icon: SoccerToolProvider(subType: tool))
            }
        }
    }
}



public struct ToolButtonSettingsIcon: View {
    public var icon: CoreTool // Assuming IconProvider conforms to SwiftUI's View

    @State public var isLocked = false
    
    public init(icon: CoreTool, isLocked: Bool = false) {
        self.icon = icon
        self.isLocked = isLocked
    }

    public var body: some View {
        Image(icon.managedTool.image)
            .resizable()
            .frame(width: 100, height: 100)
            .onTapAnimation {
                print("CodiChannel SendTopic: \(icon.managedTool.title)")
            }
            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
    }
}
