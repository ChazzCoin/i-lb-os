//
//  ParticipantsO.swift
//  CoreEngine
//
//  Created by Charles Romeo on 8/10/25.
//

import SwiftUI
import RealmSwift
import FirebaseDatabase

// MARK: - Firebase path helper
public enum FirePaths {
    static func participants(roomId: String, sessionId: String) -> String {
        "participants/\(roomId)/\(sessionId)"
    }
}

// MARK: - Observable controller
public final class ParticipantsController: ObservableObject {
    // Public, bindable state
    @Published public private(set) var participants: [String: InteractionParticipant] = [:] // userId -> participant
    @Published public private(set) var total: Int = 0
    @Published public private(set) var ready: Int = 0
    @Published public private(set) var allReady: Bool = false

    // Scope
    @AppStorage("currentUserId", store: UserDefaults(suiteName: "worlds")) public var currentUserId: String = ""

    public private(set) var roomId: String = ""
    public private(set) var sessionId: String = ""

    // Realtime + Realm glue
    private let fused = FusedRealmFire<InteractionParticipant>()
    private var baseRef = Database.database().reference()
    private var nodeRef: DatabaseReference { baseRef.child(FirePaths.participants(roomId: roomId, sessionId: sessionId)) }

    public init() {}

    // MARK: - Lifecycle
    public func start(roomId: String, sessionId: String) {
        self.roomId = roomId
        self.sessionId = sessionId

        // Point FusedRealmFire to the collection node
        fused.setReference { ref in
            ref.child(FirePaths.participants(roomId: roomId, sessionId: sessionId))
        }

        // Observe children for add/change/remove
        fused.observeFire(
            onAdded: { [weak self] item in self?.applyUpsert(item) },
            onChange: { [weak self] item in self?.applyUpsert(item) },
            onDelete: { [weak self] item in self?.applyDelete(item) }
        )
    }

    public func stop() {
        fused.stop()
        DispatchQueue.main.async {
            self.participants.removeAll()
            self.recompute()
        }
    }

    // MARK: - Public API (mutations)
    public func join(userId: String? = nil,
                     userName: String,
                     imgUrl: String = "",
                     widgetType: WidgetType,
                     widgetId: String)
    {
        let uid = userId ?? currentUserId
        var p = InteractionParticipant()
        p.id = uid            // make the participant’s PK = userId (stable key)
        p.userId = uid
        p.roomId = roomId
        p.widgetId = widgetId
        p.sessionId = sessionId
        p.userName = userName
        p.imgUrl = imgUrl
        p.widgetType = widgetType.rawValue
        p.isActive = true
        p.isReady = false
        p.role = "member"
        p.joinedAt = getCurrentTimestamp()
        p.updatedAt = p.joinedAt

        // Optimistic local update
        applyUpsert(p)

        // Write to Firebase under /participants/{room}/{session}/{userId}
        nodeRef.child(uid).setValue(p.toFirebaseDict())
    }

    public func setReady(_ isReady: Bool, userId: String? = nil) {
        let uid = userId ?? currentUserId
        nodeRef.child(uid).updateChildValues([
            "isReady": isReady,
            "updatedAt": getCurrentTimestamp()
        ])
        // Optimistic local update
        if var local = participants[uid] {
//            local.isReady = isReady
//            local.updatedAt = getCurrentTimestamp()
            applyUpsert(local)
        }
    }

    public func toggleReady(userId: String? = nil) {
        let uid = userId ?? currentUserId
        let newVal = !(participants[uid]?.isReady ?? false)
        setReady(newVal, userId: uid)
    }

    public func setActive(_ active: Bool, userId: String? = nil) {
        let uid = userId ?? currentUserId
        nodeRef.child(uid).updateChildValues([
            "isActive": active,
            "updatedAt": getCurrentTimestamp()
        ])
        if var local = participants[uid] {
//            local.isActive = active
//            local.updatedAt = getCurrentTimestamp()
            applyUpsert(local)
        }
    }

    public func setRole(_ role: String, userId: String? = nil) {
        let uid = userId ?? currentUserId
        nodeRef.child(uid).updateChildValues([
            "role": role,
            "updatedAt": getCurrentTimestamp()
        ])
        if var local = participants[uid] {
//            local.role = role
//            local.updatedAt = getCurrentTimestamp()
            applyUpsert(local)
        }
    }

    /// Completely remove the participant node
    public func leave(userId: String? = nil) {
        let uid = userId ?? currentUserId
        nodeRef.child(uid).removeValue()
        // Optimistic local cleanup
        applyDeleteById(uid)
    }

    // MARK: - Internal reducers
    private func applyUpsert(_ p: DataSnapshot) {
        DispatchQueue.main.async {
            if let obj = p.toCoreObject(InteractionParticipant.self) {
                self.participants[obj.userId] = obj
                self.recompute()
            }
           
        }
    }
    private func applyUpsert(_ p: InteractionParticipant) {
        DispatchQueue.main.async {
            self.participants[p.userId] = p
            self.recompute()
           
        }
    }
    private func applyDelete(_ p: InteractionParticipant) {
        applyDeleteById(p.userId)
    }

    private func applyDeleteById(_ userId: String) {
        DispatchQueue.main.async {
            self.participants.removeValue(forKey: userId)
            self.recompute()
        }
    }

    private func recompute() {
        total = participants.values.filter { $0.isActive }.count
        ready = participants.values.filter { $0.isActive && $0.isReady }.count
        allReady = (total > 0 && ready == total)
    }
}
