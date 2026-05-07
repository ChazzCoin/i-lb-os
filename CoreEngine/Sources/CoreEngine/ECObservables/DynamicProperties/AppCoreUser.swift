//
//  Untitled.swift
//  CoreEngine
//
//  Created by Charles Romeo on 1/25/26.
//

import SwiftUI
import RealmSwift
import Combine
import Foundation

@propertyWrapper
public struct AppCoreUser: DynamicProperty {

    @EnvironmentObject private var appUser: AppCoreUserObservable
    
    public init() {}

    public var wrappedValue: CoreUser? {
        appUser.user
    }
}

@MainActor
public final class AppCoreUserObservable: ObservableObject {

    @Published public private(set) var user: CoreUser?

    private var token: NotificationToken?
    private var userId: String = ""

    public init(userId: String?=UserTools.currentUserId) {
        if let userId = userId {
            self.userId = userId
            load()
            observe()
        }
    }

    deinit {
        token?.invalidate()
    }

    // MARK: - Initial Load
    private func load() {
        self.user = CoreUserProvider.loadCurrentUser()
    }

    // MARK: - Realm Observation
    private func observe() {
        guard !userId.isEmpty else { return }

        let realm = newRealm()

        guard let managedUser = realm.object(
            ofType: CoreUser.self,
            forPrimaryKey: userId
        ) else { return }

        token = managedUser.observe { [weak self] change in
            guard let self else { return }

            switch change {
            case .change:
                // Detach for UI safety
                self.user = CoreUser(value: managedUser)

            case .deleted:
                self.user = nil

            case .error(let error):
                print("❌ CoreUser observe error:", error)
            }
        }
    }
}

//public extension AppCoreUser {
//
//    var isLoggedIn: Bool {
//        user != nil
//    }
//
//    var isAdmin: Bool {
//        user?.role == UserRole.admin.name
//    }
//
//    var displayName: String {
//        user?.name.isEmpty == false ? user!.name : "User"
//    }
//}
