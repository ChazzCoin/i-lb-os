//
//  FirebaseLogin.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/27/23.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

func checkUsernameExists(_ username: String, completion: @escaping (Bool) -> Void) {
    let dbRef = Database.database().reference()
    let usersRef = dbRef.child("users")

    usersRef.queryOrdered(byChild: "username").queryEqual(toValue: username)
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

func syncUserFromFirebaseDb(_ email: String, completion: @escaping (Bool) -> Void) {
    let dbRef = Database.database().reference()
    let usersRef = dbRef.child("users")

    usersRef.queryOrdered(byChild: "email").queryEqual(toValue: email)
        .observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("User Does Exist.")
                let temp = snapshot.toHashMap()
                let tempp = temp.first?.value as? [String:Any?]
                realm().updateGetCurrentSolUser { u in
                    u.userName = tempp?["userName"] as? String ?? ""
                }
                completion(true)
            } else {
                print("User Does Not Exist.")
                completion(false)
            }
        }
}

func saveUserToRealtimeDatabase(user: CurrentSolUser, onComplete: @escaping (Bool) -> Void) {
    let dbRef = Database.database().reference()
    let usersRef = dbRef.child("users").child(user.userId)

    usersRef.setValue(user.toDict()) { error, _ in
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


func signUpWithEmail(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        if let authResult = authResult {
            completion(.success(authResult))
        } else {
            // This case is unlikely, but it's good to handle a situation where authResult is nil
            completion(.failure(NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
        }
    }
}

func getFirebaseUser() -> FirebaseAuth.User? {
    return Auth.auth().currentUser
}

func isLoggedIntoFirebase() -> Bool {
    
    if let _ = Auth.auth().currentUser {
        return true
    }
    return false
    
}

func loginUser(withEmail email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        realm().updateGetCurrentSolUser { u in
            if let user = Auth.auth().currentUser {
                u.userId = user.uid
                u.email = user.email ?? ""
                u.imgUrl = user.photoURL?.absoluteString ?? ""
                u.isLoggedIn = true
                saveUserToRealtimeDatabase(user: u) { result in
                    print(result)
                }
            }
        }
        completion(.success(()))
    }
}

func logoutUser(completion: @escaping (Result<Void, Error>) -> Void) {
    do {
        try Auth.auth().signOut()
        completion(.success(()))
    } catch let signOutError as NSError {
        completion(.failure(signOutError))
    }
}
