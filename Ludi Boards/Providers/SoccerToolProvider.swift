//
//  SoccerToolProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/12/23.
//

import Foundation
import SwiftUI


struct SoccerTool {
    let title: String
    let image: Image // Using SwiftUI's Image type for image resources
    let authLevel: Int
    let color: Color
}

//// Define a protocol similar to IconProvider in Kotlin
//protocol IconProvider {
//    var soccerTool: SoccerTool { get }
//}


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

    // Define your images somewhere
    // ...

    var soccerTool: SoccerTool {
        switch self {
        case .playerDummy:
            return SoccerTool(title: "Player Body", image: Image("tool_football"), authLevel: 0, color: .black)
        // ... repeat for other cases
        case .playerJersey:
            return SoccerTool(title: "", image: Image(""), authLevel: 0, color: .black)
        case .steps:
            return SoccerTool(title: "", image: Image(""), authLevel: 0, color: .black)
        case .playerWalking:
            return SoccerTool(title: "", image: Image(""), authLevel: 0, color: .black)
        case .playerRunning:
            return SoccerTool(title: "", image: Image(""), authLevel: 0, color: .black)
        case .goal:
            return SoccerTool(title: "", image: Image(""), authLevel: 0, color: .black)
        case .flagPole:
            return SoccerTool(title: "", image: Image(""), authLevel: 0, color: .black)
        case .tallCone:
            return SoccerTool(title: "", image: Image(""), authLevel: 0, color: .black)
        case .shortCone:
            return SoccerTool(title: "", image: Image(""), authLevel: 0, color: .black)
        case .ladder:
            return SoccerTool(title: "", image: Image(""), authLevel: 0, color: .black)
        case .soccerBall:
            return SoccerTool(title: "", image: Image(""), authLevel: 0, color: .black)
        case .curvedLine:
            return SoccerTool(title: "", image: Image(""), authLevel: 0, color: .black)
        case .dottedLine:
            return SoccerTool(title: "", image: Image(""), authLevel: 0, color: .black)
        }
    }

    static let allCases = [
        playerDummy, playerJersey, steps, playerWalking, playerRunning,
        goal, flagPole, tallCone, shortCone, ladder, soccerBall,
        curvedLine, dottedLine
    ]

    static let sport = "Soccer"

    static func parseByTitle(title: String) -> SoccerToolProvider? {
        return allCases.first { $0.soccerTool.title.lowercased() == title.lowercased() }
    }
}
