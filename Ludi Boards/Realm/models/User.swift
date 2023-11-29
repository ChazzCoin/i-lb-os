//
//  User.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var id: String = "" // Primary key
    @objc dynamic var username: String = "joedoiest"
    @objc dynamic var auth: String = "SPARK_USER"
    @objc dynamic var email: String = "UNASSIGNED_USER"
    @objc dynamic var phone: String = "UNASSIGNED_USER"
    @objc dynamic var visibility: String = "closed"
    @objc dynamic var photoUrl: String = "UNASSIGNED_USER"
    @objc dynamic var emailVerified: Bool = false
    @objc dynamic var dateCreated: String = "getDatabaseTimeStamp()"
    @objc dynamic var dateUpdated: String = "getDatabaseTimeStamp()"
    @objc dynamic var name: String = "Joe Doe"
    @objc dynamic var details: String = "nil"
    @objc dynamic var membership: Int = 0
    @objc dynamic var status: String = "Away"
    @objc dynamic var imgUrl: String = "nil"
    

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension User {
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]

        dictionary["id"] = id
        dictionary["username"] = username
        dictionary["auth"] = auth
        dictionary["email"] = email
        dictionary["phone"] = phone
        dictionary["visibility"] = visibility
        dictionary["photoUrl"] = photoUrl
        dictionary["emailVerified"] = emailVerified
        dictionary["dateCreated"] = dateCreated
        dictionary["dateUpdated"] = dateUpdated
        dictionary["name"] = name
        dictionary["details"] = details
        dictionary["membership"] = membership
        dictionary["status"] = status
        dictionary["imgUrl"] = imgUrl

        return dictionary
    }
    
    static func fromDictionary(_ dictionary: [String: Any]) -> User {
            let user = User()

            user.id = dictionary["id"] as? String ?? ""
            user.username = dictionary["username"] as? String ?? "joedoiest"
            user.auth = dictionary["auth"] as? String ?? "SPARK_USER"
            user.email = dictionary["email"] as? String ?? "UNASSIGNED_USER"
            user.phone = dictionary["phone"] as? String ?? "UNASSIGNED_USER"
            user.visibility = dictionary["visibility"] as? String ?? "closed"
            user.photoUrl = dictionary["photoUrl"] as? String ?? "UNASSIGNED_USER"
            user.emailVerified = dictionary["emailVerified"] as? Bool ?? false
            user.dateCreated = dictionary["dateCreated"] as? String ?? "getDatabaseTimeStamp()"
            user.dateUpdated = dictionary["dateUpdated"] as? String ?? "getDatabaseTimeStamp()"
            user.name = dictionary["name"] as? String ?? "Joe Doe"
            user.details = dictionary["details"] as? String ?? "nil"
            user.membership = dictionary["membership"] as? Int ?? 0
            user.status = dictionary["status"] as? String ?? "Away"
            user.imgUrl = dictionary["imgUrl"] as? String ?? "nil"

            return user
        }
}



/**
 
 class User: Object {
     @objc dynamic var id: String = "" // Primary key
     @objc dynamic var username: String = "joedoiest"
     @objc dynamic var auth: String = "SPARK_USER"
     @objc dynamic var email: String = "UNASSIGNED_USER"
     @objc dynamic var phone: String = "UNASSIGNED_USER"
     @objc dynamic var organization: String = "UNASSIGNED_USER"
     @objc dynamic var organizationId: String = "UNASSIGNED_USER"
     @objc dynamic var visibility: String = "closed"
     @objc dynamic var photoUrl: String = "UNASSIGNED_USER"
     @objc dynamic var emailVerified: Bool = false
     @objc dynamic var coach: Bool = false
     @objc dynamic var dateCreated: String = "getDatabaseTimeStamp()"
     @objc dynamic var dateUpdated: String = "getDatabaseTimeStamp()"
     @objc dynamic var name: String? = "Joe Doe"
     @objc dynamic var firstName: String? = nil
     @objc dynamic var lastName: String? = nil
     @objc dynamic var type: String = "null"
     @objc dynamic var subType: String? = nil
     @objc dynamic var details: String? = nil
     @objc dynamic var isFree: Bool = false
     @objc dynamic var status: String? = "Away"
     @objc dynamic var mode: String? = nil
     @objc dynamic var imgUrl: String? = nil
     @objc dynamic var sport: String? = nil

     override static func primaryKey() -> String? {
         return "id"
     }
 }
 */
