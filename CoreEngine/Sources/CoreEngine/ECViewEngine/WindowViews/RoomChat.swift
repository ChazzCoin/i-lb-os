//
//  RoomChat.swift
//  CoreEngine
//
//  Created by Charles Romeo on 7/11/25.
//

import Foundation
import SwiftUI
import FirebaseDatabase
import Combine
import RealmSwift



public struct RoomChatView: View {
    
    public init(fusedRoom: FusedRoom) {
        self.fusedRoom = fusedRoom
    }
    
    @ObservedObject public var fusedRoom: FusedRoom
    @State public var text = ""
    @State public var showDocPicker: Bool = false
    @AppStorage("currentUserId") public var userId: String = ""
    @ObservedResults(ChatMessage.self) public var allMessages
    
    public var roomMessages: Results<ChatMessage> {
        return allMessages
            .filter("chatId == %@", fusedRoom.roomId)
            .sorted(byKeyPath: "timestamp", ascending: true)
    }
    
    // For scrolling to latest
    @Namespace public var bottomID
    
    public var body: some View {
        VStack(spacing: 0) {
            // Chat messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 6) {
                        ForEach(roomMessages) { msg in
                            ChatBubbleView(
                                message: msg,
                                isCurrentUser: msg.senderId == userId,
                                senderName: senderName(for: msg)
                            )
                            .id(msg.id)
                            .onTapAnimation {
                                print("Tapp")
                            }
                            .onLongPress {
                                print("LongTapp")
                            }
                        }
                        // Empty space for the keyboard
                        Spacer().frame(height: 10)
                        Color.clear.frame(height: 1).id(bottomID)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                }
                .background(Color(.systemGray6))
                .onChange(of: fusedRoom.messages.count) { _ in
                    // Scroll to bottom when new message arrives
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo(bottomID, anchor: .bottom)
                    }
                }
                .onAppear() {
                    // Scroll to bottom when new message arrives
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo(bottomID, anchor: .bottom)
                    }
                }
            }
            
            // Send bar
            HStack(spacing: 6) {
//                TextField("Type a message...", text: $text)
//                    .textFieldStyle(.roundedBorder)
//                    .padding(.vertical, 6)
//                    .onSubmit(send)
                GrowingTextEditor(
                    text: $text,
                    placeholder: "Type a message...",
                    minHeight: 30,
                    maxHeight: 150 // ~4-5 lines
                )
                .onSubmit(send)
                .padding(.vertical, 4)
//                .frame(minHeight: 30, maxHeight: 300)
                VStack {
                    Button(action: send) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(text.isEmpty ? .gray : .blue)
                            .rotationEffect(.degrees(45))
                            .padding(.horizontal, 8)
                    }
                    .disabled(text.isEmpty)
                    Button(action: {
                        showDocPicker = true
                    }) {
                        Image(systemName: CoreName.Icons.System.photo.name)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            
                    }
                    .disabled(true)
                }
            }
            .padding([.horizontal, .bottom], 10)
            .background(.thinMaterial)
        }
        .sheet(isPresented: $showDocPicker, content: {
            UploadChatAttachment()
        })
        .background(Color(.systemGray6))
    }
    
    public func send() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        fusedRoom.sendMessage(text: trimmed)
        text = ""
    }
    
    public func senderName(for msg: ChatMessage) -> String {
        // You can look up the user by id from fusedRoom.usersInRoom or allUsers
        if let user = fusedRoom.allUsers.first(where: { $0.id == msg.senderId }) {
            return user.userName ?? user.name ?? user.id
        }
        return msg.senderId ?? "visitor"
    }
}

// MARK: - Chat Bubble

public struct ChatBubbleView: View {
    public let message: ChatMessage
    public let isCurrentUser: Bool
    public let senderName: String

//    @AppStorage("currentUserId") public var userId: String = ""
    public var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
                if !isCurrentUser {
                    Text(senderName)
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .padding(.bottom, 1)
                }
                Text(message.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isCurrentUser ?
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.95), Color.purple.opacity(0.8)]),
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        : LinearGradient(
                            gradient: Gradient(colors: [Color.green.opacity(0.95), Color.blue.opacity(0.8)]),
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(18, corners: isCurrentUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                    .shadow(color: .black.opacity(0.10), radius: 2, y: 1)
                Text(shortTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.top, 1)
            }
            if !isCurrentUser { Spacer() }
        }
        .padding(isCurrentUser ? .leading : .trailing, 48)

    }

    public func shortTimestamp(_ ts: String?) -> String {
        guard let ts = ts, let double = Double(ts) else { return "" }
        let date = Date(timeIntervalSince1970: double)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Bubble Corners Helper

fileprivate extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}



struct GrowingTextEditor: View {
    @Binding var text: String
    let placeholder: String
    let minHeight: CGFloat
    let maxHeight: CGFloat
    
    @State private var dynamicHeight: CGFloat = 30 // Starting height

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Placeholder
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
            }
            // The editor
            TextEditor(text: $text)
                .frame(height: dynamicHeight)
                .padding(.horizontal, 4)
                .background(Color.clear)
//                .scrollContentBackground(.hidden)
                .onAppear {
                    UITextView.appearance().backgroundColor = .clear
                }
                .onChange(of: text) { _ in
                    recalculateHeight()
                }
        }
        .padding(.vertical, 2)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .onAppear {
            recalculateHeight()
        }
    }

    private func recalculateHeight() {
        let size = CGSize(width: UIScreen.main.bounds.width - 80, height: .infinity)
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .body)]
        let estimatedHeight = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).height + 28 // add padding
        
        dynamicHeight = min(max(estimatedHeight, minHeight), maxHeight)
    }
}
