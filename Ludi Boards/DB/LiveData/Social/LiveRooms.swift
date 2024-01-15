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

@propertyWrapper
struct LiveRooms: DynamicProperty {
    @ObservedObject private var observer: RealmRoomObserver
    @ObservedObject private var firebaseObserver = FirebaseRoomService()
    @State var objects: Results<Room>? = nil
    private var realmInstance: Realm

    @ObservedObject var logoutObserver = LogoutObserver()

    init(realmInstance: Realm = newRealm()) {
        self.realmInstance = realmInstance
        self.observer = RealmRoomObserver(realmIn: self.realmInstance)
        self.objects = self.observer.objects
        self.logoutListener()
    }
    
    func logoutListener() {
        self.logoutObserver.onLogout = {
            print("LiveRooms: Logout Observer!!!!")
            self.destroy()
        }
    }
    
    func destroy() {
        print("LiveRooms: Destroying Thyself")
        self.observer.destroy(deleteObjects: false)
        self.firebaseObserver.stopObserving()
        self.objects = nil
    }

    var wrappedValue: Results<Room>? {
        get {
            return self.observer.objects
        }
        set { objects = newValue }
    }
    
    var projectedValue: Binding<[Room]> {
        Binding<[Room]>(
            get: {
                return self.observer.objects?.toArray() ?? []
            },
            set: { newValue in }
        )
    }
    
    func toArray() -> [Room?] {
        if let obj = objects {
            return Array(obj)
        }
        return []
    }
    
    func load(roomId:String) {
        DispatchQueue.main.async {
            firebaseObserver.startObserving(roomId: roomId)
        }
    }
    
    private class RealmRoomObserver: ObservableObject {
        @Published var objects: Results<Room>? = nil
        @Published var notificationToken: NotificationToken? = nil
        @Published var realmInstance: Realm
        
        init(realmIn: Realm=newRealm()) {
            self.realmInstance = realmIn
        }
        
        func start(roomId:String) {
            self.objects = self.realmInstance.objects(Room.self).filter("roomId == %@ AND status == %@", roomId, "IN")
            self.notificationToken = self.objects?.observe { [weak self] (changes: RealmCollectionChange) in
                guard let self = self else { return }
                if !userIsVerifiedToProceed() {
                    destroy()
                    return
                }
                switch changes {
                    case .initial(_):
                        print("LiveRoom: Initial")
                        self.objectWillChange.send()
                    case .update(_, _, _, _):
                        print("LiveRoom: Update")
                        self.objectWillChange.send()
                    case .error(let error):
                        print("LiveRoom: \(error)")
                }
            }
        }

        func destroy(deleteObjects:Bool=false) {
            notificationToken?.invalidate()
            notificationToken = nil
            if deleteObjects {
                deleteAll()
            }
        }
        
        func deleteAll() {
            realm().safeWrite { r in
                if let objs = self.objects {
                    r.delete(objs)
                }
            }
        }
        deinit {
            notificationToken?.invalidate()
        }
    }
    
    

}

enum RoomStatus {
    case IN
    case OUT
    case AWAY
}

class FirebaseRoomService: ObservableObject {
    private var firebaseSubscription: DatabaseHandle?
    @ObservedResults(SolUser.self) var allUsers
    @ObservedResults(Room.self) var allRooms
    @Published var isObserving = false
    @Published var rooms: [Room] = []
    @Published var currentRoomId = ""
    @Published var objsInCurrentRoom: [Room] = []
    @Published var usersInCurrentRoom: [SolUser] = []
    private var ref: DatabaseReference? = nil
    
    @Published var reference: DatabaseReference = Database
        .database()
        .reference()
        .child("rooms")
    
    var getCurrentRoom: Results<Room> {
        return self.allRooms.filter("roomId == %@", self.currentRoomId)
    }
    
    var getCurrentRoomObjs: Results<Room> {
        return self.allRooms.filter("roomId == %@ AND status != %@", self.currentRoomId, "OUT")
    }
    
