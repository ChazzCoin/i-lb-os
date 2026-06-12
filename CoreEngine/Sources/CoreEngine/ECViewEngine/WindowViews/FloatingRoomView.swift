//
//  FloatingRoomView.swift
//  CoreEngine
//
//  Created by Charles Romeo on 7/10/25.
//

import SwiftUI

public enum FusedRoomFeature: Int {
    case open, home, chat, users, profile, settings, widgets // Add more as needed
}


public struct FloatingFusedRoomManagerView: View {
    
    public init() {}
    // (Removed an unused NavWindowController() — see WindowHolder.swift.
    // It only appeared in commented-out code but still subscribed and
    // raced the real "master" window's persisted geometry.)
    @StateObject public var fusedRoom = FusedRoom()
    @AppStorage("isLoggedIn") public var isLoggedIn: Bool = false
    @AppStorage("currentUserId") public var currentUserId: String = ""
    @AppStorage("currentRoomId") public var currentRoomId: String = ""
    
    @State public var isExpanded: Bool = true
    @State public var scale: CGFloat = 1.2
    @State public var lastScale: CGFloat = 1.0
    @State public var viewOffset: CGSize = .zero
    @GestureState public var dragState: CGSize = .zero
    
    public let orbitRadius: CGFloat = 250
    @State public var previousSelectedFeature: FusedRoomFeature = .home
    @State public var selectedFeature: FusedRoomFeature = .home
    @State public var showingFeature: Bool = false
    
    public let featureIcons: [(icon: String, feature: FusedRoomFeature, label: String)] = [
        ("door.right.hand.open", .open, "Open"),
        ("bubble.left.and.bubble.right.fill", .chat, "Chat"),
        ("person.3.fill", .users, "Users"),
        ("profile", .profile, "Profile"),
        ("gearshape.fill", .settings, "Settings"),
        ("wrench", .widgets, "Widgets"),
        ("home", .home, "Home")
    ]
    
    public var body: some View {
        ZStack {
            // Center Room Window
            if isExpanded {
                FusedRoomFeatureSheet(feature: selectedFeature, isPresented: $showingFeature)
                    .environmentObject(fusedRoom)
//                    .environmentObject(navTools)
                    .frame(width: 350 * scale, height: 350 * scale)
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
                    .foregroundColor(i == 0 ? (isExpanded ? .red : .green) : .yellow)
                    .onTapAnimation {
                        if feature == .open {
//                            navTools.mainState = .open
//                            navTools.navTo(viewId: MenuBarProvider.activity.tool.title)
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
//            navTools.getNavStackView()
            // Sheet for Subfeatures
//            if showingFeature && selectedFeature != .home {
//                FusedRoomFeatureSheet(feature: selectedFeature, isPresented: $showingFeature)
//                    .environmentObject(fusedRoom)
//                    .frame(width: 340 * scale, height: 420 * scale)
//                    .clipShape(RoundedRectangle(cornerRadius: 30))
//                    .shadow(radius: 20)
//                    .transition(.scale)
//                    .zIndex(150)
//                    .onTapGesture { withAnimation { showingFeature = false } }
//            }
            
        }
        .offset(x: viewOffset.width + dragState.width, y: viewOffset.height + dragState.height)
        .gesture(
            DragGesture()
                .updating($dragState) { value, state, _ in state = value.translation }
                .onEnded { value in viewOffset = CGSize(width: viewOffset.width + value.translation.width, height: viewOffset.height + value.translation.height) }
        )
        .frame(width: (orbitRadius * 2 + 100) * scale, height: (orbitRadius * 2 + 100) * scale)
        .onAppear {
            isExpanded = true
            if !self.isLoggedIn {
                self.selectedFeature = .settings
            }
            self.fusedRoom.startUp()
//            navTools.addView(
//                callerId: MenuBarProvider.activity.tool.title,
//                mainContent: { RoomChatView(fusedRoom: fusedRoom) },
//                sideContent: { EmptyView() }
//            )
//            navTools.addView(
//                callerId: MenuBarProvider.buddyList.tool.title,
//                mainContent: { UsersListView },
//                sideContent: { EmptyView() }
//            )
        }
    }
}

// MARK: - Center "Home" RoomWindow View

public struct RoomWindowView: View {
    @EnvironmentObject public var fusedRoom: FusedRoom

    @Binding public var selectedFeature: FusedRoomFeature
    @State public var enteredRoomId = ""
    @State public var isLoading = false
    @State public var statusMsg: String?
    
//    public init() {}

    public var body: some View {
        VStack(spacing: 14) {
            if !fusedRoom.USER.currentRoomId.isEmpty {
                // Not in room: Entry
                Text("Enter or Create a Room")
                    .font(.headline)
                HStack {
                    TextField("Room ID", text: $enteredRoomId)
                        .padding(6)
                        .textFieldStyle(.roundedBorder)
                    Button("Go") {
                        guard !enteredRoomId.isEmpty else { return }
                        isLoading = true
                        fusedRoom.enterOrCreateRoom(
                            withId: enteredRoomId
                        ) { didCreate, error in
                            isLoading = false
                            if let error = error {
                                statusMsg = error.localizedDescription
                            } else {
                                statusMsg = didCreate ? "Room created!" : "Entered room."
                            }
                        }
                        enteredRoomId = ""
                    }
                }
                if let statusMsg = statusMsg {
                    Text(statusMsg)
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.top, 2)
                }
            } else {
                // In a room: Show room info & leave/switch
                VStack(spacing: 8) {
                    Label("Room ID:", systemImage: "number")
                    Text(fusedRoom.currentRoomId)
                        .font(.title2)
                        .bold()
                    if let room = fusedRoom.realmInstance.object(ofType: Room.self, forPrimaryKey: fusedRoom.currentRoomId) {
                        Text(room.title.isEmpty ? "Untitled" : room.title)
                            .font(.headline)
                        Text(room.ownerName.isEmpty ? "" : "Owner: \(room.ownerName)")
                            .font(.caption)
                        Text("Status: \(room.status.isEmpty ? "N/A" : room.status)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                Button("Leave Room") {
                    fusedRoom.stop()
                }
                .padding(.top, 6)
                .foregroundColor(.red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 22).fill(Color(.systemGray6)))
        .onAppear() {
            self.fusedRoom.startUp()
        }
    }
}

// MARK: - Overlay for Features (Chat, Users, etc.)

public struct FusedRoomFeatureSheet: View {
    public let feature: FusedRoomFeature
    @Binding public var isPresented: Bool
    @EnvironmentObject public var fusedRoom: FusedRoom
    @EnvironmentObject public var navTools: NavWindowController

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                switch feature {
                    case .chat:
                        RoomChatView(fusedRoom: fusedRoom)
                    case .users:
                        UsersListView()
                    case .settings:
                        CoreSignUpView()
                            .zIndex(100)
                    case .home:
                        RoomWindow()
                    default:
                        RoomWindow()
                }
            }
            
            .padding()
            .background(RoundedRectangle(cornerRadius: 30).fill(.ultraThinMaterial))
            .shadow(radius: 12)
            
            // Exit Button (top-right, always visible)
//            Button(action: {
//                isPresented = false
//            }) {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.secondary)
//                    .background(Color.red.opacity(0.5)) // Tappable area
//                    .font(.system(size: 26, weight: .bold))
//                    .padding(8)
//            }
//            .offset(CGSize(width: 0, height: -50))
//            .padding(8)
//            .accessibilityLabel("Close")
        }
    }
}


// MARK: - Helper: Tooltip

public struct TooltipView: View {
    public let label: String
    public var body: some View {
        Text(label)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(radius: 1)
    }
}
