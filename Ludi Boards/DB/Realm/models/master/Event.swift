//
//  Event.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/1/24.
//

import Foundation
import RealmSwift

class Event: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var orgId: String = ""
    @Persisted var teamId: String = ""
    @Persisted var sessionId: String = ""
    @Persisted var name: String = ""
    @Persisted var eventType: String = EventType.practice.rawValue
    @Persisted var location: String = ""
    @Persisted var startTime: String = ""
    @Persisted var endTime: String = ""
    @Persisted var descriptionText: String = ""
    @Persisted var isReoccurring: Bool = false
}