//
//  PlayerRef.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import RealmSwift

class PlayerRef: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var ownerId: String = ""
    @Persisted var orgId: String = ""
    @Persisted var teamId: String = ""
    @Persisted var userId: String = ""
    @Persisted var sessionId: String = ""
    @Persisted var activityId: String = ""
    @Persisted var toolId: String = ""
    @Persisted var name: String = ""
    @Persisted var position: String = ""
    @Persisted var number: Int = 0
    @Persisted var tag: Int = 0
    @Persisted var foot: String = ""
    @Persisted var hand: String = ""
    @Persisted var age: String = ""
    @Persisted var year: String = ""
    @Persisted var imgUrl: String = ""
    @Persisted var height: String = ""
    @Persisted var weight: String = ""
}
