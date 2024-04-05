//
//  Chat.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import RealmSwift

class Chat: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var senderId: String?
    @Persisted var senderName: String?
    @Persisted var senderImage: String?
    @Persisted var chatId: String?
    @Persisted var receiverId: String?
    @Persisted var messageText: String?
    @Persisted var timestamp: String = getCurrentTimestamp()

}

extension Chat {
    func toDictionary() -> [String: Any?] {
            return [
                "id": id,
                "senderId": senderId,
                "senderName": senderName,
                "senderImage": senderImage,
                "chatId": chatId,
                "receiverId": receiverId,
                "messageText": messageText,
                "timestamp": timestamp
            ]
        }
}

func toChat(from dictionary: [String: Any]) -> Chat {
    let chat = Chat()
    chat.id = dictionary["id"] as? String ?? UUID().uuidString
    chat.senderId = dictionary["senderId"] as? String
    chat.senderName = dictionary["senderName"] as? String
    chat.senderImage = dictionary["senderImage"] as? String
    chat.chatId = dictionary["chatId"] as? String
    chat.receiverId = dictionary["receiverId"] as? String
    chat.messageText = dictionary["messageText"] as? String
    chat.timestamp = dictionary["timestamp"] as? String ?? ""
    return chat
}
