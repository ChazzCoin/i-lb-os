//
//  NodeWindowController.swift
//  CoreEngine
//
//  Created by Charles Romeo on 2/3/26.
//

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



//public typealias NodeWindow = NavWindowController


public func goToNode(callerId: String, _ action: WindowAction = .toggle) {
    BroadcastTools.send(.MENU_WINDOW_CONTROLLER, value: WindowController(windowId: callerId, stateAction: action))
//    CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: callerId, stateAction: action))
}


public enum NodeStackSize: String, CaseIterable {
    case full = "fullscreen"
    case full_menu_bar = "fullscreen_menu_bar"
    case half = "half"
    case floatable_large = "floatable_large"
    case floatable_medium = "floatable_medium"
    case floatable_small = "floatable_small"
    
    // Fraction of the container each preset occupies. Derive sizing from
    // the actual container, not UIScreen (wrong under Split View / Stage
    // Manager, stale across rotation). Prefer width(in:)/height(in:).
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

    // Screen-relative fallbacks, kept for default-init only.
    public var width: Double { UIScreen.main.bounds.width * widthFactor }
    public var height: Double { UIScreen.main.bounds.height * heightFactor }
}


public enum NodeStackState: String, CaseIterable {
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

public class NodeViewRegistry: ObservableObject {
    
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


public class NodeViewHolder: ObservableObject, Identifiable {

    @Published public var id: String
    public var mainBuilder: () -> AnyView
    public var sidebarBuilder: () -> AnyView
    @Published public var boardId: String = ""
    @Published public var title: String = "Core Window"
    @Published public var windowId: String = "Core Window"

    @ObservedObject public var gps = GlobalPositioningSystem(.canvas)
    @Published public var windowLevel: WindowLevel = .closed
    @Published public var isMinimized: Bool = false
    @Published public var isFullScreen: Bool = true
    @Published public var isGlobalWindow: Bool = false
    
    @Published public var parentGeo: GeometryProxy?
    @Published public var childGeo: GeometryProxy?
    
    @Published public var navSize: NodeStackSize = .full
    @Published public var width = NodeStackSize.full_menu_bar.width
    @Published public var height = NodeStackSize.full_menu_bar.height
    
    public init<V: View, S: View>(id: String, mainBuilder: @escaping () -> V = {EmptyView()}, sidebarBuilder: @escaping () -> S = {EmptyView()}) {
        self.id = id
        self.mainBuilder = { AnyView(mainBuilder()) }
        self.sidebarBuilder = { AnyView(sidebarBuilder()) }
    }

    public init(id: String, mainBuilder: AnyView, sidebarBuilder: AnyView) {
        self.id = id
        self.mainBuilder = { mainBuilder }
        self.sidebarBuilder = { sidebarBuilder }
    }

    public init(id: String, mainBuilder: @escaping () -> AnyView, sidebarBuilder: @escaping () -> AnyView) {
        self.id = id
        self.mainBuilder = mainBuilder
        self.sidebarBuilder = sidebarBuilder
    }
    
    public func updateMainBuilder<V: View>(_ mainBuilder: @escaping () -> V) {
        self.mainBuilder = { AnyView(mainBuilder()) }
    }
    
    @ViewBuilder
    public func MainDisplay(_ position: ScreenArea = .topCenter) -> some View {
        GeometryReader { pGeo in
            self.mainBuilder()
                .measure { cGeo in
                    self.parentGeo = pGeo;
                    self.childGeo = cGeo
                }
                .position(using: self.gps, at: position, with: self.childGeo)
        }
    }

    @ViewBuilder
    public func getMainView() -> some View { mainBuilder() }
    @ViewBuilder
    public func getSidebarView() -> some View { sidebarBuilder() }

    public func toggleMinimized() { isMinimized = !isMinimized }
    public func toggleFullScreen() { isFullScreen = !isFullScreen }
}


public class NodeWindowController: ObservableObject {
    
    @Published public var id: String = "master"
    
