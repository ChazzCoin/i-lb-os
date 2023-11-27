//
//  ChatUI.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI
import FirebaseDatabase

struct Message: Identifiable {
    let id: Int
    let text: String
    let isCurrentUser: Bool
    let timestamp: String
}

// Define a custom color extension to match the AOL/AIM theme
extension Color {
    static let AOLGray = Color(red: 0.82, green: 0.84, blue: 0.86)
    static let AIMYellow = Color(red: 1.0, green: 0.71, blue: 0.0)
}

struct ChatView: View {
    @State var chatId: String
    @State private var messageText = ""
    @State private var messages: [String: Chat?] = [:]
    @State private var lastMessageId: String?
    
    @State private var isSidebarVisible = false
    
    let chatRef = fireGetReference(dbPath: DatabasePaths.chat)
    let chatty = Database
        .database()
        .reference()
        .child(DatabasePaths.chat.rawValue)
    
    func observeChat() {
        self.chatRef.child(chatId).fireObserver { snapshot in
            let mapped: [String:Any] = snapshot.toHashMap()
            for (_, value) in mapped {
                let singleChat: Chat? = toChat(from: value as? [String: Any] ?? [:])
                if singleChat != nil && !messages.keys.contains(singleChat!.timestamp) {
                    messages[singleChat!.timestamp] = singleChat
                }
            }
            sortAndResetMessages()
        }
    }
    
    var mainContentView: some View {
        VStack {
            // Messages list
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(messages.values.compactMap { $0 }), id: \.id) { chat in
                            ChatMessageRow(chat: chat)
                        }
                    }
                }.onChange(of: lastMessageId) { _ in
                    if let lastMessageId = lastMessageId {
                        scrollViewProxy.scrollTo(lastMessageId, anchor: .bottom)
                    }
                }
            }
            
            .padding(.horizontal)

            // Text input
            HStack(spacing: 15) {
                TextField("Type a message...", text: $messageText)
                    .padding(.horizontal)
                    .frame(height: 44)
                    .background(Color(UIColor.systemGray6))
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
        .background(Color.white)
    }
    var sidebarView: some View {
        BuddyListView()
    }
    var body: some View {
        
        // Main Content and Sidebar
        ZStack(alignment: .leading) {
            mainContentView

            if isSidebarVisible {
                sidebarView
                    .frame(width: 250)
                    .transition(.move(edge: .leading))
            }
        }
        .navigationBarTitle("SOL Chat", displayMode: .inline)
        .navigationBarItems(leading: Button(action: {
            withAnimation {
                isSidebarVisible.toggle()
            }
        }) {
            Image(systemName: "line.horizontal.3")
        })
        .onAppear() {
            observeChat()
        }
    }
    
    

    func sendMessage() {
        let newMessage = Chat()
        newMessage.chatId = chatId
        newMessage.messageText = messageText
        newMessage.senderId = "me"
        newMessage.timestamp = getTimeStamp()
        firebaseDatabase { db in
            db.child(DatabasePaths.chat.rawValue).child(chatId).child(newMessage.id).setValue(newMessage.toDictionary())
        }
        messageText = ""
    }

    func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
    
    func sortedMessagesByTimestamp() -> [(key: String, value: Chat?)] {
        return messages.sorted { first, second in
            // Assuming the keys are in a format that can be compared directly
            return first.key < second.key
        }
    }
    
    func sortAndResetMessages() {
        let sortedArray = messages.sorted { first, second in
            // Assuming the keys are in a format that can be compared directly
            return first.key < second.key
        }
        
        // Convert the sorted array back to a dictionary
        var sortedDictionary = [String: Chat?]()
        for (key, value) in sortedArray {
            sortedDictionary[key] = value
        }

        // Reset the messages with sorted dictionary
        messages = sortedDictionary
    }


}

struct ChatMessageRow: View {
    let chat: Chat
    var isCurrentUser: Bool {
        chat.senderId == "me"
    }

    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            MessageBubbleView(text: chat.messageText ?? "", isCurrentUser: isCurrentUser)
            if !isCurrentUser {
                Spacer()
            }
        }
    }
}

struct MessageBubbleView: View {
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

//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView(chatId: "")
//    }
//}

