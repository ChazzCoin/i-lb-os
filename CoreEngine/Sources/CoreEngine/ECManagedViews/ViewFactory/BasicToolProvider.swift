//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/8/24.
//

import Foundation
import SwiftUI

// Child (SubType)
public class BasicToolProvider : ManagedToolProvider {
        
    public var type: String = "basic"
    public var subType: String = ""
    public var sport: String = ""
    init(subType: String, sport: String) {
        self.subType = subType
        self.sport = sport
    }
    
    public static let soccer: String = "soccer"
    public static let pool: String = "pool"
    
    public func view(viewId: String, activityId: String) -> AnyView {
        switch sport {
            case BasicToolProvider.soccer: return SoccerToolProvider(subType: subType).view(viewId: viewId, activityId: activityId)
            case BasicToolProvider.pool: return AnyView(EmptyView())
            default: return AnyView(EmptyView())
        }
    }
    
    public static var allCases: [String] = []
}
