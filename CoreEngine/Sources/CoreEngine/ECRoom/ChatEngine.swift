//
//  ChatEngine.swift
//  CoreEngine
//
//  Created by Charles Romeo on 7/10/25.
//

import Foundation
import FirebaseDatabase
import Combine

protocol ChatServiceProtocol {
    func observeChatMessages(forChat chatId: String) -> AnyPublisher<[ChatMessage], Never>
    func sendChatMessage(_ message: ChatMessage, toChat chatId: String, completion: @escaping (Error?) -> Void)
    func createChat(with participants: [String], completion: @escaping (String?, Error?) -> Void)
    // ...other methods
}

final class ChatService: ChatServiceProtocol {
    private let db = Database.database().reference()
    
    func observeChatMessages(forChat chatId: String) -> AnyPublisher<[ChatMessage], Never> {
        let subject = PassthroughSubject<[ChatMessage], Never>()
        let messagesRef = db.child("messages").child(chatId)
        
        messagesRef.observe(.value) { snapshot in
            var messages = [ChatMessage]()
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any],
                   let message = toChatMessage(from: dict) as? ChatMessage {
                    messages.append(message)
                }
            }
            subject.send(messages.sorted(by: { $0.timestamp < $1.timestamp }))
        }
        return subject.eraseToAnyPublisher()
    }
    
    func sendChatMessage(_ message: ChatMessage, toChat chatId: String, completion: @escaping (Error?) -> Void) {
        let messageRef = db.child("messages").child(chatId).childByAutoId()
//        messageRef.setValue(message.toDict()) { error, _ in
//            completion(error)
//        }
        // Optionally update "lastChatMessage" in "chats" node as well.
    }
    
    func createChat(with participants: [String], completion: @escaping (String?, Error?) -> Void) {
        let chatRef = db.child("chats").childByAutoId()
        let chatData: [String: Any] = [
            "participants": Dictionary(uniqueKeysWithValues: participants.map { ($0, true) })
        ]
        chatRef.setValue(chatData) { error, _ in
            completion(chatRef.key, error)
        }
    }
}
