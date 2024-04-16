//
//  LiveConnections.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/6/24.
//

import Foundation
import SwiftUI
import RealmSwift
import FirebaseDatabase
import Combine
import CoreEngine

@propertyWrapper
struct LiveChat: DynamicProperty {
    @ObservedObject var observer: RealmChatObserver
    @ObservedObject var firebaseObserver = FirebaseChatObserver()
    @State var objects: Results<Chat>? = nil
    @State var sharedIds: [String] = []
    @State var realmInstance: Realm
    @State var filterSharedOnly = false
    @State var userId = ""
    
    @ObservedObject var logoutObserver = LogoutObserver()

    init(realmInstance: Realm = realm(), shared:Bool=false) {
        self.realmInstance = realmInstance
        self.filterSharedOnly = shared
        self.observer = RealmChatObserver()
        self.objects = self.observer.objects
        self.logoutListener()
    }
    
    func logoutListener() {
        self.logoutObserver.onLogout = {
            print("LiveChat: Logout Observer!!!!")
            self.destroy()
        }
    }
    
    func destroy() {
        print("LiveChat: Destroying Thyself")
        self.observer.destroy(deleteObjects: false)
        self.firebaseObserver.stopObserving()
        self.objects = nil
    }

    var wrappedValue: Results<Chat>? {
        get {
            return self.objects
        }
        set { objects = newValue }
    }
    
    var projectedValue: Binding<[Chat]> {
        Binding<[Chat]>(
            get: {
                return self.objects?.toArray() ?? []
            },
            set: { newValue in }
        )
    }
    
    func toArray() -> [Chat?] {
        if let obj = objects {
            return Array(obj)
        }
        return []
    }
    
    func start(chatId:String) {
        DispatchQueue.main.async {
            if let id = UserTools.currentUserId {
                self.userId = id
                self.observer.startObserver(chatId: chatId, realm: self.realmInstance)
                self.firebaseObserver.startObserving(chatId: chatId, realmInstance: self.realmInstance)
                fireGetChatAsync(chatId: id, realm: self.realmInstance)
            }
        }
    }
    
    func stopFirebaseObservation() {
        firebaseObserver.stopObserving()
    }
    
    func fireGetChatAsync(chatId:String, realm: Realm=newRealm()) {
//        firebaseDatabase(collection: DatabasePaths.chat.rawValue) { ref in
//            ref.child(chatId)
//                .observeSingleEvent(of: .value) { snapshot, _ in
//                    let _ = snapshot.toLudiObjects(Chat.self, realm: realm)
//                }
//        }
    }

}

// Realm

@available(*, deprecated, renamed: "ObservedResults", message: "Replaced with Observed Results")
class RealmChatObserver: ObservableObject {
    @Published var objects: Results<Chat>? = nil
    @Published var watchedObjects: Results<Chat>? = nil
    @Published var notificationToken: NotificationToken? = nil

    func startObserver(chatId: String, realm: Realm) {
//        if !userIsVerifiedToProceed() { return }
        self.objects = realm.objects(Chat.self).filter("chatId == %@", chatId)
        
        self.objects?.realm?.executeWithRetry {
            self.notificationToken = self.objects?.observe { [weak self] (changes: RealmCollectionChange) in
                guard let self = self else { return }
                switch changes {
                    case .initial(_):
                        print("RealmChatObserver: Initial")
                        self.objectWillChange.send()
                    case .update(_, _, _, _):
                        print("RealmChatObserver: Update")
                        self.objectWillChange.send()
                    case .error(let error):
                        print("RealmChatObserver: \(error)")
                        self.notificationToken?.invalidate()
                        self.notificationToken = nil
                }
            }
        }
        
        
    }
    
    func destroy(deleteObjects:Bool=false) {
        notificationToken?.invalidate()
        if deleteObjects {
            deleteAll()
        }
    }
    
    func deleteAll() {
        if let objs = self.objects {
            realm().safeWrite { r in
                r.delete(objs)
            }
        }
    }

    deinit {
        notificationToken?.invalidate()
    }
}


// Firebase

class FirebaseChatObserver: ObservableObject {
    private var firebaseSubscription: DatabaseHandle?
    @Published var isObserving = false
    private var query: DatabaseQuery? = nil
    private var ref: DatabaseReference? = nil
    
    @Published var reference: DatabaseReference = Database
        .database()
        .reference()
        .child(DatabasePaths.chat.rawValue)

    func startObserving(chatId: String, realmInstance: Realm) {
//        if !userIsVerifiedToProceed() { return }
        guard !isObserving else { return }
        firebaseSubscription = self.reference.child(chatId).observe(.value, with: { snapshot in
            let _ = snapshot.toCoreObjects(Chat.self, realm: realmInstance)
        })
        isObserving = true
    }

    func stopObserving() {
        if let subscription = firebaseSubscription {
            query?.removeObserver(withHandle: subscription)
            ref?.removeObserver(withHandle: subscription)
            reference.removeObserver(withHandle: subscription)
            firebaseSubscription = nil
        }
        isObserving = false
    }
    
    deinit {
        stopObserving()
    }
}
