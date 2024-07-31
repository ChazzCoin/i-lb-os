//
//  ViewWrapper.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI
import RealmSwift

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
//@StateRealmObject public var dyna = ManagedView()
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

// MARK: --> @StateRealmObject <-- \\
public struct DynaWrap<C: View>: View {
    @ViewBuilder public let viewHolder: () -> C
    @StateRealmObject var dyna: ManagedView  // StateRealmObject manages the live object state
    @State public var isVisible: Bool = true
    @State public var useOriginal = true
    @State public var originOffPos = CGPoint(x: 0, y: 0)
    @State private var isDragging = false
    @GestureState private var dragOffset = CGSize.zero

    // MARK: INITIALIZING A @StateRealmObject
    public init(id: String, @ViewBuilder _ viewHolder: @escaping () -> C) {
        self.viewHolder = viewHolder
        let realm = try! Realm()
        if let existingDyna = realm.object(ofType: ManagedView.self, forPrimaryKey: id) {
            _dyna = StateRealmObject(wrappedValue: existingDyna)  // Initialize with existing object
        } else {
            let newDyna = ManagedView()  // Create new if not found
            newDyna.id = id
            try! realm.write { realm.add(newDyna) }
            _dyna = StateRealmObject(wrappedValue: newDyna)
        }
    }

    public var body: some View {
        if isVisible {
            viewHolder()
                .frame(width: CGFloat(dyna.width), height: CGFloat(dyna.height))
                .offset(x: CGFloat(dyna.x) + (isDragging ? dragOffset.width : 0), y: CGFloat(dyna.y) + (isDragging ? dragOffset.height : 0))
                .gesture(gestureDynaDrag())
        }
    }

    public func gestureDynaDrag() -> some Gesture {
        DragGesture()
            .onChanged { value in
                main {
                    isDragging = true
                    if useOriginal {
                        originOffPos = CGPoint(x: self.dyna.x, y: self.dyna.y)
                        useOriginal = false
                    }
                    updateDynaPosition(translation: value.translation)
                }
            }
            .onEnded { value in
                main {
                    updateDynaPosition(translation: value.translation)
                    useOriginal = true
                    isDragging = false
                }
            }
    }

    // MARK: THIS IS HOW YOU SAVE A @StateRealmObject
    private func updateDynaPosition(translation: CGSize) {
        if let thawedDyna = dyna.thaw(), let realm = thawedDyna.realm {
            try! realm.write {
                thawedDyna.x = originOffPos.x + translation.width
                thawedDyna.y = originOffPos.y + translation.height
            }
        }
    }
}
