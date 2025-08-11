//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/10/24.
//

import Foundation
import SwiftUI
import RealmSwift
import FirebaseDatabase


public class FusedRoom : ObservableObject {
    
    @StateObject public var USER = UserToolsObservable()
    @AppStorage("currentUserId", store: UserDefaults(suiteName: "worlds")) public var currentUserId: String = ""
    @AppStorage("currentUserName", store: UserDefaults(suiteName: "worlds")) public var currentUserName: String = ""
    @AppStorage("currentRoomId", store: UserDefaults(suiteName: "worlds")) public var currentRoomId: String = ""
    @AppStorage("currentChatId", store: UserDefaults(suiteName: "worlds")) public var currentChatId: String = ""
    public func setCurrentRoomId(_ id: String?) {
        if let id = id {
            DispatchQueue.main.async {
                self.currentRoomId = id
                self.currentChatId = id
                self.getRoomDetails()
            }
        }
    }
    @ObservedResults(Room.self) public var allRooms
    @ObservedResults(UserInRoom.self) public var allUsersInRooms
    @ObservedResults(CoreUser.self) public var allUsers
    @ObservedResults(ChatMessage.self) public var allMessages
    
    @Published public var chatId: String = ""

    
    public var currentRoom: Results<Room> {
        return allRooms.filter("id == %@", self.currentRoomId)
    }
    public var inRoom: Results<UserInRoom> {
        return allUsersInRooms.filter("roomId == %@", self.currentRoomId)
    }
    public var inRoomUserIds: [String] {
        return allUsersInRooms.filter("roomId == %@", self.currentRoomId).compactMap({ $0.guestId })
    }
    public var usersInRoom: Results<CoreUser> {
        return allUsers.filter("id IN %@", inRoomUserIds)
    }
    // Room
    @Published public var childAddedHandler: DatabaseHandle? = nil
    @Published public var childChangedHandler: DatabaseHandle? = nil
    @Published public var childRemovedHandler: DatabaseHandle? = nil
    @Published public var ref = Database.database().reference().child(DatabasePaths.rooms.rawValue)
    // Users In Room
    @Published public var userAddedHandler: DatabaseHandle? = nil
    @Published public var userChangedHandler: DatabaseHandle? = nil
    @Published public var userRemovedHandler: DatabaseHandle? = nil
    @Published public var userInRoomRef = Database.database().reference().child(DatabasePaths.userInRoom.rawValue)
    // Chat Messages In Room
    @Published public var messages: [ChatMessage] = []
    @Published public var chatAddedHandler: DatabaseHandle? = nil
    @Published public var chatChangedHandler: DatabaseHandle? = nil
    @Published public var chatRef = Database.database().reference().child(DatabasePaths.messages.rawValue)
    
    public let realmInstance: Realm = newRealm()
    
    public init() {}
    @Published public var room: Room? = nil
    @Published public var roomHasBeenLoaded: Bool = false
    @Published public var roomTitle: String = "title"
    @Published public var roomOwner: String = "owner"
    @Published public var roomStatus: String = "in_room"
    @Published public var roomUserCount: String = "user_count"
    
    @MainActor
    public func startUp() {
        if !self.currentRoomId.isEmpty {
            let tempID = self.currentRoomId
            if let room = self.realmInstance.object(ofType: Room.self, forPrimaryKey: tempID) {
                self.room = room
                self.roomTitle = room.title
                self.roomOwner = room.ownerName
                self.roomStatus = room.status
                self.roomHasBeenLoaded = true
            }
            self.currentRoomId = tempID
            self.currentChatId = tempID
        } else {
            self.currentRoomId = ""
        }
        
        self.joinRoom(enteredRoomId: self.currentRoomId, completion: {
            self.getRoomDetails()
            self.getMessages()
            self.getUsersInRoom()
        })

    }
    
    
    public func joinRoom(enteredRoomId: String, completion: @escaping () -> Void) {
        
        guard !enteredRoomId.isEmpty else { return }
        stop() // cleanup previous observers
        self.enterOrCreateRoom(withId: enteredRoomId, completion: { didCreate, error in
            if let error = error {
                // Handle error (show alert)
                print("Error: \(error.localizedDescription)")
            } else if didCreate {
                print("Room created and entered!")
            } else {
                print("Joined existing room.")
            }
            completion()
        })

    }
    
