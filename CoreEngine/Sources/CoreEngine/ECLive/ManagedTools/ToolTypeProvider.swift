//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/7/24.
//

import Foundation
import SwiftUI

public enum ToolLevels: Int, CaseIterable {
    case BASIC = 1
    case LINE = 11
    case SMART = 21
    case PREMIUM = 31
}

public struct Tool {
    public let title: String
    public let image: String
    public let authLevel: Int
    public let color: Color
}

public struct ManagedTool {
    public let title: String
    public let viewId: String
    public let activityId: Int
    public let view: AnyView
}

public protocol IconProvider {
    var tool: Tool { get }
}

public enum ToolTypeProvider : CaseIterable {
    case basic
    case line
    
    public var name: String {
        switch self {
            case .basic: return "basic"
            case .line: return "line"
            
        }
    }
    
}

public enum BasicToolProvider : CaseIterable {
    case basic
    case line
    
    public var name: String {
        switch self {
            case .basic: return "basic"
            case .line: return "line"
            
        }
    }
    
}
