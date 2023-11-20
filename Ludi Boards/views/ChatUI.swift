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
            List(messages) { message in
                HStack {
                    if message.isCurrentUser {
                        Spacer()
                    }
                    VStack(alignment: .leading) {
                        Text(message.text)
                            .padding()
                            .background(message.isCurrentUser ? Color.blue : Color.gray)
                            .cornerRadius(10)
                        Text(message.timestamp)
                            .font(.caption)
                    }.background(Color.black)
                    if !message.isCurrentUser {
                        Spacer()
                    }
                }
            }
            .frame(minHeight: 200, maxHeight: 400)

            // Text input
            HStack {
                TextField("Type a message...", text: $messageText)
                    .frame(height: 50)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                }.frame(height: 50)
//                .padding()
            }
        }.background(Color.white)
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

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}

