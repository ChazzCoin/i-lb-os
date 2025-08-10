//
//  Participants.swift
//  CoreEngine
//
//  Created by Charles Romeo on 8/10/25.
//

import RealmSwift
import Foundation

public enum InteractionStatus: String, PersistableEnum {
    case idle, preparing, playing, paused, ended
}

public enum WidgetType: String, PersistableEnum {
    case binaural
    case breathwork
    case poll
    case timer
    case custom // fallback
}

// Per-user state inside a session
public class InteractionParticipant: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var userId: String = "" // which user?
    @Persisted public var roomId: String = "" // which room are they in?
    @Persisted public var widgetId: String = "" // which widget are they interacting with?
    @Persisted public var sessionId: String = "" // which session within the widget are they interacting with?
    
    @Persisted public var userName: String = ""
    @Persisted public var imgUrl: String = ""

    @Persisted public var widgetType: String = WidgetType.custom.rawValue
    @Persisted public var isReady: Bool = false
    @Persisted public var isActive: Bool = true
    @Persisted public var role: String = "member" // "host", "member", etc.

    @Persisted public var joinedAt: String = getCurrentTimestamp()
    @Persisted public var updatedAt: String = getCurrentTimestamp()
}

// MARK: - Firebase-safe payload for InteractionParticipant
extension InteractionParticipant {
    func toFirebaseDict() -> [String: Any] {
        return [
            "id": id,
            "userId": userId,
            "roomId": roomId,
            "widgetId": widgetId,
            "sessionId": sessionId,
            "userName": userName,
            "imgUrl": imgUrl,
            "widgetType": widgetType,
            "isReady": isReady,
            "isActive": isActive,
            "role": role,
            "joinedAt": joinedAt,     // already String in your model
            "updatedAt": updatedAt     // already String in your model
        ]
    }
}
