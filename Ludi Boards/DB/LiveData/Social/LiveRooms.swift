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
            firebaseObserver.startObserving(roomId: roomId, realmInstance: self.realmInstance)
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
    @Published var isObserving = false
    @Published var rooms: [Room] = []
    private var ref: DatabaseReference? = nil
    
    @Published var reference: DatabaseReference = Database
        .database()
        .reference()
        .child("rooms")

    func startObserving(roomId: String, realmInstance: Realm) {
        if !userIsVerifiedToProceed() { return }
        guard !isObserving else { return }
        firebaseSubscription = self.reference.child(roomId).observe(.value, with: { snapshot in
            var tempRooms: [Room] = []
            if let results = snapshot.toLudiObjects(Room.self, realm: realmInstance) {
                for item in results {
                    if item.roomId != roomId || item.status == "OUT" {continue}
                    tempRooms.append(item)
                }
                self.rooms = tempRooms
            }
        })
        isObserving = true
    }

    func stopObserving() {
        if let subscription = firebaseSubscription {
            ref?.removeObserver(withHandle: subscription)
            reference.removeObserver(withHandle: subscription)
            firebaseSubscription = nil
        }
        isObserving = false
    }
    
    static func enterRoom(roomId:String) {
        toggleRoomStatus(roomId: roomId, status: "IN")
    }
    static func leaveRoom(roomId:String) {
        toggleRoomStatus(roomId: roomId, status: "OUT")
    }
    static func awayRoom(roomId:String) {
        toggleRoomStatus(roomId: roomId, status: "AWAY")
    }
    
    static func toggleRoomStatus(roomId:String, status:String) {
        if roomId == "SOL" || roomId.isEmpty { return }
        safeFirebaseUserId { uid in
            let tempRealm = newRealm()
            if let item = tempRealm.findByField(Room.self, field: "roomId", value: roomId) {
                tempRealm.safeWrite { _ in
                    item.status = status
                }
                firebaseDatabase { db in
                    db.child("rooms").child(roomId).child(item.id).setValue(item.toDict())
                }
                return
            }
            
            let roomPresence = Room()
            roomPresence.roomId = roomId
            roomPresence.userId = uid
            roomPresence.status = status
            tempRealm.safeWrite { r in
                r.create(Room.self, value: roomPresence, update: .all)
            }
            firebaseDatabase { db in
                db.child("rooms").child(roomId).child(roomPresence.id).setValue(roomPresence.toDict())
            }
            
        }
        
    }
    
    deinit {
        stopObserving()
    }
}
