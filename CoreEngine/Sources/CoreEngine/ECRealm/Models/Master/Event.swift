//
//  Event.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/1/24.
//

import Foundation
import RealmSwift

public class Event: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var orgId: String = ""
    @Persisted public var teamId: String = ""
    @Persisted public var sessionId: String = ""
    @Persisted public var createdBy: String = ""
    @Persisted public var name: String = ""
    @Persisted public var eventType: String = EventType.practice.rawValue
    @Persisted public var opponent: String = ""
    @Persisted public var location: String = ""
    @Persisted public var startTime: String = ""
    @Persisted public var endTime: String = ""
    @Persisted public var startDate: String = ""
    @Persisted public var endDate: String = ""
    @Persisted public var descriptionText: String = ""
    @Persisted public var isReoccurring: Bool = false
    @Persisted public var isDeleted: Bool = false
}
