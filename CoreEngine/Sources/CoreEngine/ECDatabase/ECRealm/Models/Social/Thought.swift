//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/18/24.
//

import RealmSwift
import Foundation

public class Thought: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) public var id = UUID().uuidString
    @Persisted public var message: String = ""
    @Persisted public var category: String = "General"
    @Persisted public var duration: TimeInterval = 0
    @Persisted public var startTime: TimeInterval = Date().timeIntervalSince1970
    @Persisted public var endTime: TimeInterval = Date().timeIntervalSince1970
    @Persisted public var likes: Int = 0

    public convenience init(message: String, startTime: TimeInterval, endTime: TimeInterval) {
        self.init()
        self.message = message
        self.startTime = startTime
        self.endTime = endTime
    }
    
    public convenience init(message: String, duration: TimeInterval) {
        self.init()
        self.message = message
        self.duration = duration
    }
    
    public var startDate: Date {
        return Date(timeIntervalSince1970: startTime)
    }

    public var endDate: Date {
        return Date(timeIntervalSince1970: endTime)
    }
}
