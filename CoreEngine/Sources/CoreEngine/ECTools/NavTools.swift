//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/15/24.
//

import Foundation
import SwiftUI

public class NavTools: NavWindowController {
    
//    public static var masterNavWindow: Nav/*StackWindow = VF.BuildEmptyStackWindow(callerId: WindowProvider.master.rawValue)*/
    
//    @ObservedObject public var navController: NavWindowController = NavWindowController()
    
//    @AppStorageList(key: "registeredWindows") public var registeredWindows: [String] = []
//    public func openChat() {
//        
//        NavTools.masterNavWindow.updateContentBuilder(contentBuilder: ChatView() )
//        if registeredWindows.contains(WindowProvider.chat.rawValue) {
//            BroadcastTools.send(.MENU_WINDOW_CONTROLLER, value: WindowController(windowId: WindowProvider.chat.rawValue, stateAction: .open))
//            return
//        }
//        self.addNewNavStackToPool(viewId: WindowProvider.chat.rawValue, viewBuilder: WindowProvider.chat.view)
//        self.baseNav(windowId: WindowProvider.chat.rawValue, .open)
//    }
    
    // MARK: -> Static Navigation Helpers
    public static let registeredWindows: [String]? = UserDefaults.standard.string(forKey: "registeredWindows")?.toList()
    public static func addRegisteredWindows(_ windowName: String) {
        if var temp = UserDefaults.standard.string(forKey: "registeredWindows")?.toList() {
            if temp.contains(windowName.lowercased()) { return }
            temp.append(windowName.lowercased())
            UserDefaults.standard.set(temp.toString(), forKey: "registeredWindows")
        }
    }
    
    public static func window(_ windowName: WindowProvider, action: WindowAction) {
        BroadcastTools.send(.MENU_WINDOW_CONTROLLER, value: WindowController(windowId: windowName.rawValue, stateAction: action))
    }
    public static func window(_ windowName: String, action: WindowAction) {
        BroadcastTools.send(.MENU_WINDOW_CONTROLLER, value: WindowController(windowId: windowName, stateAction: action))
    }
    public static func goTo(_ windowName: String) {
        BroadcastTools.send(.MENU_WINDOW_CONTROLLER, value: WindowController(windowId: windowName, stateAction: .open))
    }
    public static func goTo(_ windowName: WindowProvider) {
        BroadcastTools.send(.MENU_WINDOW_CONTROLLER, value: WindowController(windowId: windowName.rawValue, stateAction: .open))
    }
    public static func toggle(_ windowName: WindowProvider) {
        BroadcastTools.send(.MENU_WINDOW_CONTROLLER, value: WindowController(windowId: windowName.rawValue, stateAction: .toggle))
    }
    public static func toggle(_ windowName: String) {
        BroadcastTools.send(.MENU_WINDOW_CONTROLLER, value: WindowController(windowId: windowName, stateAction: .toggle))
    }
    public static func open(_ windowName: String) {
        BroadcastTools.send(.MENU_WINDOW_CONTROLLER, value: WindowController(windowId: windowName, stateAction: .open))
    }
    public static func open(_ windowName: WindowProvider) {
        BroadcastTools.send(.MENU_WINDOW_CONTROLLER, value: WindowController(windowId: windowName.rawValue, stateAction: .open))
    }
    public static func close(_ windowName: String) {
        BroadcastTools.send(.MENU_WINDOW_CONTROLLER, value: WindowController(windowId: windowName, stateAction: .close))
    }
    public static func close(_ windowName: WindowProvider) {
        BroadcastTools.send(.MENU_WINDOW_CONTROLLER, value: WindowController(windowId: windowName.rawValue, stateAction: .close))
    }
    
}
