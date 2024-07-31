//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/18/24.
//

import Foundation
import SwiftUI



public class CoreViewHolder<C: View, S: View>: Identifiable {
    
    @Published public var id: String
    public var mainBuilder: () -> C
    public var sidebarBuilder: () -> S
    @Published public var boardId: String = ""
    @Published public var title: String = "Core Engine"
    @Published public var windowId: String = "Core Engine"
    
    @Published public var windowLevel: WindowLevel = .closed
    @Published public var isMinimized: Bool = false
    @Published public var isFullScreen: Bool = true
    @Published public var isGlobalWindow: Bool = false
    
    public init(id: String, mainBuilder: @escaping () -> C, sidebarBuilder: @escaping () -> S = {EmptyView()}) {
        self.id = id
        self.mainBuilder = mainBuilder
        self.sidebarBuilder = sidebarBuilder
    }
    
    public init(id: String, mainBuilder: C, sidebarBuilder: S) {
        self.id = id
        self.mainBuilder = { mainBuilder }
        self.sidebarBuilder = { sidebarBuilder }
    }
    
    @ViewBuilder
    public func getMainView() -> some View { mainBuilder() }
    @ViewBuilder
    public func getSidebarView() -> some View { sidebarBuilder() }

    public func toggleMinimized() { isMinimized = !isMinimized }
    public func toggleFullScreen() { isFullScreen = !isFullScreen }
}

public class ManagedViewHolder: ObservableObject, Identifiable {

    @Published public var id: String
    public var mainBuilder: () -> AnyView
    public var sidebarBuilder: () -> AnyView
    @Published public var boardId: String = ""
    @Published public var title: String = "Core Window"
    @Published public var windowId: String = "Core Window"

    @ObservedObject public var gps = GlobalPositioningSystem(.global)
    @Published public var windowLevel: WindowLevel = .closed
    @Published public var isMinimized: Bool = false
    @Published public var isFullScreen: Bool = true
    @Published public var isGlobalWindow: Bool = false
    
    @Published public var parentGeo: GeometryProxy?
    @Published public var childGeo: GeometryProxy?
    
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
