//
//  WindowHolder.swift
//  CoreEngine
//
//  Created by Charles Romeo on 8/13/25.
//

import SwiftUI

public struct WindowManagerView<C: View>: View {
    @ViewBuilder public let viewHolder: () -> C
    public init(_ viewHolder: @escaping () -> C) {
        self.viewHolder = viewHolder
    }
    // (Removed an unused NavWindowController() here — it never rendered a
    // stack but still subscribed to the NavStack channel and raced the
    // real "master" window on its persisted Realm row.)
    @StateObject public var fusedRoom = FusedRoom()
    @AppStorage("isLoggedIn") public var isLoggedIn: Bool = false
    @AppStorage("currentUserId") public var currentUserId: String = ""
    @AppStorage("currentRoomId") public var currentRoomId: String = ""
    
    @State public var isExpanded: Bool = false
    @State public var scale: CGFloat = 2
    @State public var lastScale: CGFloat = 1.0
    @State public var viewOffset: CGSize = .zero
    @GestureState public var dragState: CGSize = .zero
    
    public let orbitRadius: CGFloat = 306
    @State public var previousSelectedFeature: FusedRoomFeature = .home
    @State public var selectedFeature: FusedRoomFeature = .home
    @State public var showingFeature: Bool = false
    
    public let featureIcons: [(icon: String, feature: FusedRoomFeature, label: String)] = [
        ("door.right.hand.open", .open, "Open"),
        ("bubble.left.and.bubble.right.fill", .chat, "Chat"),
//        ("person.3.fill", .users, "Users"),
        ("profile", .profile, "Profile"),
        ("gearshape.fill", .settings, "Settings"),
        ("wrench", .widgets, "Widgets"),
        ("home", .home, "Home")
    ]
    
    public var body: some View {
        ZStack {
            // Center Room Window
            if isExpanded {
                ZStack(alignment: .topTrailing) {
                    self.viewHolder()
                        .environmentObject(fusedRoom)
                        .padding()
                        .background(isExpanded ? RoundedRectangle(cornerRadius: 30).fill(.ultraThinMaterial) : nil)
                        .shadow(radius: 12)
                }
                .frame(width: 369 * scale, height: 432 * scale)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isExpanded)
                .zIndex(100)
            }
            
            // Orbit Buttons
            ForEach(0..<featureIcons.count, id: \.self) { i in
                let (icon, feature, label) = featureIcons[i]
                Image(systemName: isExpanded ? icon : "door.right.hand.closed")
                    .resizable()
                    .frame(width: 35 * scale, height: 35 * scale)
                    .foregroundColor(i == 0 ? (isExpanded ? .red.opacity(0.5) : .green.opacity(0.5)) : .yellow.opacity(0.5))
                    .onTapAnimation {
                        if feature == .open {
                            withAnimation { isExpanded.toggle() }
                            selectedFeature = .home
                            showingFeature = false
                        } else if feature == self.selectedFeature {
                            selectedFeature = .home
                            showingFeature = false
                        } else {
                            selectedFeature = feature
                            withAnimation {
                                showingFeature = true
                                if !isExpanded {
                                    isExpanded = true
                                }
                                
                            }
                        }
                       
                    }
                    .background(Circle().fill(Color.purple).frame(width: 50 * scale, height: 50 * scale))
                    .zIndex(i == 0 ? 50.0 : 25.0)
                    .offset(x: isExpanded ? cos(CGFloat(i) / CGFloat(featureIcons.count) * 2 * .pi) * orbitRadius * scale : 0,
                        y: isExpanded ? sin(CGFloat(i) / CGFloat(featureIcons.count) * 2 * .pi) * orbitRadius * scale : 0)
                    .animation(Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(i == 0 ? 0 : 0.1 * Double(i)), value: isExpanded)
            
            }

            
        }
        .offset(x: viewOffset.width + dragState.width, y: viewOffset.height + dragState.height)
        .gesture(
            DragGesture()
                .updating($dragState) { value, state, _ in state = value.translation }
                .onEnded { value in viewOffset = CGSize(width: viewOffset.width + value.translation.width, height: viewOffset.height + value.translation.height) }
        )
        .frame(width: (orbitRadius * 2 + 111) * scale, height: (orbitRadius * 2 + 369) * scale)
        .onAppear {
            isExpanded = false
            if !self.isLoggedIn {
                self.selectedFeature = .settings
            }
            
        }
    }
}


public class CanvasViewHolder: ObservableObject, Identifiable {

    @Published public var id: String
    public var mainBuilder: () -> AnyView
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
    
    public init<V: View>(id: String, mainBuilder: @escaping () -> V = {EmptyView()}) {
        self.id = id
        self.mainBuilder = { AnyView(mainBuilder()) }
        
    }

    public init(id: String, mainBuilder: AnyView, sidebarBuilder: AnyView) {
        self.id = id
        self.mainBuilder = { mainBuilder }
    }

    public init(id: String, mainBuilder: @escaping () -> AnyView) {
        self.id = id
        self.mainBuilder = mainBuilder
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
    
    public func toggleMinimized() { isMinimized = !isMinimized }
    public func toggleFullScreen() { isFullScreen = !isFullScreen }
}
