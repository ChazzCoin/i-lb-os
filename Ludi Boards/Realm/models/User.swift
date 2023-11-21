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