    public func leaveRoom() {
        self.updateUserInRoom(status: .out_of_room)
        stop() // Stop observers and Firebase listeners
        self.room = nil
        self.currentRoomId = ""
        self.currentChatId = ""
        self.roomTitle = ""
        self.roomOwner = ""
        self.roomStatus = ""
        self.roomHasBeenLoaded = false
        self.roomUserCount = ""
        // Remove from UserDefaults if needed
        UserDefaults.standard.removeObject(forKey: "currentRoomId")
    }

    
    public func getRoomDetails() {
        if let room = self.realmInstance.object(ofType: Room.self, forPrimaryKey: currentRoomId) {
            main {
                self.room = room
                self.roomTitle = room.title
                self.roomOwner = room.ownerName
                self.roomStatus = room.status
                self.roomHasBeenLoaded = true
            }
        } else {
            self.roomHasBeenLoaded = false
        }
        
    }
    
    public func getMessages() {
        firebaseDatabase { db in
            db.child(DatabasePaths.messages.rawValue).child(self.currentRoomId).observeSingleEvent(of: .value) { [weak self] snapshot, _ in
                let _ = snapshot.toCoreObjects(ChatMessage.self)
            }
        }
    }
    public func getUsersInRoom() {
        firebaseDatabase { db in
            db.child(DatabasePaths.userInRoom.rawValue).pullByField(UserInRoom.self, value: self.currentRoomId, field: "roomId", realm: self.realmInstance)
        }
    }
    // Fused Firebase -> Realm
    public func start(roomId: String) {
        setCurrentRoomId(roomId)
        // UserInRoom
        userInRoomObservers()
        // Room
        roomObservers()
        // Chat
        chatObservers()
        // Room Details
//        getAllUsers()
        getRoomDetails()
        getUsersInRoom()
    }
    
    // UserInRoom
    public func userInRoomObservers() {
        userAddedHandler = userInRoomRef
            .child(self.currentRoomId)
            .observe(.childAdded, with: { snapshot in
                let _ = snapshot.toCoreObject(UserInRoom.self, realm: self.realmInstance)
            })
        userChangedHandler = userInRoomRef
            .child(self.currentRoomId)
            .observe(.childChanged, with: { snapshot in
                let _ = snapshot.toCoreObject(UserInRoom.self, realm: self.realmInstance)
            })
    }
    
    // Room
    public func roomObservers() {
        childAddedHandler = ref
            .observe(.childAdded, with: { snapshot in
                let _ = snapshot.toCoreObject(Room.self, realm: self.realmInstance)
            })
        childChangedHandler = ref
            .observe(.childChanged, with: { snapshot in
                let _ = snapshot.toCoreObject(Room.self, realm: self.realmInstance)
            })
        childRemovedHandler = ref
            .observe(.childRemoved, with: { snapshot in
                let _ = snapshot.deleteRealmObject(ofType: Room.self)
            })
    }
    
    
    // MARK: Chat
    public func chatObservers() {
        stopChatObservers() // Clean up existing
        if !self.currentRoomId.isEmpty {
            // Only observe messages for the current room
            chatAddedHandler = chatRef.child(self.currentRoomId)
                .observe(.childAdded, with: { [weak self] snapshot in
                    guard let self else { return }
                    let _ = snapshot.toCoreObject(ChatMessage.self, realm: self.realmInstance)
                    self.refreshMessages()
                })
            chatChangedHandler = chatRef.child(self.currentRoomId)
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
            chatRef.child(self.currentRoomId).removeObserver(withHandle: handle)
        }
        if let handle = chatChangedHandler {
            chatRef.child(self.currentRoomId).removeObserver(withHandle: handle)
        }
    }

    public func refreshMessages() {
        // You could also make this a Results<ChatMessage> for reactivity!
        let results = realmInstance.objects(ChatMessage.self)
            .filter("roomId == %@", self.currentRoomId)
            .sorted(byKeyPath: "timestamp", ascending: true)
        messages = Array(results)
    }
    
    public func attachFileToRoom(title: String, author: String, fileUrl: URL) {
        CoreFirebaseStorage.uploadDocument(title: title, author: author, fileUrl: fileUrl) { durl in
            self.sendMessage(text: "", uri: fileUrl)
        }
    }

