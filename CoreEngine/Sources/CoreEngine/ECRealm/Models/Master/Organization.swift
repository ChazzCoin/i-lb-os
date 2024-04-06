//
//  Team.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import RealmSwift

public class Organization: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id = UUID().uuidString
    @Persisted public var name: String = ""
    @Persisted public var type: String = ""
    @Persisted public var logoUrl: String = ""
    @Persisted public var founded: String = "" // considering the year alone is sufficient
    @Persisted public var location: String = ""
    @Persisted public var contactInfo: String = ""
    @Persisted public var descriptionText: String = ""
    @Persisted public var sports: List<String> = List<String>()
    @Persisted public var officialWebsite: String?
    @Persisted public var members: Int = 0
    @Persisted public var socialMediaLinks: List<String> = List<String>()
    @Persisted public var isDeleted: Bool = false
}
