//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/8/24.
//

import Foundation
import SwiftUI

// Child (SubType)
public class ShapeToolProvider : ManagedToolProvider {
    
    public static var type: String = ManagedViewFactory.shape
    public var subType: String = ""
    public var sport: String = ""
    init(subType: String, sport: String) {
        self.subType = subType
        self.sport = sport
    }
    
    public static let line_straight: String = "line_straight"
    public static let line_dotted: String = "line_dotted"
    public static let line_curved: String = "line_curved"
    
    public static let circle: String = "circle"
    public static let square: String = "square"
    public static let triangle: String = "triangle"
    
    public func view(viewId: String, activityId: String) -> AnyView {
        switch subType {
            case ShapeToolProvider.line_straight: return AnyView(LineDrawingManaged(viewId: viewId, activityId: activityId))
            case ShapeToolProvider.line_dotted: return AnyView(LineDrawingManaged(viewId: viewId, activityId: activityId))
            case ShapeToolProvider.line_curved: return AnyView(CurvedLineDrawingManaged(viewId: viewId, activityId: activityId))
            default: return AnyView(EmptyView())
        }
    }
    
    public static var allCases: [String] = []
}

