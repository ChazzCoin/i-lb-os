//
//  ManagedStreamObject.swift
//  CoreEngine
//
//  Created by Charles Romeo on 2/4/26.
//

//
//  ManagedStreamObject.swift
//  VSI
//
//  Created by VSI-iOS-Coder on 2/5/26
//

import SwiftUI
import RealmSwift
import FirebaseDatabase
import Combine

public class ManagedStreamObject: ObservableObject {

    // MARK: - Dependencies
    public let realm: Realm
    public var dbRef: DatabaseReference?

    // MARK: - App Context
    @AppStorage("currentState") public var currentState: String = ""
    @AppStorage("currentCountyId") public var currentCountyId: String = ""
    @AppStorage("currentCountyName") public var currentCountyName: String = ""
    @AppStorage("userId") public var userId: String = ""
    @AppStorage("userName") public var userName: String = ""

    // MARK: - Published Properties (Realm Mirror)

    @Published public var id: String = UUID().uuidString
    @Published public var createdDate: String = getTimeStamp()
    @Published public var updatedDate: String = getTimeStamp()

    @Published public var viewId: String = ""
    @Published public var roomId: String = ""
    @Published public var sessionId: String = ""

    @Published public var visibility: Bool = true
    @Published public var auth: String = ""
    @Published public var role: String = ""

    @Published public var model: String = ""
    @Published public var type: String = ""
    @Published public var ownerId: String = ""
    @Published public var updatedById: String = ""

    @Published public var title: String = ""
    @Published public var details: String = ""

    @Published public var sequence: Int = 0
    @Published public var eventKind: String = ""
    @Published public var schemaVersion: Int = 0

    @Published public var payloadType: String = ""
    @Published public var chunkIndex: Int = 0
    @Published public var chunkCount: Int = 0
    @Published public var byteSize: Int = 0

    @Published public var data: String = ""

    // MARK: - UI State
    @Published public var isLoading: Bool = false
    @Published public var isEditMode: Bool = false
    @Published public var isExpanded: Bool = false

    // MARK: - Init

    public init(streamId: String = "new", realm: Realm = newRealm()) {
        self.realm = realm

        if streamId == "new" {
            self.isEditMode = true
            self.id = UUID().uuidString
            self.createdDate = getTimeStamp()
            self.updatedDate = getTimeStamp()
            self.ownerId = userId
            self.updatedById = userId
        } else {
            self.isEditMode = false
            loadStream(id: streamId)
            observeStream(id: streamId)
        }
    }

    deinit {
        stopObserving()
    }

    // MARK: - Loading Helpers

    public func showLoadingView(completion: (() -> Void)? = nil) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            completion?()
        }
    }

    // MARK: - Realm Load

    public func loadStream(id: String) {
        guard let stream = realm.findByField(ManagedStream.self, value: id) else { return }

        main {
            self.id = stream.id
            self.createdDate = stream.createdDate
            self.updatedDate = stream.updatedDate
            self.viewId = stream.viewId
            self.roomId = stream.roomId
            self.sessionId = stream.sessionId
            self.visibility = stream.visibility
            self.auth = stream.auth
            self.role = stream.role
            self.model = stream.model
            self.type = stream.type
            self.ownerId = stream.ownerId
            self.updatedById = stream.updatedById
            self.title = stream.title
            self.details = stream.details
            self.sequence = stream.sequence
            self.eventKind = stream.eventKind
            self.schemaVersion = stream.schemaVersion
            self.payloadType = stream.payloadType
            self.chunkIndex = stream.chunkIndex
            self.chunkCount = stream.chunkCount
            self.byteSize = stream.byteSize
            self.data = stream.data
        }
    }

    // MARK: - Save

    public func saveStream(dismiss: @escaping () -> Void) {
        showLoadingView {
            self.realm.safeWrite { r in
                let stream = ManagedStream()
                stream.id = self.id
                stream.createdDate = self.createdDate
                stream.updatedDate = getTimeStamp()
                stream.viewId = self.viewId
                stream.roomId = self.roomId
                stream.sessionId = self.sessionId
                stream.visibility = self.visibility
                stream.auth = self.auth
                stream.role = self.role
                stream.model = self.model
                stream.type = self.type
                stream.ownerId = self.ownerId
                stream.updatedById = self.userId
                stream.title = self.title
                stream.details = self.details
                stream.sequence = self.sequence
                stream.eventKind = self.eventKind
                stream.schemaVersion = self.schemaVersion
                stream.payloadType = self.payloadType
                stream.chunkIndex = self.chunkIndex
                stream.chunkCount = self.chunkCount
                stream.byteSize = self.byteSize
                stream.data = self.data

                r.create(ManagedStream.self, value: stream, update: .all)
            }
            dismiss()
        }
    }

    // MARK: - Firebase Observation

    public func observeStream(id: String) {
        stopObserving()

        let ref = Database.database().reference()
        dbRef = ref
            .child(DatabasePaths.managed_stream.rawValue)
            .child(id)

        dbRef?.observe(.value) { [weak self] snapshot in
            guard let self else { return }
            guard let data = snapshot.value as? [String: Any] else { return }

            main {
                self.id = id
                self.createdDate = data["createdDate"] as? String ?? self.createdDate
                self.updatedDate = data["updatedDate"] as? String ?? self.updatedDate
                self.viewId = data["viewId"] as? String ?? ""
                self.roomId = data["roomId"] as? String ?? ""
                self.sessionId = data["sessionId"] as? String ?? ""
                self.visibility = data["visibility"] as? Bool ?? true
                self.auth = data["auth"] as? String ?? ""
                self.role = data["role"] as? String ?? ""
                self.model = data["model"] as? String ?? ""
                self.type = data["type"] as? String ?? ""
                self.ownerId = data["ownerId"] as? String ?? ""
                self.updatedById = data["updatedById"] as? String ?? ""
                self.title = data["title"] as? String ?? ""
                self.details = data["details"] as? String ?? ""
                self.sequence = data["sequence"] as? Int ?? 0
                self.eventKind = data["eventKind"] as? String ?? ""
                self.schemaVersion = data["schemaVersion"] as? Int ?? 0
                self.payloadType = data["payloadType"] as? String ?? ""
                self.chunkIndex = data["chunkIndex"] as? Int ?? 0
                self.chunkCount = data["chunkCount"] as? Int ?? 0
                self.byteSize = data["byteSize"] as? Int ?? 0
                self.data = data["data"] as? String ?? ""
            }
        }
    }

    public func stopObserving() {
        dbRef?.removeAllObservers()
        dbRef = nil
    }
}
