//
//  FireUser.swift
//  CoreEngine
//
//  Created by Charles Romeo on 7/10/25.
//
import Foundation
import SwiftUI
import FirebaseAuth

public func generateRandomUserId() -> String {
    let firstNames = [
        "Liam", "Olivia", "Noah", "Emma", "Ava", "Sophia", "Isabella",
        "Ethan", "Mia", "Mason", "Charlotte", "Amelia", "James",
        "Benjamin", "Lucas", "Harper", "Evelyn", "Henry", "Alexander"
    ]
    
    let randomFirst = firstNames.randomElement() ?? "John"
    let randomNumber = Int.random(in: 1000...9999) // 4-digit number
    
    return "\(randomFirst)-\(randomNumber)"
}

public func generateRandomName() -> String {
    let firstNames = [
        "Liam", "Olivia", "Noah", "Emma", "Ava", "Sophia", "Isabella",
        "Ethan", "Mia", "Mason", "Charlotte", "Amelia", "James",
        "Benjamin", "Lucas", "Harper", "Evelyn", "Henry", "Alexander"
    ]
    
    let lastNames = [
        "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia",
        "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez",
        "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor"
    ]
    
    let randomFirst = firstNames.randomElement() ?? "John"
    let randomLast = lastNames.randomElement() ?? "Doe"
    
    return "\(randomFirst) \(randomLast)"
}

public class UserAuthenticator: ObservableObject {
    enum State {
        case loading
        case signedOut
        case bootstrapping
        case signedIn
    }


    @Published var state: State = .loading {
        didSet {
            log("state → \(state)")
        }
    }

    @AppStorage("userId") private var storedUserId: String = "" {
        didSet { log("AppStorage.userId set → \(storedUserId)") }
    }
    @AppStorage("isConnected") private var isConnected: Bool = true

    // Optional session we populate after auth
    public weak var CS: CurrentSession?

    // Firebase auth state listener handle
    public var handle: AuthStateDidChangeListenerHandle?

    // MARK: - Init

    /// Do NOT touch Firebase in init. Attach the session if you have it.
    public init(session: CurrentSession? = nil) {
        self.CS = session
        log("init (deferred; no Firebase access yet)")
    }

    /// If you need to attach the session after init.
    public func attachSession(_ session: CurrentSession) {
        self.CS = session
        log("attachSession()")
        if state == .signedIn { runBootstrapIfPossible() }
    }

    // MARK: - Lifecycle

    public func start() {
        guard handle == nil else {
            log("start() ignored — already started")
            return
        }
        log("start() — adding Firebase auth state listener")

        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }

            if let user = user {
                self.log("Firebase user → \(user.uid)")
                if self.storedUserId.isEmpty { self.storedUserId = user.uid }

                DispatchQueue.main.async {
                    if self.storedUserId.isEmpty {
                        // weird edge case: firebase logged in user but no stored id yet
                        self.state = .signedOut
                    } else {
                        // We know you're authenticated with Firebase,
                        // but we haven't hydrated CurrentSession yet.
                        self.state = .bootstrapping
                        self.runBootstrapIfPossible()
                    }
                }

            } else {
                self.log("Firebase user → nil (signed out)")
                DispatchQueue.main.async {
                    self.state = .signedOut
                }
            }
        }
    }


    public func signOut() {
        log("signOut() called")
        do {
            try Auth.auth().signOut()
            storedUserId = ""   // router flips immediately
            log("signOut() success")
            // remove: state = .signedOut  (listener will handle it)
        } catch {
            log("signOut() failed: \(error.localizedDescription)")
        }
    }

    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
        log("deinit")
    }

    // MARK: - Bootstrap

    public func runBootstrapIfPossible() {
        guard let uid = Auth.auth().currentUser?.uid else {
            log("bootstrap skipped: no currentUser")
            return
        }
        guard let CS else {
            log("bootstrap deferred: no CurrentSession attached")
            return
        }
        bootstrapAfterAuth(uid: uid, CS: CS)
    }

    /// Centralized post-auth data loading
    /// Centralized post-auth data loading (offline-safe + timeout)
    public func bootstrapAfterAuth(uid: String, CS: CurrentSession) {
        log("🪄 bootstrap start for uid=\(uid) (isConnected=\(isConnected))")

        let timeoutSeconds: Double = 8.0
        let lock = NSLock()
        var didFinish = false

        func finishSignedIn(using user: CoreUser?) {
            lock.lock()
            defer { lock.unlock() }
            guard !didFinish else { return }
            didFinish = true

            DispatchQueue.main.async {
                if let user {
                    CS.primeFromBootstrap(user)
                    self.log("🪄 bootstrap done; hydrated from network")
                    self.state = .signedIn
                    return
                }

                // Offline / timeout fallback
                if CS.primeFromOfflineCache() {
                    self.log("🪄 bootstrap fallback; signed in from OFFLINE cache")
                    self.state = .signedIn
                } else {
                    self.log("🪄 bootstrap fallback failed; forcing signedOut (need internet for first login)")
                    self.state = .signedOut
                }
            }
        }

        // Watchdog so overlay can never hang forever
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + timeoutSeconds) { [weak self] in
            guard let self else { return }
            self.log("⏱️ bootstrap timeout after \(timeoutSeconds)s — falling back")
            finishSignedIn(using: nil)
        }

        // Heavy work off main
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }

            // If you're offline, don't even attempt network fetch; go straight to cached session
            guard self.isConnected else {
                self.log("Offline at bootstrap start — skipping DataPuller.getUser")
                finishSignedIn(using: nil)
                return
            }

            if let fireUser = Auth.auth().currentUser {
                ifUserDoesNotExistThenCreateOne(fireUser: fireUser)
            }

            self.getUser(userId: uid, onSafeResult: { user in
                finishSignedIn(using: user)
            })
        }
    }

    public func performBackground(_ work: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async(execute: work)
    }

    // MARK: - Logging
    public func log(_ msg: String) {
        print("🧭 [UserAuth] \(msg)")
    }
    
    // MARK: - User creation / existence

    public func ifUserDoesNotExistThenCreateOne(fireUser: FirebaseAuth.User) {
        checkUserExistsById(fireUser.uid, completion: { result in
            if !result {
                print("User Does Not Exist, Saving New User Record to Firebase.")

                self.performBackground {
                    autoreleasepool {
                        let realm = newRealm()
                        let newUser = CoreUser()
                        newUser.id = fireUser.uid
                        newUser.email = fireUser.email ?? ""
                        newUser.name = fireUser.displayName ?? "new"
                        newUser.auth = "new"

                        do {
                            try realm.write {
                                realm.create(CoreUser.self, value: newUser, update: .all)
                            }
                        } catch {
                            print("❌ Realm write failed when creating new User: \(error)")
                        }

                        // Save to Firebase (network, not Realm)
                        self.saveUser(user: newUser) { innerResult in
                            print("Saved New User to Firebase: \(innerResult)")
                        }
                    }
                }
            } else {
                print("User Already Exist. Moving On.")
            }
        })
    }

    public func saveUser(user: CoreUser, onComplete: @escaping (Bool) -> Void) {
        print("Save New User")
        if user.id.isEmpty { onComplete(false); return }

        firebaseDatabase { ref in
            ref.child(DatabasePaths.users.rawValue)
                .child(user.id)
                .updateChildValues(user.toDict()) { error, _ in
                    if let error = error {
                        print("Error writing user: \(error)")
                        onComplete(false)
                    } else {
                        print("User data successfully written!")
                        onComplete(true)
                    }
                }
        }
    }
    
    public func checkUserExistsById(_ id: String, completion: @escaping (Bool) -> Void) {
        print("checkUserExistsById")
        if id.isEmpty { completion(false); return }

        firebaseDatabase { ref in
            let usersRef = ref.child(DatabasePaths.users.rawValue)
            usersRef
                .child(id)
                .observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists() {
                        print("User Does Exist.")
                        completion(true)
                    } else {
                        print("User Does Not Exist.")
                        completion(false)
                    }
                }
        }
        
    }
    
    public func getUser(
        userId: String,
        onSafeResult: @escaping (CoreUser) -> Void
    ) {
        firebaseDatabase { ref in
            ref.child(DatabasePaths.users.rawValue)
                .child(userId)
                .observeSingleEvent(of: .value) { snapshot, _ in
                    print("User SnapShot: \(snapshot)")

                    // Do Realm work on a background queue
                    self.performBackground {
                        autoreleasepool {
                            let realm = newRealm()   // opened on THIS thread

                            // This should create/update a *managed* User in Realm
                            guard let managed = snapshot.toCoreObject(CoreUser.self, realm: realm) else {
                                print("❌ getUser: could not map snapshot to User")
                                return
                            }

                            // DETACH: create an unmanaged copy that is safe to cross threads
                            let detachedUser = CoreUser(value: managed)

                            // Hop back to main with the detached object
                            DispatchQueue.main.async {
                                onSafeResult(detachedUser)   // safe to use inside @MainActor CurrentSession
                            }
                        }
                    }
                }
        }
    }

    public func getAllUsers(completion: (() -> Void)? = nil) {
        firebaseDatabase { ref in
            ref.child(DatabasePaths.users.rawValue)
                .observeSingleEvent(of: .value) { snapshot, _ in
                    print("Users SnapShot: \(snapshot)")

                    self.performBackground {
                        autoreleasepool {
                            let realm = newRealm()
                            _ = snapshot.toCoreObject(CoreUser.self, realm: realm)
                        }

                        if let completion = completion {
                            DispatchQueue.main.async {
                                completion()
                            }
                        }
                    }
                }
        }
    }
}

