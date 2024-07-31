//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/8/24.
//

import Foundation
import SwiftUI

// Child (SubType)
public class ShapeToolProvider {
    
    public static var type: String = "shape"
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
    
    @ViewBuilder
    public func view(viewId: String, activityId: String) -> some View {
        switch subType {
            case ShapeToolProvider.line_straight: LineDrawingManaged(viewId: viewId, activityId: activityId)
            case ShapeToolProvider.line_dotted: LineDrawingManaged(viewId: viewId, activityId: activityId)
            case ShapeToolProvider.line_curved: CurvedLineDrawingManaged(viewId: viewId, activityId: activityId)
            case ShapeToolProvider.circle: EmptyView()
            case ShapeToolProvider.square: ShapeToolManaged(viewId: viewId, activityId: activityId, isQuad: true)
            case ShapeToolProvider.triangle: ShapeToolManaged(viewId: viewId, activityId: activityId, isTriple: true)
            default: EmptyView()
        }
    }
    
    public static var allCases: [String] = []
}

