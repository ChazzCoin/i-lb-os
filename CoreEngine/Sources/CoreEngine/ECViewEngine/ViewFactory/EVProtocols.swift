//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/19/24.
//

import Foundation
import SwiftUI

// MARK: ViewEngine Base Level Protocols.
public protocol VEConfig {
    associatedtype C: View
    static func configure(with genre: VEngine.Genre, in type: VEngine.Types, and subtype: String) -> C
}
public protocol VEGenreConfig: VEConfig {
    var type: any VESubTypeConfig { get }
}
public protocol VETypeConfig {
    var subtype: any VESubTypeConfig { get }
}
public protocol VESubTypeConfig: View {}


public typealias VEngine = CoreName.ViewEngine

public extension CoreName {
    
    class ViewEngine {
        
        /*
            .basic_tool = simple icons inside an image.
            .shape_tool = Shape Views built by Path()
            .premium_tool = ..TO BE DEVELOPED..
             .canvas_view = NavStackController() -> to be modified for social canvas use.
             .social_view = ..TO BE DEVELOPED.. -> Child Views to put into NavStack or Generic DynaView.
             .nav_stack = NavStackController()
            
            .basic -> .soccer -> .player_jersey
         
            1. Sports Icons
            2. Morphable Shapes (Lines, Triangles, Squares...)
            3.
         */
        
        public enum Genre: String, CaseIterable {
            case basic_tool = "basic_tool"
            case shape_tool = "shape"
            case premium_tool = "premium_tool"
            case canvas_view = "canvas"
            case social_view = "social_view"
            case nav_stack = "nav_stack"
            public var name: String { rawValue }
            
            public class Routes {
                public static let basic_tools = Types.Routes.self
            }
        }
        
        public enum Types: String, CaseIterable {
            case soccer = "soccer"
            case football = "football"
            case basketball = "basketball"
            case baseball = "baseball"
            case iceHockey = "iceHockey"
            case golf = "golf"
            case tennis = "tennis"
            case billiards = "billiards"
            case signupProfile = "signup_profile"
            case chat = "chat"
            public var name: String { rawValue }
            
            public class Routes {
                public static let soccer = BasicSubTypes.Soccer.self
            }
        }
        
        public class BasicSubTypes {
            
            public enum Soccer: String, CaseIterable {
                case dummy = "tools_soccer_dummy"
                case jersey = "tools_soccer_jersey"
                case steps = "tools_soccer_steps"
                case walking = "tools_soccer_walking"
                case running = "tools_soccer_running"
                case goal = "tools_soccer_goal"
                case flagPole = "tools_soccer_flag"
                case tallCone = "tools_soccer_tall_cone"
                case shortCone = "tools_soccer_mat" // Check if this is correct as it seems like it should be shortCone
                case ladder = "tools_soccer_ladder"
                case soccerBall = "tools_soccer_soccer_ball"
                case curvedLine = "tools_soccer_curved_line"
                case dottedLine = "tools_soccer_dotted_line"
                public var name: String { rawValue }
            }
            
            // -> this is the icon name for the basic tool.
            enum SubTypeTemplate: String, CaseIterable {
                case jersey = "icon_name_goes_here"
                public var name: String { rawValue }
            }
        }
        
    }
    
}


public struct BasicToolView: View {
    
    public var subType: String
    
    public var body: some View {
        Image(subType)
            .resizable()
    }
}
