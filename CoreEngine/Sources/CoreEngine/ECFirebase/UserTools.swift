//
//  SignOut.swift
//  CM Transportation
//
//  Created by Michael Cather on 3/15/24.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase


public class UserTools {
    
    public static let isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    public static func setisLoggedIn(_ id: Bool) { UserDefaults.standard.set(id, forKey: "isLoggedIn") }
    
    public static let currentUserId: String? = UserDefaults.standard.string(forKey: "currentUserId")
    public static func setCurrentUserId(_ id: String?) { UserDefaults.standard.set(id, forKey: "currentUserId") }
    public static let currentUserName: String? = UserDefaults.standard.string(forKey: "currentUserName")
    public static func setCurrentUserName(_ name: String?) { UserDefaults.standard.set(name, forKey: "currentUserName") }
    public static let currentUserRole: String? = UserDefaults.standard.string(forKey: "currentUserRole")
    public static func setCurrentUserRole(_ role: String?) { UserDefaults.standard.set(role, forKey: "currentUserRole") }
    public static let currentUserAuth: String? = UserDefaults.standard.string(forKey: "currentUserAuth")
    public static func setCurrentUserAuth(_ auth: String?) { UserDefaults.standard.set(auth, forKey: "currentUserAuth") }
    
    public static let currentOrgId: String? = UserDefaults.standard.string(forKey: "currentOrgId")
    public static func setCurrentOrgId(_ id: String?) { UserDefaults.standard.set(id, forKey: "currentOrgId") }
    public static let currentTeamId: String? = UserDefaults.standard.string(forKey: "currentTeamId")
    public static func setCurrentTeamId(_ id: String?) { UserDefaults.standard.set(id, forKey: "currentTeamId") }
    public static let currentSessionId: String? = UserDefaults.standard.string(forKey: "currentSessionId")
    public static func setCurrentSessionId(_ id: String?) { UserDefaults.standard.set(id, forKey: "currentSessionId") }
    public static let currentActivityId: String? = UserDefaults.standard.string(forKey: "currentActivityId")
    public static func setCurrentActivityId(_ id: String?) { UserDefaults.standard.set(id, forKey: "currentActivityId") }
    
    public static let firebaseUser: FirebaseAuth.User? = Auth.auth().currentUser
    public static let firebaseUserId: String? = Auth.auth().currentUser?.uid
    
    public static func userIsVerifiedToProceed(overrideFlag:Bool=false) -> Bool {
        
        if overrideFlag {
            print("Overriding Verification Request")
            return true
        }
        
        if isLoggedIn {
            print("User IS Logged In")
            return true
        }
        print("User Is NOT Logged In")
        return false
        
    }
    
    public static func sendAuthChangeNotification() {
        NotificationCenter.default.post(name: NSNotification.Name("AuthChange"), object: nil)
    }
    
