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
    
    @Published public var hasChanged: Bool = false
    @Published public var currentIsReady: Bool = false
    @Published public var currentHasJoined: Bool = false
    // Scope
    @AppStorage("currentUserId", store: UserDefaults(suiteName: "worlds")) public var currentUserId: String = ""
    @AppStorage("currentRoomId", store: UserDefaults(suiteName: "worlds")) public var currentRoomId: String = ""
    @AppStorage("currentWidgetId", store: UserDefaults(suiteName: "worlds")) public var currentWidgetId: String = ""
    @AppStorage("currentSessionId", store: UserDefaults(suiteName: "worlds")) public var currentSessionId: String = ""

    let realmInstance = newRealm()

    // Realtime + Realm glue
    private let fused = FusedRealmFire<InteractionParticipant>()
    private var baseRef = Database.database().reference()
    private var nodeRef: DatabaseReference { baseRef.child(FirePaths.participants(roomId: currentRoomId, sessionId: currentSessionId)) }

    public init() {}
    public var selfJoined: Bool { self.participants[self.currentUserId] != nil }
    public var selfReady: Bool { self.participants[self.currentUserId]?.isReady == true }
    public var allParticipantsReady: Bool { self.allReady }
    @ViewBuilder
    public func Display() -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Group Participation").font(.headline)
                Spacer()

                HStack(spacing: 6) {
                    
                    Image(systemName: self.allParticipantsReady ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(self.allParticipantsReady ? .green : .gray)
                    
                    Text("\(self.ready)/\(self.total) ready")
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }
            HStack {
                Label("Room", systemImage: "rectangle.3.group.bubble.left")
                Spacer()
                Text(currentRoomId.isEmpty ? "—" : currentRoomId)
                    .font(.callout.monospaced())
                    .foregroundStyle(.secondary)
            }
            HStack {
                Label("Session", systemImage: "rectangle.3.group.bubble.left")
                Spacer()
                Text(currentSessionId.isEmpty ? "—" : currentSessionId)
                    .font(.callout.monospaced())
                    .foregroundStyle(.secondary)
            }

            HStack {
                HStack(spacing: 12) {
                    Button {
                        // Join this session’s participants list
                        self.join(
                            userName: generateRandomName(), // or your own name source
                            widgetType: .binaural,
                            widgetId: "binaural-default"
                        )
                    } label: {
                        Label(self.selfJoined ? "Joined" : "Join Group", systemImage: "person.badge.plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(self.selfJoined)

                    if self.selfReady {
                        Button {
                            self.setReady(false)
                        } label: {
                            Label("Not Ready", systemImage: "xmark.seal")
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button {
                            self.setReady(true)
                        } label: {
                            Label("Ready!", systemImage: "checkmark.seal")
                        }
                        .buttonStyle(.bordered)
                        .disabled(self.hasChanged)
                    }

                    
                }
//                Spacer()

                
            }
            Divider()
            if !self.hasChanged && self.currentHasJoined {
                VStack(alignment: .leading, spacing: 8) {
                    if self.participants.isEmpty {
                        Text("No participants yet.")
                            .font(.subheadline).foregroundStyle(.secondary)
                    } else {
                        ForEach(
                            self.participants.values.sorted(by: { $0.userName < $1.userName }), id: \.userId
                        ) { p in
                            HStack {
                                Image(systemName: p.isReady ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(p.isReady ? .green : .gray)
                                
                                Text(p.userId == self.currentUserId ? "You:" : (p.userName.isEmpty ? "User: \(p.userId.prefix(6))" : p.userName))
                                    .font(.subheadline)
                            }
                            
                        }
                    }
                }
            }
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        .shadow(radius: 2)
    }
    
    @MainActor
    public func refresh() {
        self.participants.removeAll()
        self.participants = [:]
        let temp = self.realmInstance
            .objects(InteractionParticipant.self)
            .filter { $0.roomId == self.currentRoomId && $0.sessionId == self.currentSessionId }
        print("Participant Count: \(temp.count)")
        for p in temp {
            self.participants[p.userId] = p
           
        }
        
        if let current = self.realmInstance
            .objects(InteractionParticipant.self)
            .filter { $0.userId == self.currentUserId && $0.roomId == self.currentRoomId && $0.sessionId == self.currentSessionId }.first {
                self.currentIsReady = current.isReady
                self.currentHasJoined = current.isActive
            }
        
    }

    // MARK: - Lifecycle
    public func start(roomId: String, sessionId: String) {
        self.participants.removeAll()
        self.recompute()
        self.currentRoomId = roomId
        self.currentSessionId = sessionId

        let path = DatabasePaths.participants.rawValue
        fused.load(roomId: roomId, sessionId: sessionId, path: path, onLoad: { item in
            if self.hasChanged { return }
            self.hasChanged = true
            delayThenMain(2, mainBlock: {
                self.applyUpsert(item)
                self.hasChanged = false
            })
        })
        DispatchQueue.main.async {
            self.refresh()
        }
    
        // Observe children for add/change/remove
        fused.observeFire(
            onAdded: { item in
                if self.hasChanged { return }
                self.hasChanged = true
                delayThenMain(2, mainBlock: {
                    self.applyUpsert(item)
                    self.hasChanged = false
                })
            },
            onChange: { item in
                if self.hasChanged { return }
                self.hasChanged = true
                delayThenMain(2, mainBlock: {
                    self.applyUpsert(item)
                    self.hasChanged = false
                })
            },
            onDelete: { [weak self]
                item in self?.applyDelete(item)
            }
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
        p.roomId = currentRoomId
        p.widgetId = widgetId
        p.sessionId = currentSessionId
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
            newRealm().safeWrite { r in
                local.isReady = isReady
                local.updatedAt = getCurrentTimestamp()
            }
            applyUpsert(local)
        }
    }

    public func toggleReady(userId: String? = nil) {
        let uid = userId ?? currentUserId
        let newVal = !(participants[uid]?.isReady ?? false)
        self.currentIsReady = newVal
        setReady(newVal, userId: uid)
    }

    public func setActive(_ active: Bool, userId: String? = nil) {
        let uid = userId ?? currentUserId
        nodeRef.child(uid).updateChildValues([
            "isActive": active,
            "updatedAt": getCurrentTimestamp()
        ])
        if var local = participants[uid] {
            newRealm().safeWrite { r in
                local.isActive = active
                local.updatedAt = getCurrentTimestamp()
            }
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
            newRealm().safeWrite { r in
                local.role = role
                local.updatedAt = getCurrentTimestamp()
            }
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
                self.refresh()
                self.total = self.participants.values.filter { $0.isActive }.count
                self.ready = self.participants.values.filter { $0.isActive && $0.isReady }.count
                self.allReady = (self.total > 0 && self.ready == self.total)
                if self.currentUserId == obj.userId {
                    self.currentIsReady = obj.isReady
                }
            }
           
        }
    }
    private func applyUpsert(_ p: InteractionParticipant) {
        DispatchQueue.main.async {
            
            self.refresh()
            print("UserId: \(self.currentUserId)")
            if p.userId == self.currentUserId {
                self.currentIsReady = p.isReady
                self.currentHasJoined = p.isActive
            }
            self.total = self.participants.values.filter { $0.isActive }.count
            self.ready = self.participants.values.filter { $0.isActive && $0.isReady }.count
            self.allReady = (self.total > 0 && self.ready == self.total)
            if self.currentUserId == p.userId {
                self.currentIsReady = p.isReady
            }
            
           
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
        self.total = self.participants.values.filter { $0.isActive }.count
        self.ready = self.participants.values.filter { $0.isActive && $0.isReady }.count
        self.allReady = (self.total > 0 && self.ready == self.total)
    }
}
