//
//  ManagedWindows.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/28/23.
//

import Foundation
import SwiftUI
import Combine


class ManagedViewWindow: Identifiable {
    
    @Published var id: String
    var viewBuilder: () -> AnyView
    @Published var boardId: String = ""
    @Published var title: String = "Ludi Window"
    @Published var windowId: String = "Ludi Window"
    
    @Published var isMinimized: Bool = false
    @Published var isFullScreen: Bool = true
    @Published var isGlobalWindow: Bool = false
    
    init<V: View>(id: String, viewBuilder: @escaping () -> V) {
        self.id = id
        self.viewBuilder = { AnyView(viewBuilder()) }
    }

    func toggleMinimized() { isMinimized = !isMinimized }
    func toggleFullScreen() { isFullScreen = !isFullScreen }
}
class NavWindowController: ObservableObject {
    @Published var reload: Bool = false
    @Published var activeViews: [String: ManagedViewWindow] = [:]
    @Published private var viewPool: [String: ManagedViewWindow] = [:]
    
    @Published var cancellables = Set<AnyCancellable>()
    
    func doReload() {
        reload = true
        reload = false
    }
    
    init() {
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
    
    func doesKeyExist(_ key: String) -> Bool {
        return viewPool[key] != nil
    }
    
    func getView(withId viewId: String) -> ManagedViewWindow {
        if let view = activeViews[viewId] {
            return view
        } else {
            return prepareView(withId: viewId)
        }
    }
    
    private func prepareView(withId viewId: String) -> ManagedViewWindow {
        if let reusedView = viewPool[viewId] {
            // Reuse a view from the pool if available
            activeViews[viewId] = reusedView
            return reusedView
        } else {
            // Create a new view if not available in the pool
            let newView = ManagedViewWindow(id: viewId, viewBuilder: { ChatView() })
            activeViews[viewId] = newView
            return newView
        }
    }
    
    func toggleView(viewId: String) {
        if let _ = activeViews[viewId] {
            removeFromActive(forKey: viewId)
            return
        }
        if let viewInPool = viewPool[viewId] {
            activeViews[viewId] = viewInPool
        }
    }
    
    func moveToActive(viewId: String) {
        guard let view = viewPool[viewId] else { return }
        activeViews[viewId] = view
    }
    
    private func removeAllFromActive() {
        activeViews.removeAll()
    }
    
    private func removeAllFromActiveButId(viewId: String) {
        self.removeAllFromActive()
        moveToActive(viewId: viewId)
    }
    
//    private func moveToPool(viewId: String) {
//        if let view = activeViews.removeValue(forKey: viewId) {
//            viewPool[viewId] = view
//        }
//    }
    
    func addNewViewToPool(viewId: String, viewBuilder: @escaping () -> AnyView) {
        // Check if the view already exists in the pool or active views to avoid duplicates
        if viewPool[viewId] == nil && activeViews[viewId] == nil {
            let newView = ManagedViewWindow(id: viewId, viewBuilder: viewBuilder)
            viewPool[viewId] = newView
        }
    }
    
    func safelyRemoveItem(forKey key: String) {
        DispatchQueue.main.async {
            self.activeViews.removeValue(forKey: key)
            self.viewPool.removeValue(forKey: key)
        }
    }
    func removeFromActive(forKey key: String) {
        self.activeViews.removeValue(forKey: key)
    }
}

class ManagedViewWindows: ObservableObject {
    
    @Published var managedViewWindows: [ManagedViewWindow] = []
    @Published var managedViewGenerics: [String:ManagedViewWindow] = [:]
    
    func newManagedViewWindow(viewId: String) -> ManagedViewWindow {
        return ManagedViewWindow(id: viewId, viewBuilder: {ChatView()})
    }
    
    func toggleManagedViewWindowById(viewId: String) {
        guard let temp = managedViewWindows.first(where: { $0.id == viewId }) else { return }
        temp.toggleMinimized()
    }
    
    func toggleItem(key: String, item: ManagedViewWindow) {
        DispatchQueue.main.async {
            if self.managedViewGenerics[key] != nil {
                self.managedViewGenerics.removeValue(forKey: key)
            } else {
                self.managedViewGenerics[key] = item
            }
        }
    }
    
    func safelyAddItem(key: String, item: ManagedViewWindow) {
        DispatchQueue.main.async {
            self.managedViewGenerics[key] = item
        }
    }
    func safelyRemoveItem(forKey key: String) {
        DispatchQueue.main.async {
            self.managedViewGenerics.removeValue(forKey: key)
        }
    }

}
