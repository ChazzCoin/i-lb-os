//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/14/24.
//

import Foundation
import SwiftUI


public enum WindowProvider: String, CaseIterable {
    case master = "master"
    case home = "home"
    case signup = "signup"
    case chat = "chat"
    case profile = "profile"
    case dashboard = "dashboard"
    case settings = "settings"
    
    public var view: () -> AnyView {
        switch self {
            case .home: return VF.BuildView(Triangle())
            case .signup: return VF.BuildView(CoreSignUpView())
            case .chat: return VF.BuildView(ChatView())
            default: return VF.BuildView(EmptyView())
        }
    }
    
    public static func parseToWindow(windowId: String) -> WindowProvider? {
        for item in WindowProvider.allCases {
            if item.rawValue.lowercased() == windowId.lowercased() {
                return item
            }
        }
        return nil
    }
}

public enum WindowAction: String, CaseIterable {
    case close = "close"
    case open = "open"
    case toggle = "toggle"
    case back = "back"
    case remove = "remove"
    case toGlobal = "toGlobal"
    case toCanvas = "toCanvas"
}

public enum WindowLevel: String, CaseIterable {
    case closed = "closed"
    case main = "global"
    case sidebar = "canvas"
    case fullscreen = "fullscreen"
}
