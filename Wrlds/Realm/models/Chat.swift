//
//  Chat.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import RealmSwift

@objcMembers class Chat: Object {
    dynamic var id: String = UUID().uuidString
    dynamic var senderId: String?
    dynamic var senderName: String?
    dynamic var senderImage: String?
    dynamic var chatId: String?
    dynamic var receiverId: String?
    dynamic var messageText: String?
    dynamic var timestamp: String = getTimeStamp()

    override static func primaryKey() -> String? {
        return "id"
    }
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
