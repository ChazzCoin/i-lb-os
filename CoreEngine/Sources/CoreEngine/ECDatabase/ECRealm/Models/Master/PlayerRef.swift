//
//  PlayerRef.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import RealmSwift

public class PlayerRef: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id = UUID().uuidString
    @Persisted public var ownerId: String = ""
    @Persisted public var orgId: String = ""
    @Persisted public var teamId: String = ""
    @Persisted public var userId: String = ""
    @Persisted public var sessionId: String = ""
    @Persisted public var activityId: String = ""
    @Persisted public var toolId: String = ""
    @Persisted public var name: String = ""
    @Persisted public var position: String = ""
    @Persisted public var number: Int = 0
    @Persisted public var tag: Int = 0
    @Persisted public var foot: String = ""
    @Persisted public var hand: String = ""
    @Persisted public var age: String = ""
    @Persisted public var year: String = ""
    @Persisted public var gender: String = ""
    @Persisted public var imgUrl: String = ""
    @Persisted public var height: String = ""
    @Persisted public var weight: String = ""
    @Persisted public var isDeleted: Bool = false
}
