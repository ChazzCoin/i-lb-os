//
//  FirebaseLogin.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/27/23.
//

import Foundation
import SwiftUI
import RealmSwift
import FirebaseAuth
//import FirebaseFirestore
import FirebaseDatabase
//import FirebaseAnalytics
import CoreEngine


//func syncUserFromFirebaseDb(_ email: String, realmInstance: Realm=realm(), completion: @escaping (Bool) -> Void) {
//    let dbRef = Database.database().reference()
//    let usersRef = dbRef.child("users")
//
//    usersRef.queryOrdered(byChild: "email").queryEqual(toValue: email)
//        .observeSingleEvent(of: .value) { snapshot in
//            if snapshot.exists() {
//                snapshot.parseSingleObject { obj in
//                    do {
//                        let result = CurrentSolUser(dictionary: obj as [String : Any])
//                        try realmInstance.write {
//                            let r = realmInstance.create(CurrentSolUser.self, value: result, update: .all)
//                            print("Successful CurrentSolUser Parsing: [ \(r) ]")
//                        }
//                    } catch {
//                        print("Failed to write to Realm")
//                    }
//                }
//                completion(true)
//            } else {
//                print("User Does Not Exist.")
//                completion(false)
//            }
//        }
//}
//
//func syncUserFromFirebaseDb(realmInstance: Realm=realm(), onResult: @escaping (CurrentSolUser) -> Void = { _ in }, completion: @escaping (Bool) -> Void) {
//    
//    safeFirebaseUserId() { uId in
//        let dbRef = Database.database().reference()
//        let usersRef = dbRef.child("users")
//
//        usersRef.child(uId).observeSingleEvent(of: .value) { snapshot in
//            if snapshot.exists() {
//                if let r = snapshot.toLudiObject(CurrentSolUser.self, realm: realmInstance) {
//                    print("Successful CurrentSolUser Parsing: [ \(r) ]")
//                    onResult(r)
//                }                
//                completion(true)
//            } else {
//                print("User Does Not Exist.")
//                completion(false)
//            }
//        }
//    }
//    
//    
//}

//func saveUserToRealtimeDatabase(user: CurrentSolUser?=nil, onComplete: @escaping (Bool) -> Void) {
//    
//    var u = user
//    if user == nil {
//        realm().getCurrentSolUser() { ser in
//            u = ser
//        }
//    }
//    
//    if let us = u {
//        let dbRef = Database.database().reference()
//        let usersRef = dbRef.child("users").child(us.userId)
//        usersRef.updateChildValues(us.toDict()) { error, _ in
//            if let error = error {
//                // Handle any errors here
//                print("Error writing document: \(error)")
//                onComplete(false)
//            } else {
//                // Data successfully written
//                print("Data successfully written!")
//                onComplete(true)
//            }
//        }
//    }
//    
//}


//func signUpWithEmail(email: String, password: String, userName:String="", realmInstance: Realm=realm(), completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
//    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//        if let error = error {
//            completion(.failure(error))
//            return
//        }
//
//        if let authResult = authResult {
//            
//            let user = authResult.user
//            realmInstance.updateGetCurrentSolUser { u in
//                u.userId = user.uid
//                u.userName = userName
//                u.email = email
//                u.imgUrl = user.photoURL?.absoluteString ?? ""
//                u.isLoggedIn = true
//                saveUserToRealtimeDatabase(user: u) { result in
//                    print(result)
//                }
//            }
//            completion(.success(authResult))
//        } else {
//            // This case is unlikely, but it's good to handle a situation where authResult is nil
//            completion(.failure(NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
//        }
//    }
//}

//func quickSyncFireUser(updateRealtimeDb:Bool=false) {
//    let user = Auth.auth().currentUser
//    let r = realm()
//    r.updateGetCurrentSolUser { u in
//        u.userId = user?.uid ?? ""
//        u.email = user?.email ?? ""
//        u.imgUrl = user?.photoURL?.absoluteString ?? ""
//        u.isLoggedIn = true
//        if updateRealtimeDb {
//            saveUserToRealtimeDatabase(user: u) { result in
//                print(result)
//            }
//        }
//    }
//    r.invalidate()
//}

//func getFirebaseUser() -> FirebaseAuth.User? {
//    return Auth.auth().currentUser
//}
//
//func getFirebaseUserId() -> String? {
//    return Auth.auth().currentUser?.uid
//}
//
//func getFirebaseUserIdOrCurrentLocalId() -> String {
//    return Auth.auth().currentUser?.uid ?? CURRENT_USER_ID
//}
//
//func safeFirebaseUserId(safe: (String) -> Void) {
//    if let userId = Auth.auth().currentUser?.uid {
//        safe(userId)
//    }
//}
//
//func userIsVerifiedToProceed(overrideFlag:Bool=false) -> Bool {
//    
//    if overrideFlag {
//        print("Overriding Verification Request")
//        return true
//    }
//    
//    if let _ = Auth.auth().currentUser {
//        print("User IS Logged In")
//        return true
//    }
//    print("User Is NOT Logged In")
//    return false
//    
//}

//func loginUser(withEmail email: String, password: String, completion: @escaping (Bool) -> Void) {
//    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
//        if let _ = error {
//            completion(false)
//            return
//        }
//        syncUserFromFirebaseDb(email) { result in
//            print(result)
//        }
//        completion(true)
//    }
//}
//
//func logoutUser(completion: @escaping (Result<Void, Error>) -> Void) {
//    do {
//        try Auth.auth().signOut()
//        newRealm().updateGetCurrentSolUser { user in
//            user.userId = ""
//            user.userName = ""
//            user.email = ""
//            user.isLoggedIn = false
//            user.imgUrl = ""
//        }
//        CodiChannel.ON_LOG_IN_OUT.send(value: "logout")
//        completion(.success(()))
//    } catch let signOutError as NSError {
//        completion(.failure(signOutError))
//    }
//}
