//
//  DataPuller.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 3/28/24.
//

import Foundation
import FirebaseDatabase
import RealmSwift

public extension DatabaseQuery {
    
    func pull<T:Object>(_ obj: T.Type, realm: Realm=newRealm(), onReturn: @escaping (List<T>) -> Void={ _ in }) {
        self.observeSingleEvent(of: .value) { snapshot, _ in
            if let items = snapshot.toCoreObjects(T.self, realm: realm) {
                print("Successfully Fused In From Firebase.")
                onReturn(items)
            }
        }
    }
    func fuse<T:Object>(_ obj: T.Type, realm: Realm=newRealm(), onReturn: @escaping (List<T>) -> Void={ _ in }) -> DatabaseHandle {
        return self.observe(.value) { snapshot in
            if let items = snapshot.toCoreObjects(T.self, realm: realm) {
                print("Successfully Fused In From Firebase.")
                onReturn(items)
            }
        }
    }
    func pullByField<T:Object>(_ obj: T.Type, value: String, field: String="id", realm: Realm=newRealm(), onReturn: @escaping (List<T>) -> Void={ _ in }) {
        self.queryOrdered(byChild: field).queryEqual(toValue: value).pull(obj, realm: realm, onReturn: onReturn)
    }
    func fuseByField<T:Object>(_ obj: T.Type, value: String, field: String="id", realm: Realm=newRealm(), onReturn: @escaping (List<T>) -> Void={ _ in }) -> DatabaseHandle {
        return self.queryEqual(toValue: value, childKey: field).fuse(obj, realm: realm, onReturn: onReturn)
    }
    
}



//class FirebaseUserSearch {
//    let usersRef = Database.database().reference().child("users")
//
//    // Search for users where name or userName matches the search term
//    func searchUsersByNameOrUserName(searchTerm: String, completion: @escaping ([CoreUser]) -> Void) {
//        // First query: Search by name
//        let nameQuery = usersRef.queryOrdered(byChild: "name").queryEqual(toValue: searchTerm)
//        
//        // Second query: Search by userName
//        let userNameQuery = usersRef.queryOrdered(byChild: "userName").queryEqual(toValue: searchTerm)
//        
//        let dispatchGroup = DispatchGroup()
//        var searchResults = [CoreUser]()
//
//        dispatchGroup.enter()
//        nameQuery.observeSingleEvent(of: .value, with: { snapshot in
//            for child in snapshot.children.allObjects as! [DataSnapshot] {
//                if let user = CoreUser.fromSnap(snapshot: child) {
//                    searchResults.safeAppend(user)
//                }
//            }
//            dispatchGroup.leave()
//        })
//        
//        dispatchGroup.enter()
//        userNameQuery.observeSingleEvent(of: .value, with: { snapshot in
//            for child in snapshot.children.allObjects as! [DataSnapshot] {
//                if let user = CoreUser.fromSnap(snapshot: child), !searchResults.contains(where: { $0.id == user.id }) {
//                    searchResults.safeAppend(user)
//                }
//            }
//            dispatchGroup.leave()
//        })
//        
//        dispatchGroup.notify(queue: .main) {
//            completion(searchResults)
//        }
//    }
//}
//extension Array where Element == CoreUser {
//    mutating func safeAppend(_ newUser: CoreUser) {
//        // Check if the array already contains an element with the same id as newUser
//        if !self.contains(where: { $0.id == newUser.id }) {
//            self.append(newUser)
//        }
//    }
//}