    public func sendMessage(text: String, uri: URL?=nil, reaction: String?=nil, status: String?=nil) {
        if !self.currentRoomId.isEmpty {
            let msg = ChatMessage()
            msg.chatId = self.currentRoomId
            msg.roomId =  self.currentRoomId
            msg.senderId = self.currentUserId
            msg.senderName = self.currentUserName
            msg.text = text
            msg.uri = uri?.absoluteString ?? ""
            msg.reaction = reaction ?? ""
            msg.status = status ?? ""
            msg.timestamp = String(Date().timeIntervalSince1970)
            // Firebase auto-generates the key
            FusedTools.fusedWriter { realm in
                realm.create(ChatMessage.self, value: msg, update: .all)
            }
            let dmsg: [String: String?] = msg.toDict()
            chatRef.child(self.currentRoomId).childByAutoId().setValue(dmsg)
        }
        
    }
    public func addUserToRoom(roomId: String) {
        if !self.currentRoomId.isEmpty {
            let inroom = UserInRoom()
            inroom.roomId = self.currentRoomId
            inroom.guestId = self.currentUserId
            inroom.guestName = self.currentUserName
            inroom.auth =  UserAuth.visitor.name
            inroom.status = RoomStatus.in_room.name
            FusedTools.fusedWriter { realm in
                realm.create(UserInRoom.self, value: inroom, update: .all)
            }
            let dinroom = inroom.toDict()
            userInRoomRef.child(self.currentRoomId).child(inroom.guestId).setValue(dinroom)
        }
        
    }
    
    public func updateUserInRoom(status: RoomStatus) {
            
        if let inroom = self.realmInstance.findByField(UserInRoom.self, field: "guestId", value: self.currentUserId) {
            self.realmInstance.safeWrite { r in
                inroom.status = status.name
                var gId = inroom.guestId
                if inroom.guestId.isEmpty {
                    gId = "\(UUID())"
                    
                }
                let dinroom = inroom.toDict()
                self.userInRoomRef.child(self.currentRoomId).child(gId).setValue(dinroom)
            }
        } else {
            self.addUserToRoom(roomId: self.currentRoomId)
        }
        
        
    }

    public func completeRoomEntry(roomId: String, completion: ((_ didCreate: Bool, _ error: Error?) -> Void)?, didCreate: Bool) {
        self.updateUserInRoom(status: .in_room)
        self.start(roomId: roomId)
        completion?(didCreate, nil)
    }
    
    public func completeRoomEntry(roomId: String, didCreate: Bool, completion: ((_ didCreate: Bool, _ error: Error?) -> Void)? = nil) {
        updateUserInRoom(status: .in_room)
        start(roomId: roomId)
        completion?(didCreate, nil)
    }


    // Utils
    public func stop() {
        userAddedHandler = nil
        userChangedHandler = nil
        childAddedHandler = nil
        childChangedHandler = nil
        childRemovedHandler = nil
        stopChatObservers()
        chatChangedHandler = nil
        chatAddedHandler = nil
    }
    
    private func getAllUsers() {
        DataPuller.getListOfUsers(ids: inRoomUserIds)
    }
    
}

public extension FusedRoom {
    /// Call this to enter a room if it exists, or create it if it doesn't.
    func enterOrCreateRoom(withId roomId: String, completion: ((_ didCreate: Bool, _ error: Error?) -> Void)? = nil) {
//        self.roomId = roomId
//        self.USER.currentRoomId = roomId
        let roomRef = ref.child(roomId)
        roomRef.observeSingleEvent(of: .value) { [weak self] snapshot, _ in
            guard let self = self else { return }
            if snapshot.exists() {
                
                // Room Already Exists
                let obj = snapshot.toCoreObject(Room.self, realm: self.realmInstance)
                self.room = obj
                self.currentRoomId = obj?.id ?? ""
                self.getRoomDetails()
                self.getUsersInRoom()
                self.completeRoomEntry(roomId: roomId, didCreate: false, completion: completion)
                main {
                    completion?(true, nil)
                }
                
            } else {
                
                // New Room
                let newRoom = [
                    "id": roomId,
                    "dateCreated": getTimeStamp(),
                    "dateUpdated": getTimeStamp(),
                    "ownerId": self.currentUserId,
                    "ownerName": self.currentUserName,
                    "status": "open",
                    "title": "Room \(roomId)",
                    "subTitle": "",
                    "roomDetails": "",
                    "category": "",
                    "tags": [],
                    "isOpen": true,
                    "isLocal": false,
                    "isDeleted": false
                ] as [String : Any]
                
                roomRef.setValue(newRoom) { error, _ in
                    if let error = error {
                        completion?(false, error)
                        return
                    }
                    self.currentRoomId = roomId
                    self.getRoomDetails()
                    self.getUsersInRoom()
                    self.completeRoomEntry(roomId: roomId, didCreate: true, completion: completion)
                    main {
                        completion?(true, nil)
                    }
                    
                }
            }
        }
    }

}
