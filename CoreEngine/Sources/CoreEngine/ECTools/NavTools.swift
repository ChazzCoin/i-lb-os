//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/15/24.
//

import Foundation
import SwiftUI

public class NavTools: NavWindowController {
    
    public static func window(_ windowName: WindowProvider, action: WindowAction) {
        BroadcastTools.send(.NavStackMessage, value: WindowController(windowId: windowName.rawValue, stateAction: action))
    }
    public static func window(_ windowName: String, action: WindowAction) {
        BroadcastTools.send(.NavStackMessage, value: WindowController(windowId: windowName, stateAction: action))
    }
    public static func goTo(_ windowName: String) {
        BroadcastTools.send(.NavStackMessage, value: WindowController(windowId: windowName, stateAction: .open))
    }
    public static func goTo(_ windowName: WindowProvider) {
        BroadcastTools.send(.NavStackMessage, value: WindowController(windowId: windowName.rawValue, stateAction: .open))
    }
    public static func toggle(_ windowName: WindowProvider) {
        BroadcastTools.send(.NavStackMessage, value: WindowController(windowId: windowName.rawValue, stateAction: .toggle))
    }
    public static func toggle(_ windowName: String) {
        BroadcastTools.send(.NavStackMessage, value: WindowController(windowId: windowName, stateAction: .toggle))
    }
    public static func open(_ windowName: String) {
        BroadcastTools.send(.NavStackMessage, value: WindowController(windowId: windowName, stateAction: .open))
    }
    public static func open(_ windowName: WindowProvider) {
        BroadcastTools.send(.NavStackMessage, value: WindowController(windowId: windowName.rawValue, stateAction: .open))
    }
    public static func close(_ windowName: String) {
        BroadcastTools.send(.NavStackMessage, value: WindowController(windowId: windowName, stateAction: .close))
    }
    public static func close(_ windowName: WindowProvider) {
        BroadcastTools.send(.NavStackMessage, value: WindowController(windowId: windowName.rawValue, stateAction: .close))
    }
    
}
