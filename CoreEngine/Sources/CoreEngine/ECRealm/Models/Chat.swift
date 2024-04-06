//
//  Chat.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import RealmSwift

public class Chat: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var senderId: String?
    @Persisted public var senderName: String?
    @Persisted public var senderImage: String?
    @Persisted public var chatId: String?
    @Persisted public var receiverId: String?
    @Persisted public var messageText: String?
    @Persisted public var timestamp: String = getCurrentTimestamp()

}

public extension Chat {
    public func toDictionary() -> [String: Any?] {
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

public func toChat(from dictionary: [String: Any]) -> Chat {
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