    func startObserving(roomId: String) {
        if !userIsVerifiedToProceed() { return }
        guard !isObserving else { return }
        self.currentRoomId = roomId
        firebaseSubscription = self.reference.child(roomId).observe(.value, with: { snapshot in
            
            let snapPresence = newRealm().objects(Room.self).filter("roomId == %@", roomId)
            
            if let allUserPresences = snapshot.toLudiObjects(Room.self, realm: self.allRooms.realm?.thaw()) {
                // Assuming UserPresence has properties `roomId` and `status`
                let inRoom = allUserPresences.filter { $0.roomId == roomId }
                
                var inTemp: [SolUser] = []
                var roomTemp: [Room] = []
                for r in inRoom {
                    if r.userId == getFirebaseUserId() { continue }
                    roomTemp.safeAdd(r)
                    if let user = self.allRooms.realm?.findByField(SolUser.self, field: "userId", value: r.id) {
                        inTemp.safeAdd(user)
                    } else {
                        if r.userId.isEmpty {continue}
                        fireGetSolUserAsync(userId: r.id, realm: self.allRooms.realm?.thaw())
                    }
                }
                self.objsInCurrentRoom = roomTemp
                
                for i in roomTemp {
                    if let user = self.allRooms.realm?.findByField(SolUser.self, field: "userId", value: i.id) {
                        inTemp.safeAdd(user)
                    }
                }
                self.usersInCurrentRoom = inTemp
                
                // Handle In/Out Notifications
                for item in self.objsInCurrentRoom {
                    if !snapPresence.contains(item) {
                        self.userHasEnteredTheRoom(user: item)
                    } else {
                        for snapItem in snapPresence {
                            if item.userId != snapItem.userId {continue}
                            if item.status == "OUT" && snapItem.status == "IN" {
                                self.userHasLeftTheRoom(user: item)
                            }
                            else if item.status == "IN" && snapItem.status == "OUT" {
                                self.userHasEnteredTheRoom(user: item)
                            }
                        }
                    }
                }
            }
        })
        isObserving = true
    }
    
    func userHasLeftTheRoom(user: Room) {
        print("User has Left Room: \(self.currentRoomId)")
        CodiChannel.ON_NOTIFICATION.send(value: NotificationController(message: "\(user.userName) has left the room.", icon: "door_closed"))
    }
    
    func userHasEnteredTheRoom(user: Room) {
        print("User has Entered Room: \(self.currentRoomId)")
        CodiChannel.ON_NOTIFICATION.send(value: NotificationController(message: "\(user.userName) has entered the room.", icon: "door_open"))
    }

    func stopObserving() {
        if let subscription = firebaseSubscription {
            self.currentRoomId = ""
            self.usersInCurrentRoom.removeAll()
            ref?.removeObserver(withHandle: subscription)
            reference.removeObserver(withHandle: subscription)
            firebaseSubscription = nil
        }
        isObserving = false
    }
    
    static func enterRoom(roomId:String) { toggleRoomStatus(roomId: roomId, status: "IN") }
    static func leaveRoom(roomId:String) { toggleRoomStatus(roomId: roomId, status: "OUT") }
    static func awayRoom(roomId:String) { toggleRoomStatus(roomId: roomId, status: "AWAY") }
    
    static func toggleRoomStatus(roomId:String, status:String) {
        if roomId == "SOL" || roomId.isEmpty { return }
        
        newRealm().getCurrentSolUser() { currentUser in
            let tempRealm = newRealm()
            if let item = tempRealm.findByField(Room.self, field: "roomId", value: roomId) {
                tempRealm.safeWrite { _ in
                    item.status = status
                }
                print("User is about to be \(status) room \(roomId)")
                firebaseDatabase { db in
                    var temp = item.toDict()
                    temp["status"] = status
                    db.child("rooms").child(item.roomId).child(item.id).setValue(temp)
                }
                return
            }
            
            let roomPresence = Room()
            roomPresence.roomId = roomId
            roomPresence.userId = currentUser.userId
            roomPresence.userName = currentUser.userName
            roomPresence.userImg = currentUser.imgUrl
            roomPresence.status = status
            tempRealm.safeWrite { r in
                r.create(Room.self, value: roomPresence, update: .all)
            }
            print("User is about to be \(status) room \(roomId)")
            firebaseDatabase { db in
                db.child("rooms").child(roomId).child(roomPresence.id).setValue(roomPresence.toDict())
            }
        }
       
    }
    
    deinit {
        stopObserving()
    }
}
