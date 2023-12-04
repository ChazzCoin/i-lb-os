//
//  Channels.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import Combine
import SwiftUI

class WindowController {
    var windowId: String = ""
    var stateAction: String = "open" //close
    var viewId: String = ""
    
    init(windowId: String, stateAction: String, viewId: String="") {
        self.windowId = windowId
        self.stateAction = stateAction
        self.viewId = viewId
    }
}

class ViewAtts {
    var viewId: String = ""
    var size: Double? = nil
    var rotation: Double? = nil
    var color: Color? = nil
    var isDeleted: Bool = false
    var stateAction: String = "open" //close
    
    init(viewId: String, size: Double? = nil, rotation: Double? = nil, color: Color? = nil, isDeleted: Bool = false, stateAction: String="open") {
        self.viewId = viewId
        self.size = size
        self.rotation = rotation
        self.color = color
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
    case TOOL_ATTRIBUTES
    case REALM_ON_CHANGE
    case REALM_ON_DELETE
    case EMOJI_ON_CREATE
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
