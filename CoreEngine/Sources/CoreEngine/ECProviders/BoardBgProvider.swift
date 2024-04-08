//
//  BoardBgProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation

public enum BoardBgProvider: CoreIcon {
    case soccerOne
    case soccerTwo
    case basketballOne
    case basketballTwo
    case basketballThree
    case baseballOne
    case bracketOne
    case poolOne

    public var tool: Tool {
        switch self {
            case .soccerOne:
                return Tool(title: "Soccer 1", image: "soccer_field_two", authLevel: 0, color: .black)
            case .soccerTwo:
                return Tool(title: "Soccer 2", image: "soccer_two", authLevel: 0, color: .black)
            case .basketballOne:
                return Tool(title: "Basketball 1", image: "basketball_one", authLevel: 0, color: .black)
            case .basketballTwo:
                return Tool(title: "Basketball 2", image: "basketball_two", authLevel: 0, color: .black)
            case .basketballThree:
                return Tool(title: "Basketball 3", image: "basketball_three", authLevel: 0, color: .black)
            case .baseballOne:
                return Tool(title: "Baseball 1", image: "baseball_one", authLevel: 0, color: .black)
            case .bracketOne:
                return Tool(title: "Bracket 1", image: "bracket_one", authLevel: 0, color: .black)
            case .poolOne:
                return Tool(title: "Pool 1", image: "pool_table", authLevel: 0, color: .black)
        }
    }

    public static let allCases = [
        soccerOne, soccerTwo, basketballOne, basketballTwo, basketballThree,
        baseballOne, bracketOne, poolOne
    ]

    public static func parseByTitle(title: String) -> BoardBgProvider? {
        return allCases.first { $0.tool.title.lowercased() == title.lowercased() }
    }
}
