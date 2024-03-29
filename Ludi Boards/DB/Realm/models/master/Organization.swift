//
//  Team.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import RealmSwift

class Organization: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var name: String = ""
    @Persisted var type: String = ""
    @Persisted var logoUrl: String?
    @Persisted var founded: Int = 0 // considering the year alone is sufficient
    @Persisted var location: String = ""
    @Persisted var contactInfo: String = ""
    @Persisted var descriptionText: String = ""
    @Persisted var sports: List<String> = List<String>()
    @Persisted var officialWebsite: String?
    @Persisted var members: Int = 0
    @Persisted var socialMediaLinks: List<String> = List<String>()
}
