//
//  RoomWindow.swift
//  CoreEngine
//
//  Created by Charles Romeo on 7/10/25.
//

import SwiftUI

public struct RoomWindow: View {
    @EnvironmentObject var fusedRoom: FusedRoom
    @AppStorage("isLoggedIn") public var isLoggedIn: Bool = false
    @AppStorage("currentUserId") public var currentUserId: String = ""
    @AppStorage("currentRoomId") public var currentRoomId: String = ""
    @State private var enteredRoomId = ""
    @State private var isLoading = false
    @State private var statusMsg: String?
    
    public var body: some View {
        VStack(spacing: 14) {
            if fusedRoom.roomId.isEmpty {
                // Not in room: Entry
                Text("Enter or Create a Room").font(.headline)
                HStack {
                    TextField("Room ID", text: $enteredRoomId)
                        .padding(6)
                        .textFieldStyle(.roundedBorder)
                    Button("Enter") {
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
                    .disabled(isLoading)
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
                    Text(fusedRoom.roomId).font(.title2).bold()
                    if let room = fusedRoom.room {
                        Text(room.title.isEmpty ? "Untitled" : room.title).font(.headline)
                        Text(room.ownerName.isEmpty ? "" : "Owner: \(room.ownerName)").font(.caption)
                        Text("Status: \(room.status.isEmpty ? "N/A" : room.status)").font(.caption2).foregroundColor(.secondary)
                    }
                    Text("Users: \(fusedRoom.usersInRoom.count)").font(.caption)
                }
                Button("Leave Room") {
                    fusedRoom.leaveRoom()
                    statusMsg = nil
                }
                .padding(.top, 6)
                .foregroundColor(.red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 22).fill(Color(.systemGray6)))
    }
}

// MARK: - Room Status Views

public struct CurrentRoomStatusBox: View {
    @EnvironmentObject public var fusedRoom: FusedRoom
    @State public var roomid: String = ""
    @State public var title: String = ""
    @State public var ownerName: String = ""
    @State public var status: String = ""
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("In Room:", systemImage: "door.right.hand.open")
                .font(.headline)
            Text("Room ID: \(self.roomid)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Title: \(self.title)")
            Text("Owner: \(self.ownerName)")
            Text("Status: \(self.status)")
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 18)
            .fill(Color(.systemGray6))
            .shadow(color: .black.opacity(0.07), radius: 6, y: 2))
        .frame(maxWidth: 340)
        .onAppear() {
            self.roomid = self.fusedRoom.roomId
            self.title = self.fusedRoom.roomTitle
            self.ownerName = self.fusedRoom.roomOwner
            self.status = self.fusedRoom.roomStatus
        }
    }
}

public struct NoRoomStatusBox: View {
    public var body: some View {
        HStack {
            Image(systemName: "door.left.hand.open")
                .foregroundColor(.orange)
            Text("No room joined.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 18)
            .fill(Color(.systemGray6))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2))
        .frame(maxWidth: 340)
    }
}

// MARK: - Child Content

public struct RoomContentView: View {
    @EnvironmentObject public var fusedRoom: FusedRoom
    public let myUserId: String
    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Example: Show users in the room (optional)
            if fusedRoom.usersInRoom.count > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(fusedRoom.usersInRoom, id: \.id) { user in
                            VStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.4))
                                    .frame(width: 32, height: 32)
                                Text(user.name ?? user.id)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                }
            }

            // Chat view (can be replaced with your full-featured chat)
//            RoomChatView(fusedRoom: fusedRoom, myUserId: myUserId)
//                .frame(maxHeight: 420)
        }
        .padding(.top)
    }
}

