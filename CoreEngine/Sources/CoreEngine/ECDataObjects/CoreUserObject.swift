//
//  CoreUserObject.swift
//  CoreEngine
//
//  Created by Charles Romeo on 1/25/26.
//

import SwiftUI
import RealmSwift

@MainActor
public final class CoreUserObject: ObservableObject {

    // MARK: - Published Fields
    @Published public var id: String = ""
    @Published public var userId: String = ""

    @Published public var auth: String = UserAuth.owner.name
    @Published public var role: String = UserRole.temp.name

    @Published public var name: String = ""
    @Published public var userName: String = ""
    @Published public var handle: String = ""
    @Published public var email: String = ""
    @Published public var imgUrl: String = ""

    @Published public var dateCreated: String = getTimeStamp()
    @Published public var dateUpdated: String = getTimeStamp()

    @Published public var membership: Int = 0
    @Published public var isOpen: Bool = false
    @Published public var status: Bool = false

    // MARK: - UI State
    @Published public var isLoading: Bool = false
    @Published public var isEditMode: Bool = false

    // MARK: - Private
    private let realm: Realm

    // MARK: - Init
    public init(userId: String = "current", realm: Realm = newRealm()) {
        self.realm = realm

        if userId == "new" {
            self.isEditMode = true
        } else {
            load(id: userId == "current" ? CURRENT_USER_ID : userId)
        }
    }

    // MARK: - Load
    public func load(id: String) {
        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async {
            let realm = newRealm()
            guard let user = realm.object(ofType: CoreUser.self, forPrimaryKey: id) else {
                DispatchQueue.main.async { self.isLoading = false }
                return
            }

            DispatchQueue.main.async {
                self.id = user.id
                self.userId = user.userId
                self.auth = user.auth
                self.role = user.role
                self.name = user.name
                self.userName = user.userName
                self.handle = user.handle
                self.email = user.email
                self.imgUrl = user.imgUrl
                self.dateCreated = user.dateCreated
                self.dateUpdated = user.dateUpdated
                self.membership = user.membership
                self.isOpen = user.isOpen
                self.status = user.status
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
                realm.create(
                    CoreUser.self,
                    value: [
                        "id": self.id.isEmpty ? CURRENT_USER_ID : self.id,
                        "userId": self.userId,
                        "auth": self.auth,
                        "role": self.role,
                        "name": self.name,
                        "userName": self.userName,
                        "handle": self.handle,
                        "email": self.email,
                        "imgUrl": self.imgUrl,
                        "membership": self.membership,
                        "isOpen": self.isOpen,
                        "status": self.status,
                        "dateCreated": self.dateCreated,
                        "dateUpdated": now
                    ],
                    update: .modified
                )
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
