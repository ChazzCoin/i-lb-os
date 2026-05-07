//
//  ChatListLoader.swift
//  CoreEngine
//
//  Created by Charles Romeo on 1/25/26.
//

import Foundation
import SwiftUI
import RealmSwift
import FirebaseDatabase

public struct ChatMessageRowData: Identifiable, Hashable {

    public let id: String
    public let roomId: String
    public let senderId: String?
    public let senderName: String?
    public let senderImage: String?
    public let receiverId: String?

    public let text: String
    public let uri: String
    public let reaction: String
    public let status: String
    public let timestamp: String

    public init(
        id: String,
        roomId: String,
        senderId: String?,
        senderName: String?,
        senderImage: String?,
        receiverId: String?,
        text: String,
        uri: String,
        reaction: String,
        status: String,
        timestamp: String
    ) {
        self.id = id
        self.roomId = roomId
        self.senderId = senderId
        self.senderName = senderName
        self.senderImage = senderImage
        self.receiverId = receiverId
        self.text = text
        self.uri = uri
        self.reaction = reaction
        self.status = status
        self.timestamp = timestamp
    }
}

@MainActor
public final class ChatMessageListObservable: ObservableObject {
    
    @ObservedResults(ChatMessage.self) public var allMessages
    @Published public var messages: [ChatMessage] = []
    @Published public var chatAddedHandler: DatabaseHandle? = nil
    @Published public var chatChangedHandler: DatabaseHandle? = nil
    @Published public var chatRef = Database.database().reference().child(DatabasePaths.messages.rawValue)
    
    @Published public var USER: AppCoreUserObservable = AppCoreUserObservable()

    // MARK: - Published API
    @Published public private(set) var displayedItems: [ChatMessageRowData] = []
    @Published public private(set) var isLoading: Bool = false

    // MARK: - Config
    public let roomId: String
    private let pageSize: Int

    // MARK: - Paging State
    private var currentPage: Int = 0
    private var reachedBeginning: Bool = false
    
    // MARK: - State
    @Published public var inputText: String = ""
    @Published public var selectedImage: Image?
    @Published public var isFocused: Bool = false
    @Published public var isSending: Bool = false
    
    public let realmInstance: Realm = newRealm()

    // MARK: - Init
    public init(roomId: String, pageSize: Int = 30) {
        self.roomId = roomId
        self.pageSize = pageSize
    }

    // MARK: - Lifecycle
    public func onAppear() {
        self.getMessages()
        self.chatObservers()
    }
//    
    // MARK: - Reload (fresh load)
    public func reload() {
        currentPage = 0
        reachedBeginning = false
        displayedItems.removeAll()
        loadNextPage()
    }
    public func getMessages() {
        firebaseDatabase { db in
            db.child(DatabasePaths.messages.rawValue).child(self.roomId).observeSingleEvent(of: .value) { snapshot, _ in
                let _ = snapshot.toCoreObjects(ChatMessage.self)
            }
        }
    }
    
    public var roomMessages: Results<ChatMessage> {
        return allMessages
            .filter("chatId == %@", self.roomId)
            .sorted(byKeyPath: "timestamp", ascending: true)
    }

    // MARK: - Load Older Messages
    public func loadNextPage() {
        guard !isLoading, !reachedBeginning else { return }
        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async {
            let realm = newRealm()

            let results = realm.objects(ChatMessage.self)
                .filter("roomId == %@", self.roomId)
                .sorted(byKeyPath: "timestamp", ascending: false)

            let start = self.currentPage * self.pageSize
            let end = start + self.pageSize

            guard start < results.count else {
                DispatchQueue.main.async {
                    self.reachedBeginning = true
                    self.isLoading = false
                }
                return
            }

            let slice = results[start..<min(end, results.count)]

            let rows = slice.map {
                ChatMessageRowData(
                    id: $0.id,
                    roomId: $0.roomId,
                    senderId: $0.senderId,
                    senderName: $0.senderName,
                    senderImage: $0.senderImage,
                    receiverId: $0.receiverId,
                    text: $0.text,
                    uri: $0.uri,
                    reaction: $0.reaction,
                    status: $0.status,
                    timestamp: $0.timestamp
                )
            }

            DispatchQueue.main.async {
                // 👇 prepend older messages
                self.displayedItems.insert(contentsOf: rows.reversed(), at: 0)
                self.currentPage += 1
                self.isLoading = false
            }
        }
    }
    
    
    // MARK: - Send
    public func sendMessage() async {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        isSending = true
        let text = inputText

        inputText = ""
        selectedImage = nil
        isFocused = false

        let msg = ChatMessage()
        msg.chatId = self.roomId
        msg.roomId =  self.roomId
        msg.senderId = self.USER.user?.id
        msg.senderName = self.USER.user?.userName
        msg.text = text
        msg.uri = ""
        msg.reaction = ""
        msg.status = ""
        msg.timestamp = String(Date().timeIntervalSince1970)
        // Firebase auto-generates the key
        FusedTools.fusedWriter { realm in
            realm.create(ChatMessage.self, value: msg, update: .all)
        }
        let dmsg: [String: String?] = msg.toDict()
        try! await self.chatRef.child(self.roomId).childByAutoId().setValue(dmsg)

        isSending = false
    }
    
    public func chatObservers() {
        stopChatObservers() // Clean up existing
        if !self.roomId.isEmpty {
            // Only observe messages for the current room
            chatAddedHandler = chatRef.child(self.roomId)
                .observe(.childAdded, with: { [weak self] snapshot in
                    guard let self else { return }
                    let _ = snapshot.toCoreObject(ChatMessage.self, realm: self.realmInstance)
                    self.refreshMessages()
                })
            chatChangedHandler = chatRef.child(self.roomId)
                .observe(.childChanged, with: { [weak self] snapshot in
                    guard let self else { return }
                    let _ = snapshot.toCoreObject(ChatMessage.self, realm: self.realmInstance)
                    self.refreshMessages()
                })
        }
        refreshMessages()
    }
    
    public func stopChatObservers() {
        if let handle = chatAddedHandler {
            chatRef.child(self.roomId).removeObserver(withHandle: handle)
        }
        if let handle = chatChangedHandler {
            chatRef.child(self.roomId).removeObserver(withHandle: handle)
        }
    }

    public func refreshMessages() {
        // You could also make this a Results<ChatMessage> for reactivity!
        let results = realmInstance.objects(ChatMessage.self)
            .filter("roomId == %@", self.roomId)
            .sorted(byKeyPath: "timestamp", ascending: true)
        messages = Array(results)
    }
}
