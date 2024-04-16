//
//  ManagedWindows.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/28/23.
//

import Foundation
import SwiftUI
import Combine

/*
 
                :EXAMPLE USAGE:
    
     let caller = MenuBarProvider.chat.tool.title
 
     managedWindowsObject.addNewViewToPool(viewId: caller, viewBuilder: {
 
         AnyView(NavStackWindow(id: caller, viewBuilder: {
 
             ChatView()
 
         }))
 
     })
 
 if !self.managedWindowsObject.reload {
 
     ForEach(Array(managedWindowsObject.activeViews.keys), id: \.self) { key in
 
         managedWindowsObject.getView(withId: key)
             .viewBuilder()
             .zIndex(50.0)
             
     }
 
 }
 
 */


public typealias Nav = NavWindowController


public func goToWindow(callerId: String, _ action: WindowAction = .toggle) {
    BroadcastTools.send(.MENU_WINDOW_CONTROLLER, value: WindowController(windowId: callerId, stateAction: action))
//    CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: callerId, stateAction: action))
}


public enum NavStackSize: String, CaseIterable {
    case full = "fullscreen"
    case full_menu_bar = "fullscreen_menu_bar"
    case half = "half"
    case floatable_large = "floatable_large"
    case floatable_medium = "floatable_medium"
    case floatable_small = "floatable_small"
    
    public var height: Double {
        switch self {
            case .full: return UIScreen.main.bounds.height
            case .full_menu_bar: return UIScreen.main.bounds.height
            case .half: return UIScreen.main.bounds.height * 0.5
            case .floatable_large: return UIScreen.main.bounds.height * 0.6
            case .floatable_medium: return UIScreen.main.bounds.height * 0.5
            case .floatable_small: return UIScreen.main.bounds.height * 0.4
        }
    }
    
    public var width: Double {
        switch self {
            case .full: return UIScreen.main.bounds.width
            case .full_menu_bar: return UIScreen.main.bounds.width * 0.9
            case .half: return UIScreen.main.bounds.width * 0.5
            case .floatable_large: return UIScreen.main.bounds.width * 0.6
            case .floatable_medium: return UIScreen.main.bounds.width * 0.5
            case .floatable_small: return UIScreen.main.bounds.width * 0.4
        }
    }
}


public enum NavStackState: String, CaseIterable {
    case open = "open"
    case closed = "closed"

    
    @available(iOS 16.0, *)
    public var sidebar: NavigationSplitViewVisibility {
        switch self {
            case .open: return .doubleColumn
            case .closed: return .detailOnly
        }
    }
    
    public var main: Bool {
        switch self {
            case .open: return true
            case .closed: return false
        }
    }
    
}

public class ManagedViewWindow: Identifiable {
    
    @Published public var id: String
    public var mainBuilder: () -> AnyView
    public var sidebarBuilder: () -> AnyView
    @Published public var boardId: String = ""
    @Published public var title: String = "Core Window"
    @Published public var windowId: String = "Core Window"
    
    @Published public var windowLevel: WindowLevel = .closed
    @Published public var isMinimized: Bool = false
    @Published public var isFullScreen: Bool = true
    @Published public var isGlobalWindow: Bool = false
    
    public init<V: View, S: View>(id: String, mainBuilder: @escaping () -> V, sidebarBuilder: @escaping () -> S = {EmptyView()}) {
        self.id = id
        self.mainBuilder = { AnyView(mainBuilder()) }
        self.sidebarBuilder = { AnyView(sidebarBuilder()) }
    }
    
    @ViewBuilder
    public func getMainView() -> some View { mainBuilder() }
    @ViewBuilder
    public func getSidebarView() -> some View { sidebarBuilder() }

    public func toggleMinimized() { isMinimized = !isMinimized }
    public func toggleFullScreen() { isFullScreen = !isFullScreen }
}

public extension NavWindowController {
    
