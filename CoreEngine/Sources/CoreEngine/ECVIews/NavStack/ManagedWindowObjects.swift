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
    if !managedWindowsObject.reload {
        ForEach(Array(managedWindowsObject.globalViews.keys), id: \.self) { key in
            managedWindowsObject.getWindow(withId: key)?.viewBuilder().zIndex(50.0)
        }
    }
}

// Open Window

// Close Window

// Toggle Window

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
    @Published public var registeredCallers: [String] = []
    @Published public var globalViews: [String: ManagedViewWindow] = [:]
    @Published public var canvasViews: [String: ManagedViewWindow] = [:]
    @Published public var viewPool: [String: ManagedViewWindow] = [:]
    @Published public var isMultiView: Bool = false
    
    @Published public var cancellables = Set<AnyCancellable>()
    
    public func doReload() {
        reload = true
        reload = false
    }
    
    public init() {
        CodiChannel.MENU_WINDOW_CONTROLLER.receive(on: RunLoop.main) { wc in
            let temp = wc as! WindowController
            switch temp.stateAction {
                case "toggle":
                    print("toggling \(temp.windowId)")
                    self.toggleView(viewId: temp.windowId, .global)
                case "open":
                    self.moveToActive(viewId: temp.windowId, .global)
                case "close":
                    self.removeFromActive(forKey: temp.windowId)
                default:
                    break
            }
        }.store(in: &self.cancellables)
        
    }
    // ViewBuilders
    
    @ViewBuilder
    public func ForEachView(for level: WindowLevel = .global) -> some View {
        if !reload {
            let views = level == .global ? globalViews : canvasViews
            ForEach(Array(views.keys), id: \.self) { key in
               views[key]?.viewBuilder().zIndex(50.0)
            }
        }
    }

    public func addNewViewToPool<Content: View>(viewId: String, @ViewBuilder viewBuilder: @escaping () -> Content) {
        if registeredCallers.contains(viewId) { return }
        print("Registering new window: \(viewId)")
        registeredCallers.append(viewId)
        viewPool[viewId] = ManagedViewWindow(id: viewId, viewBuilder: viewBuilder)
    }
    
    // Queue Management
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
        
        if !self.isMultiView {
            switch level {
               case .global:
                    self.globalViews.removeAll()
               case .canvas:
                    self.canvasViews.removeAll()
               default:
                    break
            }
        }
        guard let view = viewPool[viewId] else {
            print("Cant find window: \(viewId)")
            return
        }
        main {
            switch level {
               case .global:
                    print("Adding window to Global: \(viewId)")
                    self.globalViews[viewId] = view
               case .canvas:
                    print("Adding window to Canvas: \(viewId)")
                    self.canvasViews[viewId] = view
               default: 
                    break
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
    
//    public func removeAllFromActiveButId(viewId: String) {
//        self.removeAllFromActive()
//        moveToActive(viewId: viewId, .global)
//    }
//    
    public func rgvs() {
        print(self.registeredCallers)
        for item in self.registeredCallers {
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
