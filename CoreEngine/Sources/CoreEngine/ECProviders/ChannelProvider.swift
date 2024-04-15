//
//  Channels.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import Combine
import SwiftUI

public class NotificationController {
    public var message: String = ""
    public var icon: String = "door_open"

    public init(message: String, icon: String) {
        self.message = message
        self.icon = icon
    }
}

public class WindowController {
    public var windowId: String = ""
    public var stateAction: WindowAction = .toggle
    public var viewId: String = ""
    public var x: CGFloat? = nil
    public var y: CGFloat? = nil
    
    public init(windowId: String, stateAction: WindowAction = .toggle, viewId: String="", x: CGFloat?=nil, y: CGFloat?=nil) {
        self.windowId = windowId
        self.stateAction = stateAction
        self.viewId = viewId
        self.x = x
        self.y = y
    }
}

public class NavStackMessage {
    public var navId: String = "master"
    public var isOpen: NavStackState? = nil
    public var sidebarIsOpen: NavStackState? = nil
    public var size: NavStackSize? = nil
    public var navTo: String? = nil
    
    public init(
        navId: String = "master",
        isOpen: NavStackState? = nil,
        sidebarIsOpen: NavStackState? = nil,
        size: NavStackSize? = nil,
        navTo: String? = nil
    ) {
        self.navId = navId
        self.isOpen = isOpen
        self.sidebarIsOpen = sidebarIsOpen
        self.size = size
        self.navTo = navTo
    }
}


public class OnCreateTool {
    public var toolType: String = ""
    public var toolSubType: String = ""
    public var sport: String = ""
    public var viewId: String = ""
    public var activityId: String = ""
    
    public init(toolType: String, toolSubType: String, sport: String, viewId: String, activityId: String) {
        self.toolType = toolType
        self.toolSubType = toolSubType
        self.sport = sport
        self.viewId = viewId
        self.activityId = activityId
    }
}

public class ViewAtts {
    public var viewId: String = ""
    public var size: Double? = nil
    public var rotation: Double? = nil
    public var color: Color? = nil
    public var stroke: Double? = nil
    public var position: CGPoint? = nil
    public var headIsEnabled: Bool? = nil
    public var lineDash: CGFloat? = nil
    public var toolType: String? = nil
    public var level: Int = 0
    public var isLocked: Bool? = nil
    public var isDeleted: Bool = false
    public var stateAction: String = "open" //close
    
    public init(
        viewId: String,
        size: Double? = nil,
        rotation: Double? = nil,
        color: Color? = nil,
        stroke: Double? = nil,
        position: CGPoint? = nil,
        headIsEnabled: Bool? = nil,
        lineDash: CGFloat? = nil,
        toolType: String? = nil,
        level:Int=0,
        isLocked: Bool? = nil,
        isDeleted: Bool = false,
        stateAction: String="open"
    ){
        self.viewId = viewId
        self.size = size
        self.rotation = rotation
        self.color = color
        self.stroke = stroke
        self.position = position
        self.headIsEnabled = headIsEnabled
        self.lineDash = lineDash
        self.toolType = toolType
        self.level = level
        self.isLocked = isLocked
        self.isDeleted = isDeleted
        self.stateAction = stateAction
    }
}

public class ViewMenu {
    public var viewId: String = ""
    public var state: String = "close" // "open"
    
    public init(viewId: String, state: String) {
        self.viewId = viewId
        self.state = state
    }
}

public class ActivityChange {
    public var activityId: String? = nil
    public init(activityId: String) {
        self.activityId = activityId
    }
}

public class ViewFollowing {
    public var viewId: String = ""
    public var x: Double = 0.0
    public var y: Double = 0.0
    public var hasDropped = false
    
    public init(viewId: String, x:Double=0.0, y:Double=0.0, hasDropped:Bool=false) {
        self.viewId = viewId
        self.x = x
        self.y = y
        self.hasDropped = true
    }
    
    public func getPoint() -> CGPoint {
        return CGPoint(x: self.x, y: self.y)
    }
}


//@State var cancellables = Set<AnyCancellable>()
public enum CodiChannel {
    case general
    case central
    case message
    case broadcast
    case NavStackMessage
    case SESSION_ON_ID_CHANGE
    case ACTIVITY_ON_ID_CHANGE
    case MENU_TOGGLER
    case MENU_SETTINGS_TOGGLER
    case TOOL_SETTINGS_TOGGLER
    case MENU_WINDOW_TOGGLER
    case MENU_WINDOW_CONTROLLER
    case TOOL_ON_CREATE
    case TOOL_ON_DELETE
    case TOOL_SUBSCRIPTION
    case TOOL_ON_MENU_RETURN
    case TOOL_ON_FOLLOW
    case TOOL_ATTRIBUTES
    case REALM_ON_CHANGE
    case REALM_ON_DELETE
    case EMOJI_ON_CREATE
    case ON_LOG_IN_OUT
    case ON_NOTIFICATION
    
