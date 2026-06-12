//
//  ManagedWindows.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/28/23.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift

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
    
    // Fraction of the container each preset occupies. Sizing should be
    // derived from the actual container (window) size, not UIScreen —
    // UIScreen.main.bounds is wrong under Split View / Stage Manager
    // and stale across rotation. Prefer width(in:)/height(in:).
    public var widthFactor: Double {
        switch self {
            case .full: return 1.0
            case .full_menu_bar: return 0.9
            case .half: return 0.5
            case .floatable_large: return 0.6
            case .floatable_medium: return 0.5
            case .floatable_small: return 0.4
        }
    }

    public var heightFactor: Double {
        switch self {
            case .full: return 1.0
            case .full_menu_bar: return 1.0
            case .half: return 0.5
            case .floatable_large: return 0.6
            case .floatable_medium: return 0.5
            case .floatable_small: return 0.4
        }
    }

    public func width(in container: CGSize) -> Double { container.width * widthFactor }
    public func height(in container: CGSize) -> Double { container.height * heightFactor }

    // Screen-relative fallbacks, kept for default-init only. Same values
    // as before. Runtime paths use the container-aware variants above.
    public var width: Double { UIScreen.main.bounds.width * widthFactor }
    public var height: Double { UIScreen.main.bounds.height * heightFactor }
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

public class ManagedViewRegistry: ObservableObject {
    
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
    public func getMainView() -> some View { 
        mainBuilder().enableManagedViewBasic(viewId: self.id)
    }
    @ViewBuilder
    public func getSidebarView() -> some View { 
        sidebarBuilder()
    }

    public func toggleMinimized() { isMinimized = !isMinimized }
    public func toggleFullScreen() { isFullScreen = !isFullScreen }
}

public typealias CVHolder = CoreViewHolder<AnyView,AnyView>

public extension NavWindowController {
    // MARK: OPEN/CLOSE
    static func openNavStack(sideBar: WindowAction? = nil) { BroadcastTools.send(.NavStackMessage, value: NavStackMessage(navAction: .open, sidebarAction: sideBar)) }
    // MARK: SIZE
}

public class NavWindowController: ObservableObject {

    @Published public var id: String = "master"

    // Plain references: SwiftUI property wrappers (@ObservedObject,
    // @StateRealmObject, @GestureState) are inert inside an
    // ObservableObject — they only function inside a View. Keeping
    // them here gave a false sense of observation and led to
    // undefined _dyna reassignment.
    public var gps = GlobalPositioningSystem(CoreNameSpace.global)
    public var broadcaster: BroadcastTools = BroadcastTools()

    @Published public var activeView: ManagedViewHolder? = nil
    @Published public var viewPool: [WindowID: ManagedViewHolder] = [:]
    @Published public var backStack: CoreQueue<WindowID> = CoreQueue()

    @Published public var navSize: NavStackSize = .full
    @Published public var mainState: NavStackState = .closed
    @Published public var sidebarIsEnabled: Bool = false
    @Published public var sidebarState: NavStackState = .closed

    @Published public var isLocked = true
    @Published public var isFloatable: Bool = true

    @Published public var keyboardIsShowing = false
    @Published public var keyboardHeight = 0.0

    @Published public var masterResetNavWindow = false

    @Published public var width = NavStackSize.full_menu_bar.width
    @Published public var height = NavStackSize.full_menu_bar.height

    @Published public var offset = CGSize.zero
    @Published public var position = CGPoint(x: 0, y: 0)
    @Published public var originOffPos = CGPoint(x: 0, y: 0)
    @Published public var offPos = CGPoint(x: 0, y: 0)

    public var realmInstance: Realm = newRealm()
    public var cancellables = Set<AnyCancellable>()

    @Published public var navStackCount = 0
    
    @ViewBuilder
    public func getNavStackView() -> some View {
        if self.mainState.main {
            NavStackWindow()
//                .enableDynaView(viewId: self.id)
                .environmentObject(self)
                .onAppear() {
                    print("updating nav stack...")
                }
        }
    }
    
    public init() {
        self.broadcaster = BroadcastTools()
        broadcaster.subscribeTo(.NavStackMessage, storeIn: &cancellables) { wc in
            guard let navIntake = wc as? NavStackMessage else { return }
            self.handleNavStackMessage(navIntake)
        }
        self.preLoadWithCoreViews()
        self.loadDynaView()
    }

