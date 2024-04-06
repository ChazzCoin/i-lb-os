//
//  Team.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import RealmSwift

public class Team: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id = UUID().uuidString
    @Persisted public var orgId: String = ""
    @Persisted public var name: String = ""
    @Persisted public var coachName: String = ""
    @Persisted public var sportType: String = ""
    @Persisted public var logoUrl: String?
    @Persisted public var foundedYear: String = "2020"
    @Persisted public var homeCity: String = ""
    @Persisted public var stadiumName: String = ""
    @Persisted public var roster: List<String> = List<String>() // Assuming Player is another Realm model
    @Persisted public var coach: String = ""
    @Persisted public var manager: String = ""
    @Persisted public var league: String = ""
    @Persisted public var achievements: List<String> = List<String>()
    @Persisted public var officialWebsite: String?
    @Persisted public var socialMediaLinks: List<String> = List<String>()
    @Persisted public var isDeleted: Bool = false
}
