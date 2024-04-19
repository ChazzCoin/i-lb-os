//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/8/24.
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
    public let image: String
    public var type: String
    public var subType: String
    public var sport: String
    public var viewId: String?
    public var activityId: Int?
    public var view: AnyView?
}

public protocol ManagedToolProvider {
    static var allCases: [String] { get }
    var subType: String { get }
    func view(viewId: String, activityId: String) -> AnyView
}

public protocol CoreIcon {
    var tool: Tool { get }
}
public protocol CoreTool {
    var managedTool: ManagedTool { get }
}
