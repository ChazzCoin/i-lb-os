//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/15/24.
//

import Foundation
import SwiftUI

// The public entry point for driving a NavStack from anywhere. Sends a
// NavStackMessage — which is what NavWindowController actually decodes.
// (The old version sent WindowController objects on this channel; every
// subscriber casts to NavStackMessage, so all calls were silent no-ops.)
public class NavTools: NavWindowController {

    private static func send(_ name: String, nav: WindowAction?, view: WindowAction?) {
        BroadcastTools.send(.NavStackMessage, value: NavStackMessage(navAction: nav, viewName: name, viewAction: view))
    }

    public static func window(_ windowName: WindowProvider, action: WindowAction) { send(windowName.rawValue, nav: action, view: action) }
    public static func window(_ windowName: String, action: WindowAction) { send(windowName, nav: action, view: action) }
    public static func goTo(_ windowName: String) { send(windowName, nav: .open, view: .open) }
    public static func goTo(_ windowName: WindowProvider) { send(windowName.rawValue, nav: .open, view: .open) }
    public static func toggle(_ windowName: WindowProvider) { send(windowName.rawValue, nav: .toggle, view: .toggle) }
    public static func toggle(_ windowName: String) { send(windowName, nav: .toggle, view: .toggle) }
    public static func open(_ windowName: String) { send(windowName, nav: .open, view: .open) }
    public static func open(_ windowName: WindowProvider) { send(windowName.rawValue, nav: .open, view: .open) }
    public static func close(_ windowName: String) { send(windowName, nav: nil, view: .close) }
    public static func close(_ windowName: WindowProvider) { send(windowName.rawValue, nav: nil, view: .close) }

}
