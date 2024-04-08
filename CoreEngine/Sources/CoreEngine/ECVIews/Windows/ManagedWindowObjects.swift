//
//  ManagedWindows.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/28/23.
//

import Foundation
import SwiftUI
import Combine

public class ManagedViewWindow: Identifiable {
    
    @Published public var id: String
    public var viewBuilder: () -> AnyView
    @Published public var boardId: String = ""
    @Published public var title: String = "Ludi Window"
    @Published public var windowId: String = "Ludi Window"
    
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
public class NavWindowController: ObservableObject {
    @Published public var reload: Bool = false
    @Published public var activeViews: [String: ManagedViewWindow] = [:]
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
                                
                for item in self.activeViews {
                    if item.key != temp.windowId {
                        self.removeFromActive(forKey: item.key)
                    }
                }
                
                if temp.stateAction == "toggle" {
                    self.toggleView(viewId: temp.windowId)
                } else if temp.stateAction == "open" {
                    self.moveToActive(viewId: temp.windowId)
                } else if temp.stateAction == "close" {
                    self.removeFromActive(forKey: temp.windowId)
                }
                self.doReload()
            }.store(in: &self.cancellables)
        }
        
    }
    
    public func doesKeyExist(_ key: String) -> Bool {
        return viewPool[key] != nil
    }
    
    public func getView(withId viewId: String) -> ManagedViewWindow {
        if let view = activeViews[viewId] {
            return view
        } else {
            return prepareView(withId: viewId)
        }
    }
    
    public func prepareView(withId viewId: String) -> ManagedViewWindow {
        if let reusedView = viewPool[viewId] {
            // Reuse a view from the pool if available
            activeViews[viewId] = reusedView
            return reusedView
        } else {
            // Create a new view if not available in the pool
            let newView = ManagedViewWindow(id: viewId, viewBuilder: { EmptyView() })
            activeViews[viewId] = newView
            return newView
        }
    }
    
    public func toggleView(viewId: String) {
        if let _ = activeViews[viewId] {
            removeFromActive(forKey: viewId)
            return
        }
        if let viewInPool = viewPool[viewId] {
            activeViews[viewId] = viewInPool
        }
    }
    
    public func moveToActive(viewId: String) {
        guard let view = viewPool[viewId] else { return }
        activeViews[viewId] = view
    }
    
    public func removeAllFromActive() {
        activeViews.removeAll()
    }
    
    public func removeAllFromActiveButId(viewId: String) {
        self.removeAllFromActive()
        moveToActive(viewId: viewId)
    }
    
//    private func moveToPool(viewId: String) {
//        if let view = activeViews.removeValue(forKey: viewId) {
//            viewPool[viewId] = view
//        }
//    }
    
    public func addNewViewToPool(viewId: String, viewBuilder: @escaping () -> AnyView) {
        // Check if the view already exists in the pool or active views to avoid duplicates
        if viewPool[viewId] == nil && activeViews[viewId] == nil {
            let newView = ManagedViewWindow(id: viewId, viewBuilder: viewBuilder)
            viewPool[viewId] = newView
        }
    }
    
    public func safelyRemoveItem(forKey key: String) {
        DispatchQueue.main.async {
            self.activeViews.removeValue(forKey: key)
            self.viewPool.removeValue(forKey: key)
        }
    }
    public func removeFromActive(forKey key: String) {
        self.activeViews.removeValue(forKey: key)
    }
}

public class ManagedViewWindows: ObservableObject {
    
    @Published public var managedViewWindows: [ManagedViewWindow] = []
    @Published public var managedViewGenerics: [String:ManagedViewWindow] = [:]
    
//    public func newManagedViewWindow(viewId: String) -> ManagedViewWindow {
//        return ManagedViewWindow(id: viewId, viewBuilder: {ChatView()})
//    }
    
    public func toggleManagedViewWindowById(viewId: String) {
        guard let temp = managedViewWindows.first(where: { $0.id == viewId }) else { return }
        temp.toggleMinimized()
    }
    
    public func toggleItem(key: String, item: ManagedViewWindow) {
        DispatchQueue.main.async {
            if self.managedViewGenerics[key] != nil {
                self.managedViewGenerics.removeValue(forKey: key)
            } else {
                self.managedViewGenerics[key] = item
            }
        }
    }
    
    public func safelyAddItem(key: String, item: ManagedViewWindow) {
        DispatchQueue.main.async {
            self.managedViewGenerics[key] = item
        }
    }
    public func safelyRemoveItem(forKey key: String) {
        DispatchQueue.main.async {
            self.managedViewGenerics.removeValue(forKey: key)
        }
    }

}