    @AppStorage("currentRoomId", store: UserDefaults(suiteName: "worlds")) public var currentRoomId: String = ""
    
    // Plain references — SwiftUI property wrappers are inert inside an
    // ObservableObject (see NavWindowController for the full rationale).
    public var gps = GlobalPositioningSystem(CoreNameSpace.canvas)
    public var broadcaster: BroadcastTools = BroadcastTools()

    @Published public var fullScreenView: NodeViewHolder? = nil
    @Published public var viewPool: [WindowID: NodeViewHolder] = [:]
    @Published public var preloadedPool: [WindowID: NodeViewHolder] = [:]
    @Published public var backStack: CoreQueue<WindowID> = CoreQueue()
    
    @Published public var navSize: NodeStackSize = .full
    @Published public var mainState: NodeStackState = .closed
    @Published public var sidebarIsEnabled: Bool = false
    @Published public var sidebarState: NodeStackState = .closed
    
    @Published public var isLocked = true
    @Published public var isFloatable: Bool = true
    
    @Published public var keyboardIsShowing = false
    @Published public var keyboardHeight = 0.0
    
    @Published public var masterResetNavWindow = false
      
    @Published public var width = NodeStackSize.full_menu_bar.width
    @Published public var height = NodeStackSize.full_menu_bar.height
    
    public var realmInstance: Realm = newRealm()
    public var cancellables = Set<AnyCancellable>()

    @Published public var nodeStackCount = 0
    
    @ViewBuilder
    public func displayFullScreenView() -> some View {
        NodeStackWindow(id: self.fullScreenView?.id ?? self.id)
            .environmentObject(self)
            .frame(width: width, height: height)
            .onAppear() {
                print("Adding Node Stack to Full Screen...")
            }
    }
    
    @ViewBuilder
    public func displayNode() -> some View {
        if self.mainState.main {
            NodeStackWindow(id: self.id)
                .environmentObject(self)
                .onAppear() {
                    print("Updating Node Stack...")
                }
        }
    }
    
    @ViewBuilder
    public func displayAllNodes() -> some View {
        ForEach(Array(self.viewPool.values)) { item in
            NodeStackWindow(id: item.id)
                .environmentObject(self)
                .frame(minWidth: 600, minHeight: 1000)
                .enableManagedViewBasic(viewId: item.id, activityId: self.currentRoomId)
                .onAppear() {
                    print("Adding Node [ \(item.id) ] to Stack...")
                }
        }
    }
    
    public init() {
        self.broadcaster = BroadcastTools()
        broadcaster.subscribeTo(.NodeStackMessage, storeIn: &cancellables) { wc in
            guard let navIntake = wc as? NodeStackMessage else { return }
            self.handleNodeStackMessage(navIntake)
        }
        self.preLoadWithCoreViews()
    }

    // Shell-level intents (open/close/size/sidebar) apply regardless of
    // whether a view is named; only view-level navigation requires the
    // named view to already be in the pool.
    public func handleNodeStackMessage(_ navIntake: NodeStackMessage) {
        if navIntake.nodeId.lowercased() != self.id.lowercased() { return }

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

        guard let viewName = navIntake.viewName, let va = navIntake.viewAction else { return }
        let key = WindowID(viewName)
        guard self.viewPool[key] != nil else {
            print("NodeStack[\(self.id)]: ignoring viewAction for unregistered view '\(key)'")
            return
        }
        switch va {
            case .toggle:
                if self.fullScreenView.map({ WindowID($0.id) }) == key { self.goBack() }
                else { self.navTo(viewId: viewName) }
            case .open:  self.navTo(viewId: viewName)
            case .close: self.goBack()
            default: break
        }
    }
    
    public func toggleSize() {
        if navSize == NodeStackSize.full_menu_bar {
            self.isFloatable = false
            setSize(gps: gps, NodeStackSize.full)
        } else if navSize == NodeStackSize.full {
            turnOnFloating(gps: gps)
        } else {
            turnOffFloating(gps: gps)
        }
    }
    
