//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/17/24.
//

import Foundation



public extension CoreName {
    
    
    enum BoardImage: String, CaseIterable {
        case soccerOne = "soccer_field_two"
        case soccerTwo = "soccer_two"
        case basketballOne = "basketball_one"
        case basketballTwo = "basketball_two"
        case basketballThree = "basketball_three"
        case baseballOne = "baseball_one"
        case bracketOne = "bracket_one"
        case poolOne = "pool_table"
        public var name: String { rawValue }
    }
    
    enum ManagedTool: String, CaseIterable {
        case canvas = "canvas"
        case basic = "basic"
        case shape = "shape"
        public var name: String { rawValue }
        
        public enum Shape: String, CaseIterable {
            case lineStraight = "line_straight"
            case lineDotted = "line_dotted"
            case lineCurved = "line_curved"
            case circle = "circle"
            case square = "square"
            case triangle = "triangle"
            public var name: String { rawValue }
        }
        
        public enum Sport: String, CaseIterable {
            case soccer = "soccer"
            public var name: String { rawValue }
            
            public enum SoccerIcon: String, CaseIterable {
                case playerDummy = "playerDummy"
                case playerJersey = "playerJersey"
                case steps = "steps"
                case playerWalking = "playerWalking"
                case playerRunning = "playerRunning"
                case goal = "goal"
                case flagPole = "flagPole"
                case tallCone = "tallCone"
                case shortCone = "shortCone"
                case ladder = "ladder"
                case soccerBall = "soccerBall"
                case curvedLine = "curvedLine"
                case dottedLine = "dottedLine"
                public var name: String { rawValue }
            }
        }
    }
    
    
}
