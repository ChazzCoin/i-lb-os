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
    @Persisted var ownerId: String = ""
    @Persisted var parentId: String = ""
    @Persisted var name: String = ""
    @Persisted var color: String = ""
    @Persisted var sport: String = ""
    @Persisted var coachName: String = ""
    @Persisted var year: String = ""
    @Persisted var age: String = ""
    @Persisted var imgUrl: String = ""
    
}