    // MARK: OPEN/CLOSE
    static func openNavStack(sideBar: WindowAction? = nil) { BroadcastTools.send(.NavStackMessage, value: NavStackMessage(navAction: .open, sidebarAction: sideBar)) }
//    static func closeNavStack() { BroadcastTools.send(.NavStackMessage, value: NavStackMessage(isOpen: .closed, sidebarIsOpen: .closed)) }
//    static func openNavStackSideBar() { BroadcastTools.send(.NavStackMessage, value: NavStackMessage(isOpen: .open, sidebarIsOpen: .open)) }
//    static func closeNavStackSideBar() { BroadcastTools.send(.NavStackMessage, value: NavStackMessage(isOpen: .open, sidebarIsOpen: .closed)) }
    
    // MARK: SIZE
}

public class NavWindowController: ObservableObject {
    
    @Published public var id: String = "master"
    
    @ObservedObject public var gps = GlobalPositioningSystem()
    @ObservedObject public var broadcaster: BroadcastTools = BroadcastTools()
    
    @Published public var activeView: ManagedViewWindow? = nil
    @Published public var viewPool: [String: ManagedViewWindow] = [:]
    @Published public var backStack: CoreQueue<String> = CoreQueue()
    
    @Published public var navSize: NavStackSize = .full_menu_bar
    @Published public var mainState: NavStackState = .closed
    @Published public var sidebarIsEnabled: Bool = false
    @Published public var sidebarState: NavStackState = .closed
    
    @Published public var isLocked = false
    @Published public var isFloatable: Bool = false
    
    @Published public var keyboardIsShowing = false
    @Published public var keyboardHeight = 0.0
    
    @Published public var masterResetNavWindow = false
      
    @Published public var offset = CGSize.zero
    @Published public var position = CGPoint(x: 0, y: 0)
    @Published public var originOffPos = CGPoint(x: 0, y: 0)
    @Published public var offPos = CGPoint(x: 0, y: 0)
    @GestureState public var dragOffset = CGSize.zero
    @Published public var isDragging = false
    
    @Published public var cancellables = Set<AnyCancellable>()
    
    @Published public var navStackCount = 0
    
    @ViewBuilder
    public func getNavStackView() -> some View {
        if self.mainState.main {
            NavStackWindow().environmentObject(self).onAppear() { print("updating nav stack...") }
        }
    }
    
    public init() {
        self.broadcaster = BroadcastTools()
        broadcaster.subscribeTo(.NavStackMessage, storeIn: &cancellables) { wc in
            if let navIntake = wc as? NavStackMessage {
                
                if navIntake.navId.lowercased() != self.id { return }
                print("NavStack Intake -> NAV TO: \(String(describing: navIntake.viewName))")
                
                if let io = navIntake.navAction {
                    switch io {
                        case .toggle:
                            if self.mainState == NavStackState.open {
                                self.mainState = NavStackState.closed
                            } else {
                                self.mainState = NavStackState.open
                            }
                        case .open: self.mainState = NavStackState.open
                        case .close: return self.mainState = NavStackState.closed
                        default: return
                    }
                }
                if let sio = navIntake.sidebarAction {
                    switch sio {
                        case .toggle:
                            if self.sidebarState == NavStackState.open {
                                self.sidebarState = NavStackState.closed
                            } else {
                                self.sidebarState = NavStackState.open
                            }
                        case .open: self.sidebarState = NavStackState.open
                        case .close: return self.sidebarState = NavStackState.closed
                        default: return
                    }
                }
                
                if let s = navIntake.size {
                    if self.navSize.rawValue != s.rawValue {
                        self.setSize(gps: self.gps, s)
                    }
                }
                if let nt = navIntake.viewName?.lowercased() {
                    
                    if let va = navIntake.viewAction {
                        switch va {
                            case .toggle:
                                if self.activeView?.id == nt {
                                    self.goBack()
                                } else {
                                    self.navTo(viewId: nt)
                                }
                            case .open: self.navTo(viewId: nt)
                            case .close: self.goBack()
                            default: return
                        }
                    }
                    
                    
                    
                }
            }
        }
        self.preLoadWithCoreViews()
    }
    
    public func setSize(gps: GlobalPositioningSystem, _ navSize: NavStackSize) {
        self.navSize = navSize
        position = gps.getCoordinate(for: .center, offsetX: self.navSize.width * 0.05)
        offset = CGSize.zero
        originOffPos = CGPoint(x: 0, y: 0)
        offPos = CGPoint(x: 0, y: 0)
    }
    
