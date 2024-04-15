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



@ViewBuilder
public func ForEachActiveManagedWindow(managedWindowsObject: NavWindowController) -> some View {
    if !managedWindowsObject.reload {
        ForEach(Array(managedWindowsObject.globalViews.keys), id: \.self) { key in
            managedWindowsObject.getWindow(withId: key)?.viewBuilder().zIndex(50.0)
        }
    }
}

public class ManagedViewWindow: Identifiable {
    
    @Published public var id: String
    public var viewBuilder: () -> AnyView
    @Published public var boardId: String = ""
    @Published public var title: String = "Ludi Window"
    @Published public var windowId: String = "Ludi Window"
    
    @Published public var windowLevel: WindowLevel = .closed
    @Published public var isMinimized: Bool = false
    @Published public var isFullScreen: Bool = true
    @Published public var isGlobalWindow: Bool = false
    
    public init<V: View>(id: String, viewBuilder: @escaping () -> V) {
        self.id = id
        self.viewBuilder = { AnyView(viewBuilder()) }
    }

    public func toggleMinimized() { isMinimized = !isMinimized }
    public func toggleFullScreen() { isFullScreen = !isFullScreen }
}


public func goToWindow(callerId: String, _ action: WindowAction = .toggle) {
    BroadcastTools.send(.MENU_WINDOW_CONTROLLER, value: WindowController(windowId: callerId, stateAction: action))
//    CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: callerId, stateAction: action))
}

public typealias Nav = NavWindowController

//{ HomeDashboardView().environmentObject(self.BEO) }
// Used within Canvas
public class NavWindowController: ObservableObject {
    
    @AppStorage("activeGlobalWindowId") public var activeGlobalWindowId: String = ""
    @AppStorage("activeCanvasWindowId") public var activeCanvasWindowId: String = ""
    @AppStorageList(key: "registeredWindows") public var registeredWindows: [String] = []
    @ObservedObject public var broadcaster: BroadcastTools = BroadcastTools()
    
    @Published public var reload: Bool = false
    @Published public var globalViews: [String: ManagedViewWindow] = [:]
    @Published public var canvasViews: [String: ManagedViewWindow] = [:]
    @Published public var viewPool: [String: ManagedViewWindow] = [:]
    @Published public var isMultiView: Bool = false
    
    @Published public var cancellables = Set<AnyCancellable>()
    @Published public var cancellables2 = Set<AnyCancellable>()
    
    public func doReload() {
        reload = true
        reload = false
    }
    
    public init() {
        self.appWillTerminate()
        print("Registered Callers: \(self.registeredWindows)")
        main { self.subscribeToWindowChannel() }
    }
    
    private func appWillTerminate() {
        print("App is terminating, removing registered callers.")
        self.registeredWindows.removeAll()
    }
    
    public func subscribeToWindowChannel() {
//        broadcaster.subscribeTo(.appWillTerminate, { _ in
//            self.appWillTerminate()
//        })
        broadcaster.subscribeTo(.MENU_WINDOW_CONTROLLER, storeIn: &cancellables) { wc in
            if let temp = wc as? WindowController {
                self.windowNav(windowId: temp.windowId.lowercased(), temp.stateAction)
            }
            
//            self.baseNav(windowId: temp.windowId, temp.stateAction)
        }
    }
    
    public func windowNav(windowId: String, _ action: WindowAction) {
        
        if self.containsRegisteredWindow(windowId) {
            self.baseNav(windowId: windowId, action)
            return
        }
        
        if let window = WindowProvider.parseToWindow(windowId: windowId) {
            self.addNewNavStackToPool(viewId: windowId, viewBuilder: window.view)
            self.baseNav(windowId: windowId, action)
        }
    }
    
    public func baseNav(windowId: String, _ action: WindowAction) {
        switch action {
            case .toggle: self.toggleView(viewId: windowId, .global)
            case .open: self.moveToActive(viewId: windowId, .global)
            case .close: self.removeFromActive(forKey: windowId)
            default: break
        }
    }
    
    // ViewBuilders
    @ViewBuilder
    public func ForEachView(in level: WindowLevel = .global) -> some View {
        if !reload {
            let views = level == .global ? globalViews : canvasViews
            ForEach(Array(views.keys), id: \.self) { key in
               views[key]?.viewBuilder().zIndex(50.0)
            }
        }
    }

    // MARK: -> Add any view to an embedded Nav Stack ...to the pool
    public func addNewNavStackToPool<Content: View>(viewId: String, @ViewBuilder viewBuilder: @escaping () -> Content) {
        if self.containsRegisteredWindow(viewId) { return }
        print("Registering new window: \(viewId)")
        self.addRegisteredWindow(viewId: viewId)
        viewPool[viewId] = VF.BuildManagedStack(callerId: viewId, viewContent: { viewBuilder() })
    }
    // MARK: -> Add any view ...to the pool
    public func addNewViewToPool<Content: View>(viewId: String, @ViewBuilder anyView: @escaping () -> Content) {
        if self.containsRegisteredWindow(viewId) { return }
        print("Registering new window: \(viewId)")
        self.addRegisteredWindow(viewId: viewId)
        viewPool[viewId] = VF.BuildManagedHolder(callerId: viewId, viewContent: anyView)
    }
    
