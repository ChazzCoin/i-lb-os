//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/8/24.
//

import Foundation
import SwiftUI


public struct VEBasicTypeConfig: VETypeConfig {
    public var subtype: any VESubTypeConfig
    public typealias C = AnyView
    
    
    public static func configure(with subtype: String) -> AnyView {
        switch subtype {
            case "player_jersey":
                return AnyView(EmptyView())
            default:
                return AnyView(EmptyView()) // Extend with other subtypes as necessary
        }
    }

}