    // Routes an incoming message. Shell-level intents (open/close the
    // window, change size, toggle the sidebar) are handled regardless
    // of whether a view is named — that's what openNavStack() and
    // size-only messages rely on. Only the view-level intent requires
    // the named view to already be in the pool.
    public func handleNavStackMessage(_ navIntake: NavStackMessage) {
        if navIntake.navId.lowercased() != self.id.lowercased() { return }

        if let io = navIntake.navAction {
            switch io {
                case .toggle: self.mainState = (self.mainState == .open) ? .closed : .open
                case .open:   self.mainState = .open
                case .close:  self.mainState = .closed
                default: break
            }
        }

        if let sio = navIntake.sidebarAction {
            switch sio {
                case .toggle: self.sidebarState = (self.sidebarState == .open) ? .closed : .open
                case .open:   self.sidebarState = .open
                case .close:  self.sidebarState = .closed
                default: break
            }
        }

        if let s = navIntake.size, self.navSize.rawValue != s.rawValue {
            self.setSize(gps: self.gps, s)
        }

        // View-level navigation: requires a registered view. If the
        // view isn't in the pool, log and skip — but the shell-level
        // intents above have already been applied.
        guard let viewName = navIntake.viewName, let va = navIntake.viewAction else { return }
        let key = WindowID(viewName)
        guard self.viewPool[key] != nil else {
            print("NavStack[\(self.id)]: ignoring viewAction for unregistered view '\(key)'")
            return
        }
        switch va {
            case .toggle:
                if self.activeView.map({ WindowID($0.id) }) == key { self.goBack() }
                else { self.navTo(viewId: viewName) }
            case .open:  self.navTo(viewId: viewName)
            case .close: self.goBack()
            default: break
        }
    }

    public func toggleSize() {
        if navSize == NavStackSize.full_menu_bar {
            self.isFloatable = false
            setSize(gps: gps, NavStackSize.full)
        } else if navSize == NavStackSize.full {
            turnOnFloating(gps: gps)
        } else {
            turnOffFloating(gps: gps)
        }
    }
    
