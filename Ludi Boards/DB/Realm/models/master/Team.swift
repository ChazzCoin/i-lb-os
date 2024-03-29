//
//  Team.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import RealmSwift

class Team: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var orgId: String = ""
    @Persisted var name: String = ""
    @Persisted var coachName: String = ""
    @Persisted var sportType: String = ""
    @Persisted var logoUrl: String?
    @Persisted var foundedYear: String = "2020"
    @Persisted var homeCity: String = ""
    @Persisted var stadiumName: String = ""
    @Persisted var roster: List<String> = List<String>() // Assuming Player is another Realm model
    @Persisted var coach: String = ""
    @Persisted var manager: String = ""
    @Persisted var league: String = ""
    @Persisted var achievements: List<String> = List<String>()
    @Persisted var officialWebsite: String?
    @Persisted var socialMediaLinks: List<String> = List<String>()
    
}
