//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/19/24.
//

import Foundation
import SwiftUI


/*
 
    -> Everything is routed to a View based on three categories..
        1. Genre -> ex: Soccer, NavStack, Global ...
        2. Type -> "basic", "premium", "shape", "social" ... Directs the category and 'level'
        3. SubType -> The Final View itself. AnyView() //todo: make this generic viewbuilder.
 
    EX:
        1. Genre.soccer -> 2. Views.Types.basic -> 3. Views.SubTypes.player_jersey
 
 */

// MARK: ViewEngine Builder
public struct VEGenreRouter: VEGenreConfig {
    
    public var type: any VESubTypeConfig
    public typealias C = AnyView
    
    
    public static func configure(with genre: CoreName.ViewEngine.Genre, in type: VEngine.Types, and subtype: String) -> AnyView {
        switch genre {
            case VEngine.Genre.basic_tool:
                return AnyView(EmptyView())
            default:
                return AnyView(EmptyView())
        }
    }
    
}



// Example Output View

//public struct PlayerJerseyView: View, VESubtypeConfig {
//    public var body: some View {
//        Text("Player Jersey")
//        // Customize the view as needed
//    }
//}



