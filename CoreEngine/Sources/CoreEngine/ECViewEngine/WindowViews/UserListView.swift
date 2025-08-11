//
//  UserListView.swift
//  CoreEngine
//
//  Created by Charles Romeo on 7/10/25.
//
import RealmSwift
import SwiftUI

public struct UsersListView: View {
    @AppStorage("currentRoomId") public var currentRoomId: String = ""
    @ObservedResults(UserInRoom.self) public var allUsers
    
    public var roomUsers: Results<UserInRoom> {
        return allUsers
            .filter("roomId == %@", currentRoomId)
    }

    public init() {}
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "person.3.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("Users In Room")
                    .font(.title3).bold()
                Spacer()
                Text("\(roomUsers.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 2)
            
            if roomUsers.isEmpty {
                HStack {
                    Image(systemName: "person.crop.circle.badge.xmark")
                        .foregroundColor(.gray)
                    Text("No users in this room yet.")
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding(.top, 40)
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(roomUsers, id: \.id) { user in
                            UserCard(user: user)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemGray6))
                .shadow(color: .black.opacity(0.07), radius: 6, y: 2)
        )
    }
}

public struct UserCard: View {
    public let user: UserInRoom

    public var body: some View {
        HStack(spacing: 12) {
            // Avatar: Use a placeholder if no avatar
            if let url = URL(string: user.guestId ?? ""), !(user.guestId ?? "")!.isEmpty {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Circle()
                        .fill(Color.blue.opacity(0.18))
                        .overlay(Text((user.guestName ?? "vistor").first?.uppercased() ?? "?")
                            .font(.title2).foregroundColor(.blue))
                }
                .frame(width: 42, height: 42)
                .clipShape(Circle())
                .shadow(radius: 2)
            } else {
                Circle()
                    .fill(Color.blue.opacity(0.18))
                    .frame(width: 42, height: 42)
                    .overlay(
                        Text((user.guestName ?? "vistor").first?.uppercased() ?? "?")
                            .font(.title2).foregroundColor(.blue)
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(user.guestId ?? user.guestId)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(user.status)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 1)
            }
            Spacer()
            // Online indicator or action buttons can go here
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
        )
    }
}