    // ... (other cases)

    public var subject: PassthroughSubject<Any, Never> {
        switch self {
            case .general:
                return GeneralChannel.shared.subject
            case .central:
                return CentralChannel.shared.subject
            case .message:
                return MessageChannel.shared.subject
            case .broadcast:
                return BroadcastChannel.shared.subject
            case .NavStackMessage:
                return NavStackToggleChannel.shared.subject
            case .SESSION_ON_ID_CHANGE:
                return SessionOnIdChangeChannel.shared.subject
            case .ACTIVITY_ON_ID_CHANGE:
                return BoardOnIdChangeChannel.shared.subject
            case .MENU_TOGGLER:
                return MenuTogglerChangeChannel.shared.subject
            case .MENU_WINDOW_TOGGLER:
                return MenuWindowTogglerChangeChannel.shared.subject
            case .MENU_WINDOW_CONTROLLER:
                return MenuWindowControllerChangeChannel.shared.subject
            case .TOOL_ON_CREATE:
                return ToolOnCreateChannel.shared.subject
            case .TOOL_ON_DELETE:
                return ToolOnCreateChannel.shared.subject
            case .TOOL_ON_FOLLOW:
                return ToolOnFollowChannel.shared.subject
            case .TOOL_SUBSCRIPTION:
                return ToolSubscriptionChannel.shared.subject
            case .TOOL_ON_MENU_RETURN:
                return ToolOnMenuReturnChannel.shared.subject
            case .TOOL_ATTRIBUTES:
                return ToolAttributesChannel.shared.subject
            case .REALM_ON_CHANGE:
                return RealmOnChangeChannel.shared.subject
            case .REALM_ON_DELETE:
                return RealmOnDeleteChannel.shared.subject
            case .EMOJI_ON_CREATE:
                return EmojiOnCreateChannel.shared.subject
            case .ON_LOG_IN_OUT:
                return OnLogInOutChannel.shared.subject
            case .ON_NOTIFICATION:
                return OnNotificationChannel.shared.subject
            case .MENU_SETTINGS_TOGGLER:
                return MenuSettingsToggleChannel.shared.subject
            case .TOOL_SETTINGS_TOGGLER:
                return ToolSettingsToggleChannel.shared.subject
        }
    }

    public func send(value: Any) { subject.send(value) }

    public func receive<S: Scheduler>(on scheduler: S, callback: @escaping (Any) -> Void) -> AnyCancellable {
        subject.receive(on: scheduler).sink(receiveValue: callback)
    }
}

public class NavStackToggleChannel {
    static let shared = NavStackToggleChannel()
    let subject = PassthroughSubject<Any, Never>()
}
// Example of a channel
public class GeneralChannel {
    static let shared = GeneralChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class CentralChannel {
    static let shared = CentralChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class MessageChannel {
    static let shared = MessageChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class BroadcastChannel {
    static let shared = BroadcastChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class SessionOnIdChangeChannel {
    static let shared = SessionOnIdChangeChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class BoardOnIdChangeChannel {
    static let shared = BoardOnIdChangeChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class MenuTogglerChangeChannel {
    static let shared = MenuTogglerChangeChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class MenuWindowControllerChangeChannel {
    static let shared = MenuWindowControllerChangeChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class MenuWindowTogglerChangeChannel {
    static let shared = MenuWindowTogglerChangeChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class ToolOnCreateChannel {
    static let shared = ToolOnCreateChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class ToolOnDeleteChannel {
    static let shared = ToolOnDeleteChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class ToolOnFollowChannel {
    static let shared = ToolOnFollowChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class ToolSubscriptionChannel {
    static let shared = ToolOnDeleteChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class ToolOnMenuReturnChannel {
    static let shared = ToolOnDeleteChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class ToolAttributesChannel {
    static let shared = ToolOnDeleteChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class RealmOnChangeChannel {
    static let shared = RealmOnChangeChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class RealmOnDeleteChannel {
    static let shared = RealmOnDeleteChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class EmojiOnCreateChannel {
    static let shared = EmojiOnCreateChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class OnLogInOutChannel {
    static let shared = OnLogInOutChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class OnNotificationChannel {
    static let shared = OnNotificationChannel()
    let subject = PassthroughSubject<Any, Never>()
}

public class MenuSettingsToggleChannel {
    static let shared = MenuSettingsToggleChannel()
    let subject = PassthroughSubject<Any, Never>()
}
public class ToolSettingsToggleChannel {
    static let shared = ToolSettingsToggleChannel()
    let subject = PassthroughSubject<Any, Never>()
}
