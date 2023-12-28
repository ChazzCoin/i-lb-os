//
//  ManagedWindows.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/28/23.
//

import Foundation
import SwiftUI

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

class ManagedViewWindows: ObservableObject {
    
    static let shared = ManagedViewWindows()
    
    @Published var managedViewWindows: [ManagedViewWindow] = []
    @Published var managedViewGenerics: [String:ManagedViewWindow] = [:]
    
    func newManagedViewWindow(viewId: String) -> ManagedViewWindow {
        return ManagedViewWindow(id: viewId, viewBuilder: {ChatView(chatId: "default-1")})
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
