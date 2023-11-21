//
//  ChatUI.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI

struct Message: Identifiable {
    let id: Int
    let text: String
    let isCurrentUser: Bool
    let timestamp: String
}

struct ChatView: View {
    @State private var messageText = ""
    @State private var messages: [Message] = []

    var body: some View {
        VStack {
            // Messages list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        HStack {
                            if message.isCurrentUser {
                                Spacer()
                                MessageBubbleView(text: message.text, isCurrentUser: true)
                            } else {
                                MessageBubbleView(text: message.text, isCurrentUser: false)
                                Spacer()
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
        .navigationBarTitle("SOL Chat", displayMode: .inline)
    }

    func sendMessage() {
        let newMessage = Message(id: messages.count + 1, text: messageText, isCurrentUser: true, timestamp: getCurrentTime())
        messages.append(newMessage)
        messageText = ""
    }

    func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
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

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}

