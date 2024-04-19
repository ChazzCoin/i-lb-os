//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/18/24.
//

import Foundation
import RealmSwift


public class CoreNotification: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) public var id = UUID().uuidString
    @Persisted public var dateCreated = getTimeStamp()
    @Persisted public var title = ""
    @Persisted public var subtitle = ""
    @Persisted public var icon = ""
    @Persisted public var details = ""
    @Persisted public var duration = 0 // duration in seconds
    @Persisted public var priority: String = "low"

}
