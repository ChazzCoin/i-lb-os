//
//  ChatUI.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI
import FirebaseDatabase
import Combine
import RealmSwift

public struct ChatView: View {
    
    public init() {}
    
    @AppStorage("currentRoomId") public var currentRoomId: String = ""

    @State public var messageText = ""
    
    @StateObject public var CHAT = ChatObserver()
    @StateObject public var keyboardResponder = KeyboardResponder()
    @State public var isSidebarVisible = false
    public let realmInstance = realm()
    @State public var delaySeconds = 2.0
    @State public var isReloading = false


    public var mainContentView: some View {
        VStack {
            // Messages list
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(CHAT.roomMessages) { chat in
                            ChatMessageRow(chat: chat)
                        }
                    }
                }.onChange(of: CHAT.roomMessages.count) { _ in
                    if let lastChat = CHAT.roomMessages.last {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastChat.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            .padding(.horizontal)

            // Text input
            HStack(spacing: 15) {
                TextField("Type a message...", text: $messageText)
                    .padding(.horizontal)
                    .frame(height: 44)
                    .foregroundColor(Color.white)
//                    .background(Color.secondaryBackground)
                    .cornerRadius(22)

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.blue)
                        .frame(width: 44, height: 44)
                        .padding(5)
                }
            }
            .padding(.horizontal)
        }
        .isLoading(showLoading: $isReloading)
        .background(Color.white)
        .onTap {
            self.keyboardResponder.safeHideKeyboard()
        }
        .onChange(of: currentRoomId) { newValue in
            self.CHAT.start(chatId: newValue)
        }
        .onAppear() {
            self.CHAT.start(chatId: currentRoomId)
        }
        .onDisappear() {
            self.CHAT.stop()
        }
    }
    public var sidebarView: some View {
//        RoomUserList()
        EmptyView()
    }
    
    public var body: some View {
        
        // Main Content and Sidebar
        ZStack(alignment: .leading) {
            
            mainContentView

            if isSidebarVisible {
                sidebarView
                    .frame(width: 300)
                    .transition(.move(edge: .leading))
            }
            
        }
        .navigationBarTitle("Chat", displayMode: .inline)
        .navigationBarItems(leading: Button(action: {
            withAnimation {
                isSidebarVisible.toggle()
            }
        }) {
            Image(systemName: "line.horizontal.3")
        })

    }
    

    public func sendMessage() {
        
        let newMessage = Chat()
        newMessage.chatId = currentRoomId
        newMessage.messageText = messageText
        newMessage.senderId = UserTools.currentUserId
        newMessage.senderName = UserTools.currentUserId
        newMessage.senderImage = ""
        newMessage.timestamp = getCurrentTimestamp()

        firebaseDatabase { db in
            db.child(DatabasePaths.chat.rawValue)
                .child(currentRoomId)
                .child(newMessage.id)
                .setValue(newMessage.toDict())
        }

        messageText = ""
    }

    

}

struct ChatMessageRow: View {
    let chat: Chat
    var isCurrentUser: Bool {
        chat.senderId == UserTools.currentUserId ?? ""
    }
    
    func toHumanReadableTime(ts: String) -> String {
        return convertTimestampToReadableDate(timestamp: ts) ?? "unknown time"
    }
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            MessageBubbleView(
                text: chat.messageText ?? "",
                isCurrentUser: isCurrentUser,
                userName: chat.senderName ?? "Anon",
                dateTime: toHumanReadableTime(ts: chat.timestamp)
            )
            if !isCurrentUser {
                Spacer()
            }
        }
    }
}

struct MessageBubbleView1: View {
    var text: String
    var isCurrentUser: Bool

    var body: some View {
        Text(text)
            .padding(10)
            .foregroundColor(isCurrentUser ? Color.white : Color.black)
            .background(isCurrentUser ? Color.blue : Color(UIColor.systemGray5))
            .cornerRadius(10)
            .frame(maxWidth: 250, alignment: isCurrentUser ? .trailing : .leading)
    }
}

struct MessageBubbleView: View {
    var text: String
    var isCurrentUser: Bool
    var userName: String
    var dateTime: String

    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
            if !isCurrentUser {
                Text(userName)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Text(text)
                .padding(10)
                .foregroundColor(isCurrentUser ? Color.white : Color.white)
                .background(isCurrentUser ? Color.blue : Color.green)
                .cornerRadius(10)

            Text(dateTime)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: 250, alignment: isCurrentUser ? .trailing : .leading)
    }
}


//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageBubbleView(text: "Hey hey", isCurrentUser: false, userName: "Chazz Romeo", dateTime: "3:22pm")
//    }
//}

