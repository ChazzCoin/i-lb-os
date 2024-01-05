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