    public func toggleFloating(gps: GlobalPositioningSystem) {
        self.isFloatable.toggle()
        if self.isFloatable {
            self.isLocked = false
            setSize(gps: gps, .floatable_medium)
            return
        }
        self.isLocked = true
        setSize(gps: gps, .full_menu_bar)
    }
    
    public func masterResetTheWindow() {
        masterResetNavWindow = true
        masterResetNavWindow = false
    }
    
    public func preLoadWithCoreViews() {
        self.addView(
            callerId: MenuBarProvider.profile.tool.title,
            mainContent: { CoreSignUpView() },
            sideContent: { EmptyView() }
        )
    }
    
    // Function to add a view to the pool
    public func addView(window: ManagedViewWindow) {
       viewPool[window.id.lowercased()] = window
       if activeView == nil { setActiveViewByID(window.id.lowercased()) }
    }
    
    public func addView<Content: View, Side: View>(callerId: String, @ViewBuilder mainContent: @escaping () -> Content, @ViewBuilder sideContent: @escaping () -> Side) {
        let newManagedWindow = VF.BuildManagedHolder(
            callerId: callerId.lowercased(),
            mainContent: mainContent,
            sideContent: sideContent
        )
        viewPool[newManagedWindow.id.lowercased()] = newManagedWindow
        if activeView == nil { setActiveViewByID(newManagedWindow.id.lowercased()) }
    }

    // Function to make a view active by its ID
    public func setActiveViewByID(_ id: String) {
        guard let window = viewPool[id.lowercased()] else { return }
        activeView = window
        backStack.enqueue(id.lowercased())
    }

    // Get the currently active view
    public func getActiveView() -> ManagedViewWindow? {
        return activeView
    }
    
    // Function to navigate to a specific view by ID
    public func navTo(viewId: String) {
        guard let window = viewPool[viewId.lowercased()] else { return }
        activeView = window
        backStack.enqueue(viewId.lowercased())
    }

    // Function to go back to the previous view in the history
    public func goBack() {
        _ = backStack.dequeue() // Remove current view
        guard let previousViewId = backStack.peek() else { return }
        if let previousView = viewPool[previousViewId.lowercased()] {
            activeView = previousView
        }
    }
    
    public func baseNav(windowId: String, _ action: WindowAction) {
        guard let window = viewPool[windowId.lowercased()] else { return }
        switch action {
            case .toggle: window.toggleMinimized()
            case .open: setActiveViewByID(windowId.lowercased())
            case .close:
                window.windowLevel = .closed
                goBack() // Navigate back if a window is closed
            case .back: goBack()
            default: break
        }
    }
    
    public func resetNavStack(gps: GlobalPositioningSystem) {
        setSize(gps: gps, .full_menu_bar)
    }

    public func resetPosition(gps: GlobalPositioningSystem) {
        position = gps.getCoordinate(for: .center, offsetX: self.navSize.width * 0.05)
    }
    
    public func toggleWindowSize(gps: GlobalPositioningSystem) {
        if self.navSize != NavStackSize.full_menu_bar {
            setSize(gps: gps, .full_menu_bar)
        } else {
            setSize(gps: gps, .half)
        }
    }
    
    public func addToStack() {
        self.navStackCount = self.navStackCount + 1
    }
    public func removeFromStack() {
        self.navStackCount = self.navStackCount - 1
    }

    // TODO: I like this idea, but don't know if it can work really...
    @ViewBuilder
    public static func linkTo<Content: View>(viewId: String, @ViewBuilder viewBuilder: @escaping () -> Content) -> NavigationLink<EmptyView, Content> {
        NavigationLink(destination: { viewBuilder() } ) { EmptyView() }
    }
    // TODO: Make View Active by ID
    // TODO: Get Active View
    // TODO: Add ManagedViewWindow to pool with ID.
    // TODO: Make sure to add view IDs to the backstack
    // TODO: Create navTo() and goBack() functions

}

