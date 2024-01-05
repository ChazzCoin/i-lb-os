//
//  User.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import RealmSwift

class SolKnight: Object, Identifiable {
    @objc dynamic var id: String = "1" // Primary key
    @objc dynamic var tempId: String = ""
    @objc dynamic var username: String = ""
    @objc dynamic var isLoggedIn: Bool = false
    @objc dynamic var status: String = "away"
    
    override static func primaryKey() -> String? {
        return "tempId"
    }
}


class SolUser: Object, Identifiable {
    @objc dynamic var id: String = "" // Primary key
    @objc dynamic var tempId: String = ""
    @objc dynamic var username: String = ""
    @objc dynamic var status: String = "away"
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class User: Object, Identifiable {
    @objc dynamic var id: String = "" // Primary key
    @objc dynamic var username: String = ""
    @objc dynamic var auth: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var phone: String = ""
    @objc dynamic var visibility: String = "closed"
    @objc dynamic var photoUrl: String = ""
    @objc dynamic var emailVerified: Bool = false
    @objc dynamic var dateCreated: String = getTimeStamp()
    @objc dynamic var dateUpdated: String = getTimeStamp()
    @objc dynamic var name: String = ""
    @objc dynamic var details: String = ""
    @objc dynamic var membership: String = ""
    @objc dynamic var status: String = "away"
    @objc dynamic var imgUrl: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}


//extension User {
//    func toDictionary() -> [String: Any] {
//        var dictionary: [String: Any] = [:]
//
//        dictionary["id"] = id
//        dictionary["username"] = username
//        dictionary["auth"] = auth
//        dictionary["email"] = email
//        dictionary["phone"] = phone
//        dictionary["visibility"] = visibility
//        dictionary["photoUrl"] = photoUrl
//        dictionary["emailVerified"] = emailVerified
//        dictionary["dateCreated"] = dateCreated
//        dictionary["dateUpdated"] = dateUpdated
//        dictionary["name"] = name
//        dictionary["details"] = details
//        dictionary["membership"] = membership
//        dictionary["status"] = status
//        dictionary["imgUrl"] = imgUrl
//
//        return dictionary
//    }
//    
//    static func fromDictionary(_ dictionary: [String: Any]) -> User {
//            let user = User()
//
//            user.id = dictionary["id"] as? String ?? ""
//            user.username = dictionary["username"] as? String ?? "joedoiest"
//            user.auth = dictionary["auth"] as? String ?? "SPARK_USER"
//            user.email = dictionary["email"] as? String ?? "UNASSIGNED_USER"
//            user.phone = dictionary["phone"] as? String ?? "UNASSIGNED_USER"
//            user.visibility = dictionary["visibility"] as? String ?? "closed"
//            user.photoUrl = dictionary["photoUrl"] as? String ?? "UNASSIGNED_USER"
//            user.emailVerified = dictionary["emailVerified"] as? Bool ?? false
//            user.dateCreated = dictionary["dateCreated"] as? String ?? "getDatabaseTimeStamp()"
//            user.dateUpdated = dictionary["dateUpdated"] as? String ?? "getDatabaseTimeStamp()"
//            user.name = dictionary["name"] as? String ?? "Joe Doe"
//            user.details = dictionary["details"] as? String ?? "nil"
//            user.membership = dictionary["membership"] as? Int ?? 0
//            user.status = dictionary["status"] as? String ?? "Away"
//            user.imgUrl = dictionary["imgUrl"] as? String ?? "nil"
//
//            return user
//        }
//}
