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

public enum WindowLevel: String, CaseIterable {
    case closed = "closed"
    case global = "global"
    case canvas = "canvas"
    case fullscreen = "fullscreen"
}

@ViewBuilder
public func ForEachActiveManagedWindow(managedWindowsObject: NavWindowController) -> some View {
    ForEach(Array(managedWindowsObject.globalViews.keys), id: \.self) { key in
        managedWindowsObject.getGlobalView(withId: key)
            .viewBuilder().zIndex(50.0)
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

// Used within Canvas
public class NavWindowController: ObservableObject {
    @Published public var reload: Bool = false
    @Published public var globalViews: [String: ManagedViewWindow] = [:]
    @Published public var canvasViews: [String: ManagedViewWindow] = [:]
    @Published public var viewPool: [String: ManagedViewWindow] = [:]
    
    @Published public var cancellables = Set<AnyCancellable>()
    
    public func doReload() {
        reload = true
        reload = false
    }
    
    public init() {
        DispatchQueue.main.async {
            CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { wc in
                let temp = wc as! WindowController
                
                if temp.windowId == "master" {
                    self.removeAllFromActive()
                }
                
                if !self.doesKeyExist(temp.windowId) {
                    return
                }
                                
                for item in self.globalViews {
                    if item.key != temp.windowId {
                        self.removeFromActive(forKey: item.key)
                    }
                }
                
                if temp.stateAction == "toggle" {
                    self.toggleGlobalView(viewId: temp.windowId)
                } else if temp.stateAction == "open" {
                    self.moveToActive(viewId: temp.windowId, .global)
                } else if temp.stateAction == "close" {
                    self.removeFromActive(forKey: temp.windowId)
                }
                self.doReload()
            }.store(in: &self.cancellables)
        }
        
    }
    // ViewBuilders
    
    @ViewBuilder
    public func ForEachGlobalManagedWindow() -> some View {
        ForEach(Array(globalViews.keys), id: \.self) { key in
            self.getGlobalView(withId: key).viewBuilder().zIndex(50.0)
        }
    }
    
    @ViewBuilder
    public func ForEachCanvasManagedWindow() -> some View {
        ForEach(Array(globalViews.keys), id: \.self) { key in
            self.getCanvasView(withId: key).viewBuilder().zIndex(50.0)
        }
    }
    
    public func addNewViewToPool<Content: View>(viewId: String, @ViewBuilder viewBuilder: @escaping () -> Content) {
        // Check if the view already exists in the pool or active views to avoid duplicates
        if viewPool[viewId] == nil && globalViews[viewId] == nil {
            let newView = ManagedViewWindow(id: viewId, viewBuilder: viewBuilder)
            viewPool[viewId] = newView
        }
    }
    
    public func addNewViewToPool(viewId: String, viewBuilder: @escaping () -> AnyView) {
        // Check if the view already exists in the pool or active views to avoid duplicates
        if viewPool[viewId] == nil && globalViews[viewId] == nil {
            let newView = ManagedViewWindow(id: viewId, viewBuilder: viewBuilder)
            viewPool[viewId] = newView
        }
    }
    
    // Queue Management
    public func doesKeyExist(_ key: String) -> Bool { return viewPool[key] != nil }
    
    public func getGlobalView(withId viewId: String) -> ManagedViewWindow {
        if let view = globalViews[viewId] {
            return view
        } else {
            return prepareViewForGlobal(withId: viewId)
        }
    }
    
    public func getCanvasView(withId viewId: String) -> ManagedViewWindow {
        if let view = canvasViews[viewId] {
            return view
        } else {
            return prepareViewForGlobal(withId: viewId)
        }
    }
    
    public func prepareViewForGlobal(withId viewId: String) -> ManagedViewWindow {
        if let reusedView = viewPool[viewId] {
            // Reuse a view from the pool if available
            globalViews[viewId] = reusedView
            return reusedView
        } else {
            // Create a new view if not available in the pool
            let newView = ManagedViewWindow(id: viewId, viewBuilder: { EmptyView() })
            globalViews[viewId] = newView
            return newView
        }
    }
    
    public func prepareViewForCanvas(withId viewId: String) -> ManagedViewWindow {
        if let reusedView = viewPool[viewId] {
            // Reuse a view from the pool if available
            canvasViews[viewId] = reusedView
            return reusedView
        } else {
            // Create a new view if not available in the pool
            let newView = ManagedViewWindow(id: viewId, viewBuilder: { EmptyView() })
            canvasViews[viewId] = newView
            return newView
        }
    }
    
    public func toggleGlobalView(viewId: String) {
        if let _ = globalViews[viewId] {
            removeFromActive(forKey: viewId)
            return
        }
        if let viewInPool = viewPool[viewId] {
            globalViews[viewId] = viewInPool
        }
    }
    
    public func toggleCanvasView(viewId: String) {
        if let _ = canvasViews[viewId] {
            removeFromActive(forKey: viewId)
            return
        }
        if let viewInPool = viewPool[viewId] {
            canvasViews[viewId] = viewInPool
        }
    }
    
    public func moveToActive(viewId: String, _ level: WindowLevel = .global) {
        guard let view = viewPool[viewId] else { return }
        switch level {
            case .global: globalViews[viewId] = view
            case .canvas: canvasViews[viewId] = view
            case .fullscreen: globalViews[viewId] = view
            default: return
        }
    }
    
    public func removeAllFromActive() {
        globalViews.removeAll()
        canvasViews.removeAll()
    }
    
    public func removeAllFromActiveButId(viewId: String) {
        self.removeAllFromActive()
        moveToActive(viewId: viewId, .global)
    }
    
    public func safelyRemoveItem(forKey key: String) {
        DispatchQueue.main.async {
            self.viewPool.removeValue(forKey: key)
            self.globalViews.removeValue(forKey: key)
            self.canvasViews.removeValue(forKey: key)
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

//public class ManagedViewWindows: ObservableObject {
//    
//    @Published public var managedViewWindows: [ManagedViewWindow] = []
//    @Published public var managedViewGenerics: [String:ManagedViewWindow] = [:]
//    
////    public func newManagedViewWindow(viewId: String) -> ManagedViewWindow {
////        return ManagedViewWindow(id: viewId, viewBuilder: {ChatView()})
////    }
//    
//    public func toggleManagedViewWindowById(viewId: String) {
//        guard let temp = managedViewWindows.first(where: { $0.id == viewId }) else { return }
//        temp.toggleMinimized()
//    }
//    
//    public func toggleItem(key: String, item: ManagedViewWindow) {
//        DispatchQueue.main.async {
//            if self.managedViewGenerics[key] != nil {
//                self.managedViewGenerics.removeValue(forKey: key)
//            } else {
//                self.managedViewGenerics[key] = item
//            }
//        }
//    }
//    
//    public func safelyAddItem(key: String, item: ManagedViewWindow) {
//        DispatchQueue.main.async {
//            self.managedViewGenerics[key] = item
//        }
//    }
//    public func safelyRemoveItem(forKey key: String) {
//        DispatchQueue.main.async {
//            self.managedViewGenerics.removeValue(forKey: key)
//        }
//    }
//
//}
