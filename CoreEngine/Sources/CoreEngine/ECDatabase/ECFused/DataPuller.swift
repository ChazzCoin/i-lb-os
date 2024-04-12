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
        self.queryEqual(toValue: value, childKey: field).pull(obj, onReturn: onReturn)
    }
    func fuseByField<T:Object>(_ obj: T.Type, value: String, field: String="id", realm: Realm=newRealm(), onReturn: @escaping (List<T>) -> Void={ _ in }) -> DatabaseHandle {
        return self.queryEqual(toValue: value, childKey: field).fuse(obj, onReturn: onReturn)
    }
}

public class DataPuller {
    
    static func getUser(userId:String, realm: Realm=newRealm(), onSafeResult: @escaping (CoreUser) -> Void) {
        firebaseDatabase { ref in
            ref.child(DatabasePaths.users.rawValue)
                .child(userId)
                .observeSingleEvent(of: .value) { snapshot, _ in
                    print("User SnapShot: \(snapshot)")
                    let user = snapshot.toCoreObject(CoreUser.self, realm: realm)
                    if let user = user {
                        print("We have a user: \(user)")
                        onSafeResult(user)
                    }
                }
        }
    }
    
    static func getListOfUsers(ids: [String], realm: Realm=newRealm()) {
        firebaseDatabase { ref in
            for id in ids {
                ref.child(DatabasePaths.users.rawValue)
                    .child(id)
                    .pull(CoreUser.self)
//                    .observeSingleEvent(of: .value) { snapshot, _ in
//                        print("Users SnapShot: \(snapshot)")
//                        let _ = snapshot.toCoreObject(CoreUser.self, realm: realm)
//                    }
            }
        }
    }
    
    static func getAllUsers(realm: Realm=newRealm()) {
        firebaseDatabase { ref in
            ref.child(DatabasePaths.users.rawValue)
                .observeSingleEvent(of: .value) { snapshot, _ in
                    print("Users SnapShot: \(snapshot)")
                    let _ = snapshot.toCoreObjects(CoreUser.self, realm: realm)
                }
        }
    }
    
    // Organizations
    
    static func getOrganization(orgId:String, realm: Realm=newRealm(), onSafeResult: @escaping (Organization) -> Void) {
        firebaseDatabase { ref in
            ref.child(DatabasePaths.organizations.rawValue)
                .child(orgId)
                .observeSingleEvent(of: .value) { snapshot, _ in
                    print("Organization SnapShot: \(snapshot)")
                    let org = snapshot.toCoreObject(Organization.self, realm: realm)
                    if let org = org {
                        print("We have a Organization: \(org)")
                        onSafeResult(org)
                    }
                }
        }
    }
    
    static func getAllOrganizations(realm: Realm=newRealm()) {
        firebaseDatabase { ref in
            ref.child(DatabasePaths.organizations.rawValue)
                .observeSingleEvent(of: .value) { snapshot, _ in
                    print("Organization SnapShot: \(snapshot)")
                    let _ = snapshot.toCoreObjects(Organization.self, realm: realm)
                }
        }
    }
    
    // Teams
        //  by id
        //  by OrgId
        //  by Share
    
    static func getTeam(teamId:String, realm: Realm=newRealm(), onSafeResult: @escaping (Team) -> Void) {
        firebaseDatabase { ref in
            ref.child(DatabasePaths.teams.rawValue)
                .child(teamId)
                .observeSingleEvent(of: .value) { snapshot, _ in
                    print("Team SnapShot: \(snapshot)")
                    let team = snapshot.toCoreObject(Team.self, realm: realm)
                    if let team = team {
                        print("We have a Team: \(team)")
                        onSafeResult(team)
                    }
                }
        }
    }
    
    // Sessions
    
    // Activities
    
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
