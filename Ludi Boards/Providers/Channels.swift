//
//  Channels.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import Combine

enum CodiChannel {
    case general
    case central
    case message
    case broadcast
    case BOARD_ON_ID_CHANGE
    case MENU_TOGGLER
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
