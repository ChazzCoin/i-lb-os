//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/5/24.
//

import Foundation
import FirebaseDatabase

class FirebaseUserSearch {
    let usersRef = Database.database().reference().child("users")

    // Search for users where name or userName matches the search term
    func searchUsersByNameOrUserName(searchTerm: String, completion: @escaping ([CoreUser]) -> Void) {
        // First query: Search by name
        let nameQuery = usersRef.queryOrdered(byChild: "name").queryEqual(toValue: searchTerm)
        
        // Second query: Search by userName
        let userNameQuery = usersRef.queryOrdered(byChild: "userName").queryEqual(toValue: searchTerm)
        
        let dispatchGroup = DispatchGroup()
        var searchResults = [CoreUser]()

        dispatchGroup.enter()
        nameQuery.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if let user = CoreUser.fromSnap(snapshot: child) {
                    searchResults.safeAppend(user)
                }
            }
            dispatchGroup.leave()
        })
        
        dispatchGroup.enter()
        userNameQuery.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if let user = CoreUser.fromSnap(snapshot: child), !searchResults.contains(where: { $0.id == user.id }) {
                    searchResults.safeAppend(user)
                }
            }
            dispatchGroup.leave()
        })
        
        dispatchGroup.notify(queue: .main) {
            completion(searchResults)
        }
    }
}
extension Array where Element == CoreUser {
    mutating func safeAppend(_ newUser: CoreUser) {
        // Check if the array already contains an element with the same id as newUser
        if !self.contains(where: { $0.id == newUser.id }) {
            self.append(newUser)
        }
    }
}