    public func setSize(gps: GlobalPositioningSystem, _ navSize: NavStackSize) {
        mainAnimation {
            self.navSize = navSize
            self.width = navSize.width(in: gps.effectiveSize)
            self.height = navSize.height(in: gps.effectiveSize)
            self.resetPosition(gps: gps)
            self.offset = CGSize.zero
            self.originOffPos = CGPoint(x: 0, y: 0)
            self.offPos = CGPoint(x: 0, y: 0)
            self.masterResetTheWindow()
            self.saveDynaView()
        }
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
    
    public func turnOnFloating(gps: GlobalPositioningSystem) {
        self.isFloatable = true
        if self.isFloatable {
            self.isLocked = false
            setSize(gps: gps, .floatable_medium)
        }
    }
    
    public func turnOffFloating(gps: GlobalPositioningSystem) {
        self.isFloatable = false
        self.isLocked = true
        setSize(gps: gps, .full)
    }
    
    // Forces SwiftUI to tear down and rebuild the window body. The flag
    // must be flipped back on a LATER runloop tick — flipping it true
    // then false synchronously renders nothing (SwiftUI only ever sees
    // the final `false`), which made the old version a silent no-op.
    public func masterResetTheWindow() {
        masterResetNavWindow = true
        main { self.masterResetNavWindow = false }
    }
    
    public func preLoadWithCoreViews() {
        self.addView(
            callerId: MenuBarProvider.profile.tool.title,
            mainContent: { CoreSignUpView() },
            sideContent: { EmptyView() }
        )
    }
    
    // Function to add a view to the pool
    public func addView(window: ManagedViewHolder) {
       viewPool[WindowID(window.id)] = window
       if activeView == nil { setActiveViewByID(window.id) }
    }

    public func addView<Content: View, Side: View>(callerId: String, @ViewBuilder mainContent: @escaping () -> Content, @ViewBuilder sideContent: @escaping () -> Side = { EmptyView()}) {
        let newManagedWindow = VF.BuildManagedHolder(
            callerId: callerId.lowercased(),
            mainContent: mainContent,
            sideContent: sideContent
        )
        viewPool[WindowID(newManagedWindow.id)] = newManagedWindow
        if activeView == nil { setActiveViewByID(newManagedWindow.id) }
    }

    public func preLoad(window: ManagedViewHolder) -> NavWindowController {
        viewPool[WindowID(window.id)] = window
        if activeView == nil { setActiveViewByID(window.id) }
        return self
    }

    public func preLoad<Content: View, Side: View>(callerId: String, @ViewBuilder mainContent: @escaping () -> Content, @ViewBuilder sideContent: @escaping () -> Side = { EmptyView()}) -> NavWindowController {
        let newManagedWindow = VF.BuildManagedHolder(
            callerId: callerId.lowercased(),
            mainContent: mainContent,
            sideContent: sideContent
        )
        viewPool[WindowID(newManagedWindow.id)] = newManagedWindow
        if activeView == nil { setActiveViewByID(newManagedWindow.id) }
        return self
    }

    // Function to make a view active by its ID
    public func setActiveViewByID(_ id: String) {
        let key = WindowID(id)
        guard let window = viewPool[key] else { return }
        activeView = window
        if backStack.top != key { backStack.push(key) }
    }

    // Get the currently active view
    public func getActiveView() -> ManagedViewHolder? {
        return activeView
    }

    // Function to navigate to a specific view by ID
    public func navTo(viewId: String) {
        let key = WindowID(viewId)
        guard let window = viewPool[key] else { return }
        activeView = window
        if backStack.top != key { backStack.push(key) }
    }

    // Function to go back to the previous view in the history. The back
    // stack is LIFO: the current view is the top, the previous view is
    // the next one down. Refuse to pop the last remaining entry.
    public func goBack() {
        guard backStack.count > 1 else { return }
        _ = backStack.pop() // remove current (top of stack)
        guard let previousViewId = backStack.top else { return }
        if let previousView = viewPool[previousViewId] {
            activeView = previousView
        }
    }

    public func baseNav(windowId: String, _ action: WindowAction) {
        let key = WindowID(windowId)
        guard let window = viewPool[key] else { return }
        switch action {
            case .toggle: window.toggleMinimized()
            case .open: setActiveViewByID(windowId)
            case .close:
                window.windowLevel = .closed
                goBack() // Navigate back if a window is closed
            case .back: goBack()
            default: break
        }
    }

    public func resetNavStack(gps: GlobalPositioningSystem) {
        setSize(gps: gps, .full)
    }

    public func resetPosition(gps: GlobalPositioningSystem) {
        position = gps.getGlobalCoordinate(for: self.navSize == NavStackSize.full ? .center : .centerRight, childWidth: self.navSize.width(in: gps.effectiveSize), childHeight: self.navSize.height(in: gps.effectiveSize))
    }
    
    public func toggleWindowSize(gps: GlobalPositioningSystem) {
        if self.navSize != NavStackSize.full {
            setSize(gps: gps, .full)
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

    // MARK: DynaView
    // Window geometry persists into a ManagedView row keyed by this
    // controller's id. `toolType` holds the size preset's rawValue;
    // `isLocked` holds the REAL lock state (floatable is its inverse).
    public func loadDynaView() {
        guard let managedView = realmInstance.object(ofType: ManagedView.self, forPrimaryKey: self.id) else { return }
        mainAnimation {
            // Restore ANY persisted preset, not just three of six.
            if let savedSize = NavStackSize(rawValue: managedView.toolType) {
                self.navSize = savedSize
                self.width = savedSize.width(in: self.gps.effectiveSize)
                self.height = savedSize.height(in: self.gps.effectiveSize)
            }
            self.isLocked = managedView.isLocked
            self.isFloatable = !managedView.isLocked
            self.position = CGPoint(x: managedView.startX, y: managedView.startY)
            self.offPos = CGPoint(x: managedView.x, y: managedView.y)
            self.masterResetTheWindow()
        }
    }

    public func saveDynaView() {
        guard let managedView = realmInstance.object(ofType: ManagedView.self, forPrimaryKey: self.id) else {
            realmWriter { r in
                let managedView = ManagedView()
                managedView.id = self.id
                managedView.toolType = self.navSize.rawValue
                managedView.isLocked = self.isLocked
                managedView.width = Int(self.width)
                managedView.height = Int(self.height)
                managedView.x = self.offPos.x
                managedView.y = self.offPos.y
                managedView.startX = self.position.x
                managedView.startY = self.position.y
                r.create(ManagedView.self, value: managedView, update: .all)
                r.refresh()
            }
            return
        }
        realmWriter { r in
            managedView.toolType = self.navSize.rawValue
            managedView.isLocked = self.isLocked
            managedView.width = Int(self.width)
            managedView.height = Int(self.height)
            managedView.x = self.offPos.x
            managedView.y = self.offPos.y
            managedView.startX = self.position.x
            managedView.startY = self.position.y
        }
    }
    
}

