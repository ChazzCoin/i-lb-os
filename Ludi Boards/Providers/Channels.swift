//
//  Channels.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import Combine
import SwiftUI

class NotificationController {
    var message: String = ""
    var icon: String = "door_open"

    init(message: String, icon: String) {
        self.message = message
        self.icon = icon
    }
}

class WindowController {
    var windowId: String = ""
    var stateAction: String = "open" //close
    var viewId: String = ""
    var x: CGFloat? = nil
    var y: CGFloat? = nil
    
    init(windowId: String, stateAction: String, viewId: String="", x: CGFloat?=nil, y: CGFloat?=nil) {
        self.windowId = windowId
        self.stateAction = stateAction
        self.viewId = viewId
        self.x = x
        self.y = y
    }
}

class ViewAtts {
    var viewId: String = ""
    var size: Double? = nil
    var rotation: Double? = nil
    var color: Color? = nil
    var stroke: Double? = nil
    var position: CGPoint? = nil
    var headIsEnabled: Bool? = nil
    var lineDash: CGFloat? = nil
    var toolType: String? = nil
    var level: Int = 0
    var isLocked: Bool? = nil
    var isDeleted: Bool = false
    var stateAction: String = "open" //close
    
    init(
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

class ViewMenu {
    var viewId: String = ""
    var state: String = "close" // "open"
    
    init(viewId: String, state: String) {
        self.viewId = viewId
        self.state = state
    }
}

class SessionChange {
    var sessionId: String? = nil
    var activityId: String? = nil
    
    init(sessionId: String?=nil, activityId: String?=nil) {
        self.sessionId = sessionId
        self.activityId = activityId
    }
}

class ViewFollowing {
    var viewId: String = ""
    var x: Double = 0.0
    var y: Double = 0.0
    var hasDropped = false
    
    init(viewId: String, x:Double=0.0, y:Double=0.0, hasDropped:Bool=false) {
        self.viewId = viewId
        self.x = x
        self.y = y
        self.hasDropped = true
    }
    
    func getPoint() -> CGPoint {
        return CGPoint(x: self.x, y: self.y)
    }
}

//@State var cancellables = Set<AnyCancellable>()
enum CodiChannel {
    case general
    case central
    case message
    case broadcast
    case SESSION_ON_ID_CHANGE
    case ACTIVITY_ON_ID_CHANGE
    case MENU_TOGGLER
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

    private var subject: PassthroughSubject<Any, Never> {
        switch self {
            case .general:
                return GeneralChannel.shared.subject
            case .central:
                return CentralChannel.shared.subject
            case .message:
                return MessageChannel.shared.subject
            case .broadcast:
                return BroadcastChannel.shared.subject
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
        }
    }

    func send(value: Any) { subject.send(value) }

    func receive<S: Scheduler>(on scheduler: S, callback: @escaping (Any) -> Void) -> AnyCancellable {
        subject.receive(on: scheduler).sink(receiveValue: callback)
    }
}

// Example of a channel
class GeneralChannel {
    static let shared = GeneralChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class CentralChannel {
    static let shared = CentralChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class MessageChannel {
    static let shared = MessageChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class BroadcastChannel {
    static let shared = BroadcastChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class SessionOnIdChangeChannel {
    static let shared = SessionOnIdChangeChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class BoardOnIdChangeChannel {
    static let shared = BoardOnIdChangeChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class MenuTogglerChangeChannel {
    static let shared = MenuTogglerChangeChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class MenuWindowControllerChangeChannel {
    static let shared = MenuWindowControllerChangeChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class MenuWindowTogglerChangeChannel {
    static let shared = MenuWindowTogglerChangeChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class ToolOnCreateChannel {
    static let shared = ToolOnCreateChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class ToolOnDeleteChannel {
    static let shared = ToolOnDeleteChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class ToolOnFollowChannel {
    static let shared = ToolOnFollowChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class ToolSubscriptionChannel {
    static let shared = ToolOnDeleteChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class ToolOnMenuReturnChannel {
    static let shared = ToolOnDeleteChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class ToolAttributesChannel {
    static let shared = ToolOnDeleteChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class RealmOnChangeChannel {
    static let shared = RealmOnChangeChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class RealmOnDeleteChannel {
    static let shared = RealmOnDeleteChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class EmojiOnCreateChannel {
    static let shared = EmojiOnCreateChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class OnLogInOutChannel {
    static let shared = OnLogInOutChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class OnNotificationChannel {
    static let shared = OnNotificationChannel()
    let subject = PassthroughSubject<Any, Never>()
}
