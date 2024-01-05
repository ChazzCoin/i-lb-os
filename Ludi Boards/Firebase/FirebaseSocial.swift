//
//  FirebaseSocial.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/5/24.
//

import Foundation
import RealmSwift
import FirebaseDatabase


func getFriendRequests(realmInstance: Realm=realm(), completion: @escaping (List<Request>?) -> Void={_ in}) {
    let dbRef = Database.database().reference()
    let usersRef = dbRef.child("friendRequests")
    
    if let uId = getFirebaseUserId() {
        usersRef.queryOrdered(byChild: "toUserId").queryEqual(toValue: uId)
            .observeSingleEvent(of: .value) { snapshot in
                
                if snapshot.exists() {
                    let objs = snapshot.toLudiObjects(Request.self, realm: realmInstance)
                    completion(objs)
                } else {
                    print("No Friend Requests Found")
                    completion(nil)
                }
            }
    }
    
    
}
