//
//  FirebaseSocial.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/5/24.
//

import Foundation
import RealmSwift
import FirebaseDatabase


class SocialTools {
    
    static let USER_TO_ORG = "UserToOrg"
    static let USER_TO_TEAM = "UserToTeam"
    static let USER_TO_SESSION = "UserToSession"
    
    // Add User to Org
    static func addUserToOrg(user: User, org: Organization) {
        
        let share = UserToOrganization()
        share.organizationId = org.id
        share.organizationName = org.name
        share.userId = user.id
        share.userName = user.userName
        
        firebaseDatabase { db in
            db.child(USER_TO_ORG)
                .child(share.id)
                .setValue(share.toDict())
        }
    }
    
    // Add User to Team
    static func addUserToTeam(user: User, team: Team) {
        
        let share = UserToTeam()
        share.teamId = team.id
        share.teamName = team.name
        share.userId = user.id
        share.userName = user.userName
        
        firebaseDatabase { db in
            db.child(USER_TO_TEAM)
                .child(share.id)
                .setValue(share.toDict())
        }
    }
    
    // Add User to Session
    static func addUserToSession(user: User, session: SessionPlan) {
        
        let share = UserToSession()
        share.sessionId = session.id
        share.sessionName = session.title
        share.userId = user.id
        share.userName = user.userName
        
        firebaseDatabase { db in
            db.child(USER_TO_SESSION)
                .child(share.id)
                .setValue(share.toDict())
        }
    }
    
    static func pullAllShares() {
        getShares(USER_TO_ORG)
        getShares(USER_TO_TEAM)
        getShares(USER_TO_SESSION)
    }
    
    static func getShares<T:Object>(_ sharePath: String, realmInstance: Realm=realm(), onResult: @escaping (List<T>) -> Void={ _ in }) {
        let dbRef = Database.database().reference()
        let usersRef = dbRef.child(sharePath)
        
        if let uId = UserTools.currentUserId {
            usersRef.queryOrdered(byChild: "userId")
                .queryEqual(toValue: uId)
                .observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists() {
                        if let objs = snapshot.toLudiObjects(T.self, realm: realmInstance) {
                            onResult(objs)
                        }
                    } else {
                        print("No Shares Found")
                    }
                }
        }
        
    }
    
}


func getFriendRequests(path: String, realmInstance: Realm=realm(), completion: @escaping (List<Friendship>?) -> Void={_ in}) {
    let dbRef = Database.database().reference()
    let usersRef = dbRef.child("friendRequests")
    
    if let uId = UserTools.currentUserId {
        usersRef.queryOrdered(byChild: "userId").queryEqual(toValue: uId)
            .observeSingleEvent(of: .value) { snapshot in
                
                if snapshot.exists() {
                    let objs = snapshot.toLudiObjects(Friendship.self, realm: realmInstance)
                    completion(objs)
                } else {
                    print("No Friend Requests Found")
                    completion(nil)
                }
            }
    }
    
}
