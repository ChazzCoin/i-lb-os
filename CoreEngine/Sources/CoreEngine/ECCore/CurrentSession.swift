//
//  CurrentSession.swift
//  CoreEngine
//
//  Created by Charles Romeo on 1/23/26.
//

//
//  CurrentSession.swift
//  VSI
//
//  Created by Charles Romeo on 7/20/25.
//  Revised by Michael Cather on 11/09/25
//

import Foundation
import SwiftUI

// ======================================================
// MARK: - Current Session
// ======================================================

public enum AuthLevel: String, Codable { case master, admin, user }
public enum RoleLevel: String, Codable { case view, interact, control }

@MainActor
public class CurrentSession: ObservableObject {

    // MARK: Navigation / State
    @Published public var routes = NavigationPath()

    @AppStorage("routingInProgress") public var routingInProgress: Bool = false
    @AppStorage("hasLoadedData") public var hasLoadedData: Bool = false
    @AppStorage("isFirstTime") public var isFirstTime: Bool = true

    // MARK: User identity
    @AppStorage("userId") public var userId: String = ""
    @AppStorage("userName") public var userName: String = ""
    @AppStorage("userEmail") public var userEmail: String = ""
    @AppStorage("userRole") public var userRole: String = ""

    // MARK: Current scope
    @AppStorage("currentState") public var currentState: String = ""
    @AppStorage("currentCountyId") public var currentCountyId: String = ""
    @AppStorage("currentCountyName") public var currentCountyName: String = ""

    /// Single source of truth for authorization. Examples: "driver", "mechanic", "admin", "master"
    @AppStorage("currentAuth") public var currentAuth: String = ""

    @AppStorage("needsAuthCheck") public var needsAuthCheck: Bool = false
    @AppStorage("syncIsOn") public var syncIsOn: Bool = false

    // Load state
    @Published public var isLoading: Bool = false {
        didSet {
            if isSigningOut && isLoading {
                isLoading = false
            }
        }
    }
    @Published public var user: CoreUser = CoreUser()

    // MARK: Sign out gating
    /// When true, ALL refresh/load flows and the loading overlay are suppressed.
    @Published public var isSigningOut: Bool = false

    // MARK: Trial persistence (for UI countdown etc)
    @AppStorage("trialEndsAt") public var trialEndsAt: Double = 0

    // MARK: Internals
    public var hasContractObserver = false

    // MARK: - Derived Permissions (Master inherits Admin)
    // entitlements is @Published, so changes WILL refresh the UI
    public var isMaster: Bool { self.currentAuth == AuthLevel.master.rawValue }
    public var isAdmin:  Bool { self.currentAuth == AuthLevel.admin.rawValue }
    public var canAdmin: Bool { isAdmin }

    // MARK: - Trial UI helpers (Option A)
    public var trialExpiresAt: Date? {
        self.trialEndsAt > 0 ? Date(timeIntervalSince1970: self.trialEndsAt) : nil
    }

    public var trialRemainingText: String {
        guard let exp = trialExpiresAt else { return "" }
        let secs = exp.timeIntervalSinceNow
        guard secs > 0 else { return "" }

        let days = Int(secs) / 86_400
        if days >= 1 { return "\(days)d" }

        let hours = (Int(secs) % 86_400) / 3_600
        let mins  = (Int(secs) % 3_600) / 60
        if hours >= 1 { return "\(hours)h \(mins)m" }
        return "\(mins)m"
    }

    /// Call this right BEFORE auth.signOut() and BEFORE clearing any AppStorage keys.
    /// This prevents any reactive `.onChange` / bootstrap logic from showing the loading screen.
    public func beginSignOut() {
        isSigningOut = true

        // Kill any visible loading immediately.
        isLoading = false

        // Stop routing flows.
        routingInProgress = false
        routes = NavigationPath()

        // Prevent "app thinks it has hydrated" while we tear down.
        hasLoadedData = false
        needsAuthCheck = false

        user = CoreUser()
    }

    public func clearForSignOut() {
        // Identity
        userId = ""
        userName = ""
        userEmail = ""
        userRole = ""

        // Auth / scope
        currentAuth = ""

        // Contract store
        trialEndsAt = 0

        // Routing + hydration
        routingInProgress = false
        hasLoadedData = false
        isFirstTime = true
        needsAuthCheck = false

        // Non-AppStorage state
        routes = NavigationPath()
        isLoading = false
        user = CoreUser()
    }

