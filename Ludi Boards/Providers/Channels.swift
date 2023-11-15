//
//  Channels.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import Combine
//@State var cancellables = Set<AnyCancellable>()
enum CodiChannel {
    case general
    case central
    case message
    case broadcast
    case BOARD_ON_ID_CHANGE
    case MENU_TOGGLER
    case TOOL_ON_CREATE
    case TOOL_ON_DELETE
    case TOOL_SUBSCRIPTION
    case TOOL_ON_MENU_RETURN
    case TOOL_ATTRIBUTES
    case REALM_ON_CHANGE
    case REALM_ON_DELETE
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
            case .BOARD_ON_ID_CHANGE:
                return BoardOnIdChangeChannel.shared.subject
            case .MENU_TOGGLER:
                return MenuTogglerChangeChannel.shared.subject
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
class BoardOnIdChangeChannel {
    static let shared = BoardOnIdChangeChannel()
    let subject = PassthroughSubject<Any, Never>()
}
class MenuTogglerChangeChannel {
    static let shared = MenuTogglerChangeChannel()
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
