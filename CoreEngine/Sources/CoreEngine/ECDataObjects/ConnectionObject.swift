//
//  ConnectionObject.swift
//  CoreEngine
//
//  Created by Charles Romeo on 1/25/26.
//

import SwiftUI
import RealmSwift

@MainActor
public class ConnectionObject: ObservableObject {

    // MARK: - Published Fields (bind directly to UI)
    @Published public var id: String = ""
    @Published public var dateCreated: String = getTimeStamp()
    @Published public var dateUpdated: String = getTimeStamp()

    @Published public var userOne: String = ""
    @Published public var userTwo: String = ""
    @Published public var connection: String = ConnectionStatus.waiting_approval.name
    @Published public var status: String = RoomStatus.out_of_room.name

    // MARK: - UI State
    @Published public var isLoading: Bool = false
    @Published public var isEditMode: Bool = false

    // MARK: - Private
    public let realm: Realm

    // MARK: - Init
    public init(connectionId: String = "new", realm: Realm = newRealm()) {
        self.realm = realm

        if connectionId == "new" {
            isEditMode = true
        } else {
            load(id: connectionId)
        }
    }

    // MARK: - Load
    public func load(id: String) {
        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async {
            let realm = newRealm()
            guard let conn = realm.object(ofType: Connection.self, forPrimaryKey: id) else {
                DispatchQueue.main.async { self.isLoading = false }
                return
            }

            DispatchQueue.main.async {
                self.id = conn.id
                self.dateCreated = conn.dateCreated
                self.dateUpdated = conn.dateUpdated
                self.userOne = conn.userOne
                self.userTwo = conn.userTwo
                self.connection = conn.connection
                self.status = conn.status
                self.isEditMode = false
                self.isLoading = false
            }
        }
    }

    // MARK: - Save
    public func save(dismiss: (() -> Void)? = nil) {
        isLoading = true
        let now = getTimeStamp()

        DispatchQueue.global(qos: .userInitiated).async {
            let realm = newRealm()

            try? realm.write {
                let conn = realm.create(
                    Connection.self,
                    value: [
                        "id": self.id.isEmpty ? UUID().uuidString : self.id,
                        "dateCreated": self.dateCreated,
                        "dateUpdated": now,
                        "userOne": self.userOne,
                        "userTwo": self.userTwo,
                        "connection": self.connection,
                        "status": self.status
                    ],
                    update: .modified
                )

                self.id = conn.id
            }

            DispatchQueue.main.async {
                self.dateUpdated = now
                self.isEditMode = false
                self.isLoading = false
                dismiss?()
            }
        }
    }
}
