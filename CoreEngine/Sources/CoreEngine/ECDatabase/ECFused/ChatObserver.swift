//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/9/24.
//

import Foundation
import FirebaseDatabase
import RealmSwift


public class ChatObserver: ObservableObject {
    @Published public var chatId: String = ""
    @Published public var chatRef = FireReference(dbPath: DatabasePaths.chat)
    public let realmInstance = realm()
    @Published public var firebaseSubscription: DatabaseHandle? = nil
    
    public init() {}
    
    @ObservedResults(Chat.self) public var allMessages
    public var roomMessages: Results<Chat> {
        return allMessages
            .filter("chatId == %@", chatId)
            .sorted(byKeyPath: "timestamp", ascending: true)
    }
    
    public func start(chatId: String) {
        if chatId.isEmpty {return}
        stop()
        self.chatId = chatId
        firebaseSubscription = self.chatRef.child(chatId).fireObserveChildAdded { snapshot in
            if let results = snapshot.toCoreObjects(Chat.self, realm: self.realmInstance) {
                print("New Chat Messages: \(results)")
            }
        }
    }

    public func stop() {
        if let fs = firebaseSubscription {
            self.chatRef.removeObserver(withHandle: fs)
            firebaseSubscription = nil
        }
    }
}