    // MARK: -> Add any view ...to the pool
    public func addNewViewToPool<Content: View>(viewId: String, viewBuilder: Content) {
        if self.containsRegisteredWindow(viewId) { return }
        print("Registering new window: \(viewId)")
        self.addRegisteredWindow(viewId: viewId)
        viewPool[viewId] = VF.BuildManagedHolder(callerId: viewId, viewContent: {viewBuilder})
    }
    
    // MARK: -> Add pre-built Managed View ...to the pool
    public func addNewViewToPool(viewId: String, managedView: ManagedViewWindow) {
        if self.containsRegisteredWindow(viewId) { return }
        print("Registering new window: \(viewId)")
        self.addRegisteredWindow(viewId: viewId)
        viewPool[viewId] = managedView
    }
    // Queue Management
    public func containsRegisteredWindow(_ viewId: String) -> Bool { return registeredWindows.contains(viewId.lowercased()) }
    public func addRegisteredWindow(viewId: String) { registeredWindows.append(viewId.lowercased()) }
    
    public func setActiveWindowId(windowId: String, windowLevel: WindowLevel) {
        switch windowLevel {
            case .global: self.setActiveGlobalWindowId(windowId)
            case .canvas: self.setActiveCanvasWindowId(windowId)
            default: return
        }
    }
    
    public func isActiveWindowId(windowId: String, windowLevel: WindowLevel) -> Bool {
        switch windowLevel {
            case .global: 
                return self.hasActiveGlobalWindowId(windowId)
            case .canvas:
                return self.hasActiveCanvasWindowId(windowId)
            default: return false
        }
    }
    
    public func setActiveGlobalWindowId(_ windowId: String) { self.activeGlobalWindowId = windowId }
    public func clearActiveGlobalWindowId(_ windowId: String) { self.activeGlobalWindowId = "" }
    public func hasActiveGlobalWindowId(_ windowId: String) -> Bool { !self.activeGlobalWindowId.isEmpty }
    
    public func setActiveCanvasWindowId(_ windowId: String) { self.activeCanvasWindowId = windowId }
    public func clearActiveCanvasWindowId(_ windowId: String) { self.activeCanvasWindowId = "" }
    public func hasActiveCanvasWindowId(_ windowId: String) -> Bool { !self.activeCanvasWindowId.isEmpty }
    
    public func doesKeyExist(_ key: String) -> Bool { return viewPool[key] != nil }
    
    public func getWindow(withId viewId: String, _ level: WindowLevel = .global) -> ManagedViewWindow? {
        switch level {
            case .global: return globalViews[viewId]
            case .canvas: return canvasViews[viewId]
            default: return nil
        }
    }
    
    private func toggleView(viewId: String, _ level: WindowLevel = .global) {
        let targetDictionary = level == .global ? globalViews : canvasViews
        if targetDictionary[viewId] != nil {
            removeFromActive(forKey: viewId)
        } else {
            moveToActive(viewId: viewId, level)
        }
        self.doReload()
    }

    public func moveToActive(viewId: String, _ level: WindowLevel = .global) {
        
        if !self.isActiveWindowId(windowId: viewId, windowLevel: level) { return }
        
        if !self.isMultiView {
            switch level {
               case .global: self.globalViews.removeAll()
               case .canvas: self.canvasViews.removeAll()
               default:  break
            }
        }
        guard let view = viewPool[viewId] else { return }
        self.setActiveWindowId(windowId: viewId, windowLevel: level)
        main {
            switch level {
               case .global: self.globalViews[viewId] = view
               case .canvas: self.canvasViews[viewId] = view
               default:  break
            }
        }
    }
    
    public func removeAllFromActive() {
        globalViews.removeAll()
        canvasViews.removeAll()
    }
    
    public func removeAllFrom(_ level: WindowLevel = .global) {
        for item in self.globalViews {
            self.removeFromActive(forKey: item.key)
        }
    }
    
    public func rgvs() {
        print(self.registeredWindows)
        for item in self.registeredWindows {
            print("Removing: \(item)")
            self.globalViews.removeValue(forKey: item)
        }
    }
    public func removeFromActive(forKey key: String) {
        if let _ = globalViews[key] {
            self.globalViews.removeValue(forKey: key)
        }
        if let _ = canvasViews[key] {
            self.canvasViews.removeValue(forKey: key)
        }
    }
}

