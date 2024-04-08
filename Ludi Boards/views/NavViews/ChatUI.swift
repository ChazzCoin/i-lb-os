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
import CoreEngine

struct ChatView: View {
    @EnvironmentObject var boardEngineObject: BoardEngineObject
    @State var chatId: String = ""
    @State var currentUserId: String = ""
    @State private var messageText = ""
    @State private var messages: [String: Chat?] = [:]
    @State private var lastMessageId: String?
    
    @StateObject var ROOM = FirebaseRoomService()
    @StateObject var keyboardResponder = KeyboardResponder()
    
    @State private var isSidebarVisible = false
    
    private let realmInstance = realm()
    
    let delaySeconds = 2.0
    
    @State private var isReloading = false
    @State var cancellables = Set<AnyCancellable>()
    @State var chatRef = fireGetReference(dbPath: DatabasePaths.chat)
    
    @State var firebaseSubscription: DatabaseHandle? = nil
//    @State var currentUser = newRealm().getCurrentSolUser()
    
    
    
    @ObservedResults(Chat.self) var allMessages
    var roomMessages: Results<Chat> {
        return allMessages.filter("chatId == %@", self.boardEngineObject.currentActivityId)
    }
    // Function to sort chats by timestamp
    func sortChatsByTimestamp(chats: Results<Chat>) -> Results<Chat> {
        return chats.sorted(byKeyPath: "timestamp", ascending: true)
    }
    
    func observeChat() {
        stopObserver()
        firebaseSubscription = self.chatRef.child(boardEngineObject.currentActivityId).fireObserver { snapshot in
            if let results = snapshot.toLudiObjects(Chat.self, realm: self.realmInstance) {
                print("New Chat Messages: \(results)")
            }
        }
    }

    func stopObserver() {
        if let fs = firebaseSubscription {
            self.chatRef.removeObserver(withHandle: fs)
            firebaseSubscription = nil
        }
    }
    
    func reloader() {
        let results = realmInstance.findAllByField(Chat.self, field: "chatId", value: boardEngineObject.currentActivityId)
        var temp: [String:Chat] = [:]
        guard let r = results else {return}
        for i in r { temp[i.id] = i }
        messages = temp
        self.isReloading = false
    }
    
    var mainContentView: some View {
        VStack {
            // Messages list
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if !(roomMessages.realm?.isInWriteTransaction ?? true) {
                            ForEach(sortChatsByTimestamp(chats: roomMessages)) { chat in
                                ChatMessageRow(chat: chat)
                            }
                        }
                    }
                }.onChange(of: roomMessages.count) { _ in
                    
                    if !(roomMessages.realm?.isInWriteTransaction ?? true) {
                        if let lastChat = sortChatsByTimestamp(chats: roomMessages).last {
                            withAnimation {
                                scrollViewProxy.scrollTo(lastChat.id, anchor: .bottom)
                            }
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
                    .background(Color.secondaryBackground)
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
        .loading(isShowing: $isReloading)
        .background(Color.white)
        .onTap {
            self.keyboardResponder.safeHideKeyboard()
        }
        .onChange(of: boardEngineObject.currentActivityId) { _ in
            chatId = boardEngineObject.currentActivityId
            observeChat()
            self.ROOM.stopObserving()
            self.ROOM.startObserving(roomId: chatId)
        }
        .onAppear() {
            chatId = boardEngineObject.currentActivityId
            observeChat()
            self.ROOM.startObserving(roomId: chatId)
        }
        .onDisappear() {
            stopObserver()
            self.ROOM.stopObserving()
        }
    }
    var sidebarView: some View {
        RoomUserList()
            .environmentObject(self.boardEngineObject)
            .environmentObject(self.ROOM)
    }
    
    var body: some View {
        
        // Main Content and Sidebar
        ZStack(alignment: .leading) {
            
            mainContentView

            if isSidebarVisible {
                sidebarView
                    .frame(width: 300)
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
            
            safeFirebaseUserId { uId in
                self.currentUserId = uId
            }
            
            observeChat()
            
            CodiChannel.SESSION_ON_ID_CHANGE.receive(on: RunLoop.main) { onChange in
                if let temp = onChange as? ActivityChange {
                    if let roomId = temp.activityId {
                        if self.chatId != roomId {
                            print("Changing Chat ID: \(roomId)")
                            self.chatId = roomId
                            observeChat()
                        }
                    }
                }
            }.store(in: &cancellables)
            
        }
    }
    
    

    func sendMessage() {
        
//        UserTools.currentUserId
        
//        realmInstance.getCurrentSolUser() { user in
//            let newMessage = Chat()
//            newMessage.chatId = chatId
//            newMessage.messageText = messageText
//            newMessage.senderId = user.userId
//            newMessage.senderName = user.userName
//            newMessage.senderImage = user.imgUrl
//            newMessage.timestamp = getCurrentTimestamp()
//            
//            firebaseDatabase { db in
//                db.child(DatabasePaths.chat.rawValue)
//                    .child(chatId)
//                    .child(newMessage.id)
//                    .setValue(newMessage.toDict())
//            }
//            
//            messageText = ""
//        }
        
        
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
        chat.senderId == getFirebaseUserId()
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
                .background(isCurrentUser ? Color.blue : Color.primaryBackground)
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