    public func setSize(gps: GlobalPositioningSystem, _ navSize: NodeStackSize) {
        mainAnimation {
            self.navSize = navSize
            self.width = navSize.width(in: gps.effectiveSize)
            self.height = navSize.height(in: gps.effectiveSize)
            self.masterResetTheWindow()
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
    
    // Flag must flip back on a LATER runloop tick or SwiftUI never sees
    // the teardown (see NavWindowController for the full rationale).
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
    public func addView(window: NodeViewHolder) {
       viewPool[WindowID(window.id)] = window
       if fullScreenView == nil { setActiveViewByID(window.id) }
    }

    public func addView<Content: View, Side: View>(callerId: String, @ViewBuilder mainContent: @escaping () -> Content, @ViewBuilder sideContent: @escaping () -> Side = { EmptyView()}) {
        let newManagedWindow = VF.BuildNodeHolder(
            callerId: callerId.lowercased(),
            mainContent: mainContent,
            sideContent: sideContent
        )
        viewPool[WindowID(newManagedWindow.id)] = newManagedWindow
        if fullScreenView == nil { setActiveViewByID(newManagedWindow.id) }
    }

    public func swapFromPreload(id: String) -> NodeWindowController {
        if let preWindow = preloadedPool[WindowID(id)] {
            self.addView(window: preWindow)
        }
        return self
    }
    public func swapFromView(id: String) -> NodeWindowController {
        if let preWindow = viewPool[WindowID(id)] {
            return self.preLoad(window: preWindow)
        }
        return self
    }

    public func preLoad(window: NodeViewHolder) -> NodeWindowController {
        preloadedPool[WindowID(window.id)] = window
        if fullScreenView == nil { setActiveViewByID(window.id) }
        return self
    }

    public func preLoad<Content: View, Side: View>(callerId: String, @ViewBuilder mainContent: @escaping () -> Content, @ViewBuilder sideContent: @escaping () -> Side = { EmptyView()}) -> NodeWindowController {
        let newManagedWindow = VF.BuildNodeHolder(
            callerId: callerId.lowercased(),
            mainContent: mainContent,
            sideContent: sideContent
        )
        preloadedPool[WindowID(newManagedWindow.id)] = newManagedWindow
        if fullScreenView == nil { setActiveViewByID(newManagedWindow.id) }
        return self
    }

    // Function to make a view active by its ID
    public func setActiveViewByID(_ id: String) {
        let key = WindowID(id)
        guard let window = viewPool[key] else { return }
        fullScreenView = window
        if backStack.top != key { backStack.push(key) }
    }

    // Get the currently active view
    public func getActiveView() -> NodeViewHolder? {
        return fullScreenView
    }

    // Function to navigate to a specific view by ID
    public func navTo(viewId: String) {
        let key = WindowID(viewId)
        guard let window = viewPool[key] else { return }
        fullScreenView = window
        if backStack.top != key { backStack.push(key) }
    }

    // Function to go back to the previous view in the history. LIFO:
    // current is the top, previous is the next one down.
    public func goBack() {
        guard backStack.count > 1 else { return }
        _ = backStack.pop() // remove current (top of stack)
        guard let previousViewId = backStack.top else { return }
        if let previousView = viewPool[previousViewId] {
            fullScreenView = previousView
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
    
    public func toggleWindowSize(gps: GlobalPositioningSystem) {
        if self.navSize != NodeStackSize.full {
            setSize(gps: gps, .full)
        } else {
            setSize(gps: gps, .half)
        }
    }
    
    public func addToStack() {
        self.nodeStackCount = self.nodeStackCount + 1
    }
    public func removeFromStack() {
        self.nodeStackCount = self.nodeStackCount - 1
    }

    // TODO: I like this idea, but don't know if it can work really...
    @ViewBuilder
    public static func linkTo<Content: View>(viewId: String, @ViewBuilder viewBuilder: @escaping () -> Content) -> NavigationLink<EmptyView, Content> {
        NavigationLink(destination: { viewBuilder() } ) { EmptyView() }
    }
    
}

