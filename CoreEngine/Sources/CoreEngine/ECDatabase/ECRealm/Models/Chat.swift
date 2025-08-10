//
//  Chat.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import RealmSwift


public class ChatMessage: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var roomId: String = ""
    @Persisted public var senderId: String?
    @Persisted public var senderName: String?
    @Persisted public var senderImage: String?
    @Persisted public var chatId: String?
    @Persisted public var receiverId: String?
    @Persisted public var messageText: String?
    @Persisted public var text: String = ""
    @Persisted public var uri: String = ""
    @Persisted public var reaction: String = ""
    @Persisted public var status: String = ""
    @Persisted public var timestamp: String = getCurrentTimestamp()

}

public extension ChatMessage {
    public func toDict() -> [String: String?] {
        return [
            "id": id,
            "roomId": roomId,
            "senderId": senderId,
            "senderName": senderName,
            "senderImage": senderImage,
            "chatId": chatId,
            "receiverId": receiverId,
            "messageText": messageText,
            "text": text,
            "uri": uri,
            "reaction": reaction,
            "status": status,
            "timestamp": timestamp
        ]
    }
}

public func toChatMessage(from dictionary: [String: Any]) -> ChatMessage {
    let chat = ChatMessage()
    chat.id = dictionary["id"] as? String ?? UUID().uuidString
    chat.roomId = dictionary["roomId"] as? String ?? ""
    chat.senderId = dictionary["senderId"] as? String
    chat.senderName = dictionary["senderName"] as? String
    chat.senderImage = dictionary["senderImage"] as? String
    chat.chatId = dictionary["chatId"] as? String
    chat.receiverId = dictionary["receiverId"] as? String
    chat.messageText = dictionary["messageText"] as? String
    chat.text = dictionary["text"] as? String ?? ""
    chat.uri = dictionary["uri"] as? String ?? ""
    chat.reaction = dictionary["reaction"] as? String ?? ""
    chat.status = dictionary["status"] as? String ?? ""
    chat.timestamp = dictionary["timestamp"] as? String ?? ""
    return chat
}
