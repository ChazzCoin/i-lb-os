//
//  Stopwatch.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/4/23.
//

import Foundation
import RealmSwift


@objcMembers class Stopwatch: Object, Identifiable {
    dynamic var id: String = UUID().uuidString
    dynamic var timeElapsed: String = "00:00:00"
    dynamic var isRunning: Bool = false
    dynamic var hostId: String = ""
    dynamic var hostName: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

}
extension Stopwatch {
    
    convenience init(dictionary: [String: Any]) {
        self.init()
        let properties = self.objectSchema.properties.map { $0.name }
        
        for property in properties {
            if let value = dictionary[property] {
                self.setValue(value, forKey: property)
            }
        }
    }
    
    func toDict() -> [String: Any] {
        let properties = self.objectSchema.properties.map { $0.name }
        var dictionary: [String: Any] = [:]
        for property in properties {
            dictionary[property] = self.value(forKey: property)
        }
        return dictionary
    }
}
