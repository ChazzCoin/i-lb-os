//
//  DataPuller.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 3/28/24.
//

import Foundation
import FirebaseDatabase
import RealmSwift

class DataPuller {
    
    static func getUser(userId:String, realm: Realm?=newRealm(), onSafeResult: @escaping (User) -> Void) {
        firebaseDatabase { ref in
            ref.child(DatabasePaths.users.rawValue)
                .child(userId)
                .observeSingleEvent(of: .value) { snapshot, _ in
                    print("User SnapShot: \(snapshot)")
                    let user = snapshot.toLudiObject(User.self, realm: realm)
                    if let user = user {
                        print("We have a user: \(user)")
                        onSafeResult(user)
                    }
                }
        }
    }
    
    static func getAllUsers(realm: Realm?=newRealm()) {
        firebaseDatabase { ref in
            ref.child(DatabasePaths.users.rawValue)
                .observeSingleEvent(of: .value) { snapshot, _ in
                    print("Users SnapShot: \(snapshot)")
                    let _ = snapshot.toLudiObjects(User.self, realm: realm)
                }
        }
    }
    
    // Organizations
    
    static func getOrganization(orgId:String, realm: Realm?=newRealm(), onSafeResult: @escaping (Organization) -> Void) {
        firebaseDatabase { ref in
            ref.child(DatabasePaths.organizations.rawValue)
                .child(orgId)
                .observeSingleEvent(of: .value) { snapshot, _ in
                    print("Organization SnapShot: \(snapshot)")
                    let org = snapshot.toLudiObject(Organization.self, realm: realm)
                    if let org = org {
                        print("We have a Organization: \(org)")
                        onSafeResult(org)
                    }
                }
        }
    }
    
    static func getAllOrganizations(realm: Realm?=newRealm()) {
        firebaseDatabase { ref in
            ref.child(DatabasePaths.organizations.rawValue)
                .observeSingleEvent(of: .value) { snapshot, _ in
                    print("Organization SnapShot: \(snapshot)")
                    let _ = snapshot.toLudiObjects(Organization.self, realm: realm)
                }
        }
    }
    
    // Teams
        //  by id
        //  by OrgId
        //  by Share
    
    static func getTeam(teamId:String, realm: Realm?=newRealm(), onSafeResult: @escaping (Team) -> Void) {
        firebaseDatabase { ref in
            ref.child(DatabasePaths.teams.rawValue)
                .child(teamId)
                .observeSingleEvent(of: .value) { snapshot, _ in
                    print("Team SnapShot: \(snapshot)")
                    let team = snapshot.toLudiObject(Team.self, realm: realm)
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