    public static func login(email: String, password: String, onResult: @escaping (AuthDataResult) -> Void, onError: @escaping (any Error) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                UserTools.setisLoggedIn(false)
                onError(error)
            } else {
                if let result = result {
                    print("Successfully logged in: \(result)")
                    UserTools.setisLoggedIn(true)
                    ifUserDoesNotExistThenCreateOne(fireUser: result.user)
                    onResult(result)
                }
                sendAuthChangeNotification()
            }
        }
    }
    
    public static func logout(completion: ((Bool, Error?) -> Void)? = nil) {
        do {
            try Auth.auth().signOut()
            UserTools.setisLoggedIn(false)
            clearUserDefaults()
            sendAuthChangeNotification()
            completion?(true, nil)
        } catch let signOutError as NSError {
            completion?(false, signOutError)
        }
    }
    
    public static func signUp(email: String, password: String, onError: @escaping (any Error) -> Void, onComplete: @escaping (FirebaseAuth.User) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            if let error = error {
                UserTools.setisLoggedIn(false)
                onError(error)
            } else {
                // Successfully signed up
                if let user = result?.user {
                    UserTools.setisLoggedIn(true)
                    UserTools.saveUserToRealm(fireUser: user)
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = user.displayName ?? ""
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print("Failed to update profile: \(error.localizedDescription)")
                        } else {
                            print("Successfully updated profile")
                        }
                    }
                    onComplete(user)
                }
                print("Successfully signed up")
                NotificationCenter.default.post(name: NSNotification.Name("AuthChange"), object: nil)
            }
        }
    }
    
    public static func syncUserDetails() {
        if let cui = currentUserId {
            firebaseDatabase { ref in
                ref.child(DatabasePaths.users.rawValue)
                    .child(cui)
                    .observeSingleEvent(of: .value) { snapshot, _ in
                        print("User SnapShot: \(snapshot)")
                        if let user = snapshot.toLudiObject(CoreUser.self, realm: newRealm()) {
                            setCurrentUserName(user.userName)
                            setCurrentUserAuth(user.auth)
                            setCurrentUserRole(user.role)
                        }
                    }
            }
        }
    }
    
    public static func saveUserToRealm(fireUser: FirebaseAuth.User) {
        let newUser = CoreUser()
        newUser.id = fireUser.uid
        setCurrentUserId(fireUser.uid)
        newUser.name = fireUser.displayName ?? ""
        newUser.email = fireUser.email ?? ""
        newRealm().safeWrite { r in
            r.create(CoreUser.self, value: newUser, update: .all)
        }
        UserTools.saveUserToFirebase(user: newUser)
    }
    
    public static func saveUserToFirebase(user:CoreUser) {
        firebaseDatabase { db in
            db.saveUser(obj: user)
        }
    }
    
    public static func forgotPassword(email: String, onSuccess: @escaping () -> Void, onError: @escaping (any Error) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                onError(error)
            } else {
                onSuccess()
            }
        }
    }
    
    public static func ifUserDoesNotExistThenCreateOne(fireUser: FirebaseAuth.User) {
        checkUserExistsById(fireUser.uid, completion: { result in
            if !result {
                print("User Does Not Exist, Saving New User Record to Firebase.")
                let newUser = CoreUser()
                newUser.id = fireUser.uid
                newUser.email = fireUser.email ?? ""
                newUser.name = fireUser.displayName ?? "new"
                newUser.auth = "new"
                saveUser(user: newUser, onComplete: { innerResult in
                    print("Saved New User to Firebase: \(innerResult)")
                })
            } else {
                print("User Already Exist. Moving On.")
                syncUserDetails()
            }
        })
    }
    
    public static func saveUser(user: CoreUser, onComplete: @escaping (Bool) -> Void) {
        print("Save New User")
        if user.id.isEmpty {return}
        firebaseDatabase { ref in
            ref.child(DatabasePaths.users.rawValue)
                .child(user.id)
                .updateChildValues(user.toDict()) { error, _ in
                    if let error = error {
                        // Handle any errors here
                        print("Error writing document: \(error)")
                        onComplete(false)
                    } else {
                        // Data successfully written
                        print("Data successfully written!")
                        onComplete(true)
                    }
                }
        }
    }
    
    public static func checkUserExistsById(_ id: String, completion: @escaping (Bool) -> Void) {
        print("checkUserExistsById")
        if id.isEmpty {return}
        let dbRef = Database.database().reference()
        let usersRef = dbRef.child(DatabasePaths.users.rawValue)
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
    
    public static func checkUsernameExists(_ username: String, completion: @escaping (Bool) -> Void) {
        let dbRef = Database.database().reference()
        let usersRef = dbRef.child("users")

        usersRef.queryOrdered(byChild: "userName").queryEqual(toValue: username)
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

    public static func checkEmailExists(_ email: String, completion: @escaping (Bool) -> Void) {
        let dbRef = Database.database().reference()
        let usersRef = dbRef.child("users")

        usersRef.queryOrdered(byChild: "email").queryEqual(toValue: email)
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
    
    // UserDefault Functions
    public static func clearUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "currentUserId")
        defaults.removeObject(forKey: "currentUserName")
        defaults.removeObject(forKey: "currentUserRole")
        defaults.removeObject(forKey: "currentUserAuth")
        defaults.removeObject(forKey: "currentOrgId")
        defaults.removeObject(forKey: "currentTeamId")
        defaults.removeObject(forKey: "currentSessionId")
        defaults.removeObject(forKey: "currentActivityId")
    }
}