    /// Call when login/bootstrap completes successfully to re-enable loads.
    public func endSignOutGate() {
        isSigningOut = false
    }

    // ======================================================
    // MARK: - Public Refresh Flows
    // ======================================================

    public func hardRefresh() {
        print("Doing Hard Refresh")
        guard !isSigningOut else { return }
        guard !userId.isEmpty else { return }

        // Clear user-facing fields
        userName = ""
        userEmail = ""
        currentAuth = ""

        let uid = userId

        DataPuller.getUser(userId: uid) { [weak self] user in
            guard let self else { return }
            guard !self.isSigningOut else { return }

            print("CurrentSession - Loading User from Firebase: \(user)")

            self.applyUser(user)

            self.softRefresh()

            delayThenMain(5.0) {
                guard !self.isSigningOut else { return }
                self.isFirstTime = false
                self.hasLoadedData = true
            }

            print("Reloading Finished!")
        }
    }

    public func refreshUserData() {
        print("Refreshing User Data")
        guard !isSigningOut else { return }
        guard !userId.isEmpty else { return }

        userName = ""
        userEmail = ""
        currentAuth = ""

        let uid = userId

        DataPuller.getUser(userId: uid) { [weak self] user in
            guard let self else { return }
            guard !self.isSigningOut else { return }

            print("CurrentSession - Loading User from Firebase: \(user)")

            self.applyUser(user)
            print("Reloading Finished!")
        }
    }

    public func softRefresh() {
        print("Doing Soft Refresh")
        guard !isSigningOut else { return }
        guard !currentState.isEmpty, !currentCountyId.isEmpty else { return }

        let uid    = userId

        func runLoads() {
            guard !self.isSigningOut else { return }
            let isAdminFlag = self.isAdmin
            let role = self.userRole.lowercased()

            io {
                // Double-check inside background too (in case sign out happens mid-flight).
                if Task.isCancelled { return }
                if isAdminFlag {
                    DataPuller.getAllUsers()
                }

            }
        }

        // Step 1: refresh user so auth/role is current (after you change it)
        guard !uid.isEmpty else {
            runLoads()
            return
        }

        DataPuller.getUser(userId: uid) { [weak self] user in
            guard let self else { return }
            guard !self.isSigningOut else { return }
            self.applyUser(user)   // updates entitlements (published) + auth/role
            runLoads()             // now uses the updated isAdmin/userRole
        }
    }

    // MARK: - Loaders (kept for API compatibility)

    public func loadAdminData() {
        guard !isSigningOut else { return }
        guard !currentState.isEmpty, !currentCountyId.isEmpty else { return }
        let isAdminFlag = isAdmin
        io {
            if isAdminFlag { DataPuller.getAllUsers() }
        }
    }

   
    func showLoadingView() {
        guard !isSigningOut else { return }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            // if sign out started while timer is running, don't re-show anything
            guard !self.isSigningOut else { return }
            self.isLoading = false
            print("Delay complete")
        }
    }

    // ==================================================
    // MARK: - Internal mappers / entitlement plumbing
    // ==================================================

    public func applyUser(_ u: CoreUser) {
        main {
            guard !self.isSigningOut else { return }

            self.user = u
            self.userId = u.id
            self.userName = u.name
            self.userEmail = u.email

            self.currentAuth = u.auth.lowercased()
            self.userRole = u.role.lowercased()

        }
    }

    public var authLevel: AuthLevel {
        let a = currentAuth.lowercased()
        if a == "master" { return .master }
        if a == "admin"  { return .admin }
        return .user
    }

   

}

// MARK: - Bootstrap helper
extension CurrentSession {
    func primeFromBootstrap(_ u: CoreUser) {
        print("Priming session from bootstrap")

        // login/bootstrap completed -> allow loads again
        endSignOutGate()

        applyUser(u)


        softRefresh()

        isFirstTime = false
        hasLoadedData = true
        isLoading = false

    }
}

// MARK: - Offline bootstrap helper
extension CurrentSession {

    /// Allows app to proceed when offline by using already-persisted AppStorage values.
    /// Returns false if we don't have enough cached info to run offline (ex: first launch).
    @MainActor
    func primeFromOfflineCache() -> Bool {
        guard !userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Offline prime failed: no cached userId")
            return false
        }

        // offline bootstrap implies "session is active" -> allow loads again
        endSignOutGate()

        print("Priming session from OFFLINE cache")

        isFirstTime = false
        hasLoadedData = true
        isLoading = false

        return true
    }
}
