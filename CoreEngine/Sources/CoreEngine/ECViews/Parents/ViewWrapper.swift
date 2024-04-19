//
//  ViewWrapper.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI

public struct Hold<Content: View>: Identifiable {
    public let id: UUID
    @ViewBuilder public let viewHolder: () -> Content

    public init(id: UUID = UUID(), @ViewBuilder viewHolder: @escaping () -> Content) {
        self.id = id
        self.viewHolder = viewHolder
    }
    
    public func view() -> () -> Content { return viewHolder }
}


public struct WrapLite<C: View>: View {
    @ViewBuilder public let viewHolder: () -> C
    @State public var width: Double = 0.0
    @State public var height: Double = 0.0
    @State public var masterReset: Bool = false

    public init(@ViewBuilder _ viewHolder: @escaping () -> C) {
        self.viewHolder = viewHolder
    }
    
    public var body: some View {
        if self.masterReset { EmptyView() }
        ZStack {
            viewHolder()
                .measure { geo in
                    print("Wrap: \(geo.size)")
                    self.width = geo.size.width
                    self.height = geo.size.height
                    self.masterReset.toggle()
                    self.masterReset.toggle()
                }
        }
        .frame(width: self.width, height: self.height)
    }
}

public struct Wrap<C: View>: View {
    @ViewBuilder public let viewHolder: () -> C
    @Binding public var isVisible: Bool
    @ObservedObject public var gps = GlobalPositioningSystem(CoreNameSpace.global)
    @State public var width: Double = 0.0
    @State public var height: Double = 0.0
    @State public var masterReset: Bool = false
    @State public var safePadding: Bool = false
    @State public var pos: ScreenArea?
    @State public var geo: GeometryProxy?

    public init(_ position: ScreenArea? = nil, padding: Bool = false, @ViewBuilder _ viewHolder: @escaping () -> C) {
        self.viewHolder = viewHolder
        self._isVisible = .constant(true)
        self.safePadding = padding
        self._pos = State(initialValue: position)
    }
    
    public init(_ visibility: Binding<Bool>, _ position: ScreenArea? = nil, padding: Bool = false, @ViewBuilder _ viewHolder: @escaping () -> C) {
        self.viewHolder = viewHolder
        self._isVisible = visibility
        self.safePadding = padding
        self._pos = State(initialValue: position)
    }
    
    public init(_ visibility: Binding<Bool>, @ViewBuilder _ viewHolder: @escaping () -> C) {
        self.viewHolder = viewHolder
        self._isVisible = visibility
    }
    
    public func res() {
        main {
            self.masterReset.toggle()
            self.masterReset.toggle()
        }
    }
    public var body: some View {
        if self.masterReset { EmptyView() }
        if self.isVisible {
            if self.pos != nil { gpsView }
            else { liteView }
        }
    }
    
    public var liteView: some View {
        ZStack {
            viewHolder()
                .measure { geo in
                    print("Wrap: \(geo.size)")
                    self.width = geo.size.width
                    self.height = geo.size.height
                    self.masterReset.toggle()
                    self.masterReset.toggle()
                }
        }
        .frame(width: self.width, height: self.height)
    }
    
    public var gpsView: some View {
        ZStack {
            viewHolder()
                .measure { g in
                    print("Wrap: \(g.size)")
                    self.geo = g
                    self.width = g.size.width
                    self.height = g.size.height
                    self.res()
                }
        }
        .frame(width: self.width, height: self.height)
        .position(using: gps, at: pos!, with: geo, safePadding: safePadding)
    }
}
