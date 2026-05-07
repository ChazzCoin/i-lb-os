//
//  DataPuller.swift
//  CoreEngine
//
//  Created by Charles Romeo on 1/24/26.
//

import RealmSwift

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
